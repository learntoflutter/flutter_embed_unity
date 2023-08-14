using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing.Printing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using PlasticPipe.PlasticProtocol.Messages;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

internal class ProjectExporter
{
    internal void ExportAndroid(BuildPlayerOptions buildPlayerOptions, List<string> precheckWarnings)
    {        
        // This executes the build:
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);

        if (report.summary.result != BuildResult.Succeeded) {
            Debug.LogError("Building Android project failed");
        }
        else {
            // Debug.Log doesn't work until after BuildPipeline.BuildPlayer has executed
            foreach(var log in precheckWarnings) {
                Debug.LogWarning(log);
            }

            Debug.Log($"Building Android project to {buildPlayerOptions.locationPathName} succeeded");
            TransformExportedProject(buildPlayerOptions.locationPathName);
        }
    }

    private void TransformExportedProject(string exportPath)
    {
        Debug.Log("Transforming Unity export for Flutter integration...");

        // The exported project has this structure:
        // 
        // <unityLibrary>
        // |
        // |- <gradle>
        // |- <launcher>
        // |- <unityLibrary>
        // |- build.gradle
        // |- gradle.properties
        // |- local.properties
        // |- settings.gradle
        //
        // The structure is:
        // A library part in the unityLibrary module that you can integrate into any other Gradle project. This contains the Unity runtime and Player data.
        // A thin launcher part in the launcher module that contains the application name and its icons. This is a simple Android application that launches Unity.
        //
        // This needs to be transformed into a single module (the unityLibrary part).
        // The launcher module is not needed, as the user's Flutter project's android part will be the 'launcher'.
        // However, we do need the string.xml file from the launcher, as this contains some strings which Unity
        // will expect to find (and will crash with android.content.res.Resources$NotFoundException if they don't exist)
        // So, first, copy strings.xml 
        // from `<exportPath>\launcher\src\main\res\values\` 
        // to   `<exportPath>\unityLibrary\src\main\res\values\`

        string stringsResourceFileFromPath = new string[] {exportPath, "launcher", "src", "main", "res", "values", "strings.xml"}
                .Aggregate((a, b) => Path.Combine(a, b));
        string stringResourcesFileToPath = new string[] {exportPath, "unityLibrary", "src", "main", "res", "values", "strings.xml"}
                .Aggregate((a, b) => Path.Combine(a, b));

        FileInfo stringsResourceFile = new FileInfo(stringsResourceFileFromPath);

        if(!stringsResourceFile.Exists) {
            ShowErrorMessage($"Unexpected error: '{stringsResourceFile.FullName} not found");
            return;
        }

        stringsResourceFile.MoveTo(stringResourcesFileToPath);
        Debug.Log($"Moved {stringsResourceFileFromPath} to {stringResourcesFileToPath}");

        // The launcher folder can now be deleted
        DirectoryInfo launcherDirectory = new DirectoryInfo(Path.Combine(exportPath, "launcher"));
        FileIOHelpers.DeleteDirectoryAndContents(launcherDirectory);
        Debug.Log($"Deleted {launcherDirectory.FullName}");

        // The gradle folder can be deleted
        DirectoryInfo gradleDirectory = new DirectoryInfo(Path.Combine(exportPath, "gradle"));
        FileIOHelpers.DeleteDirectoryAndContents(gradleDirectory);
        Debug.Log($"Deleted {gradleDirectory.FullName}");

        // The files at the root of exportPath can be deleted
        DirectoryInfo exportDirectory = new DirectoryInfo(exportPath);
        foreach (FileInfo file in exportDirectory.GetFiles()) { 
            file.Delete(); 
            Debug.Log($"Deleted {file.FullName}");
        }

        // Now move the contents of 
        //    '<exportPath>/unityLibrary/unityLibrary' 
        // to '<exportPath>/unityLibrary'
        // so that the unityLibrary module is 'promoted' to being the main and only module of the export
        DirectoryInfo unityLibrarySubModuleDirectory = new DirectoryInfo(Path.Combine(exportPath, "unityLibrary"));
        if(!unityLibrarySubModuleDirectory.Exists) {
            ShowErrorMessage($"Unexpected error: '{unityLibrarySubModuleDirectory.FullName} not found");
            return;
        }
        FileIOHelpers.MoveContentsOfDirectory(unityLibrarySubModuleDirectory, exportDirectory);
        unityLibrarySubModuleDirectory.Delete(true);
        Debug.Log($"Moved {unityLibrarySubModuleDirectory.FullName} to {exportDirectory.FullName}");

        // The export includes an activity in the AndroidManifest.xml which is not going to be
        // used (because we are using a Flutter PlatfromView instead). Remove it
        FileInfo androidManifestFile = new FileInfo(Path.Combine(exportPath, "src", "main", "AndroidManifest.xml"));
        if(!androidManifestFile.Exists) {
            ShowErrorMessage($"Unexpected error: '{androidManifestFile.FullName} not found");
            return;
        }
        string androidManifestContents = File.ReadAllText(androidManifestFile.FullName);
        Regex regexActivityTag = new Regex(@"<activity.*>(\s|\S)+?</activity>", RegexOptions.Multiline);
        androidManifestContents = regexActivityTag.Replace(androidManifestContents, "");
        File.WriteAllText(androidManifestFile.FullName, androidManifestContents);
        Debug.Log($"Removed <activity> from {androidManifestFile.FullName}");

        // Add the namespace 'com.unity3d.player' to unityLibrary\build.gradle
        // for compatibility with Gradle 8
        FileInfo buildGradleFile = new FileInfo(Path.Combine(exportPath, "build.gradle"));
        if(!buildGradleFile.Exists) {
            ShowErrorMessage($"Unexpected error: '{buildGradleFile.FullName} not found");
            return;
        }
        string buildGradleContents = File.ReadAllText(buildGradleFile.FullName);
        Regex regexAndroidBlock = new Regex(Regex.Escape("android {"));
        buildGradleContents = regexAndroidBlock.Replace(buildGradleContents, "android {\n\tnamespace 'com.unity3d.player'", 1);
        File.WriteAllText(buildGradleFile.FullName, buildGradleContents);
        Debug.Log($"Added namespace 'com.unity3d.player' to {buildGradleFile.FullName} for Gradle 8 compatibility");

        DirectoryInfo burstDebugInformation = new DirectoryInfo(Path.Join(exportPath, "..", "unityLibrary_BurstDebugInformation_DoNotShip"));
        if(burstDebugInformation.Exists) {
            FileIOHelpers.DeleteDirectoryAndContents(burstDebugInformation);
            Debug.Log($"Deleted {burstDebugInformation.FullName}");
        }

        Debug.Log("Transforming Unity export for Flutter integration complete");
    }

    private void ShowErrorMessage(string errorMessage)
    {
        EditorUtility.DisplayDialog(
                        "Export incomplete",
                        errorMessage,
                        "Okay");
    }
}
