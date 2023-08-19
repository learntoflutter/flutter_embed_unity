using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.Build;

internal class ProjectExportCheckerResult
{
    internal bool IsSuccessful { get; set; }
    internal BuildPlayerOptions BuildPlayerOptions { get; set; }
    internal List<string> PrecheckWarnings { get; set; } = new List<string>();

    internal static ProjectExportCheckerResult Success(BuildPlayerOptions buildPlayerOptions, List<string> precheckWarnings)
    {
        return new ProjectExportCheckerResult
        {
            IsSuccessful = true,
            BuildPlayerOptions = buildPlayerOptions,
            PrecheckWarnings = precheckWarnings
        };
    }

    internal static ProjectExportCheckerResult Failure()
    {
        return new ProjectExportCheckerResult { IsSuccessful = false };
    }
}

internal class ProjectExportChecker
{
    internal ProjectExportCheckerResult PreCheck()
    {
        // Because Debug.Log does not work until after the build, collect any log messages to show at the end:
        List<string> precheckWarnings = new();

        // Check this is the supported version of Unity
#if !UNITY_2022_3
        ShowErrorMessage("This plugin only supports Unity 2022.3 LTS (Long Term Support).");
        return ProjectExportCheckerResult.Failure();
#endif

        // Check various build settings
        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            ShowErrorMessage("Can't export until you change the build target to Android: see File -> Build settings -> Platform, then Switch Target");
            return ProjectExportCheckerResult.Failure();
        }

        if (!EditorUserBuildSettings.exportAsGoogleAndroidProject)
        {
            ShowErrorMessage("Can't export until you tick 'Export project': see File -> Build settings");
            return ProjectExportCheckerResult.Failure();
        }

        AndroidArchitecture architectures = PlayerSettings.Android.targetArchitectures;
        if (!architectures.HasFlag(AndroidArchitecture.ARMv7) || !architectures.HasFlag(AndroidArchitecture.ARM64))
        {
            ShowErrorMessage("You must include ARMv7 and ARM64 as target architectures " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> Target architectures)");
            return ProjectExportCheckerResult.Failure();
        }

        if (PlayerSettings.GetScriptingBackend(EditorUserBuildSettings.selectedBuildTargetGroup) != ScriptingImplementation.IL2CPP)
        {
            ShowErrorMessage("You must set IL2CPP as the scripting backend " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> Scripting backend)");
            return ProjectExportCheckerResult.Failure();
        }

        if (EditorUserBuildSettings.allowDebugging)
        {
            precheckWarnings.Add("'Allow debugging' is set to 'true'. This should be disabled for release builds" +
                "(see File -> Build settings -> Player settings -> untick 'Development build' and 'Script debugging')");
        }

        Il2CppCodeGeneration il2CppCodeGeneration = PlayerSettings.GetIl2CppCodeGeneration(NamedBuildTarget.Android);
        if (il2CppCodeGeneration == Il2CppCodeGeneration.OptimizeSize)
        {
            precheckWarnings.Add($"'IL2CPP code generation' is set to 'Faster (smaller) builds'. This can improve build time (useful for development) " +
                "but should be set to 'Faster runtime' when building your release version " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> IL2CPP code generation)");
        }

        Il2CppCompilerConfiguration il2CppCompilerConfiguration = PlayerSettings.GetIl2CppCompilerConfiguration(BuildTargetGroup.Android);
        if (il2CppCompilerConfiguration == Il2CppCompilerConfiguration.Debug)
        {
            precheckWarnings.Add($"'C++ compiler configuration' is set to 'Debug'. This can be useful for debugging during development " +
                "but should be set to 'Release' when building your release version " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> C++ compiler configuration)");
        }

        bool confirmOpenFolderSelection = EditorUtility.DisplayDialog(
                "Select export directory",
                "In the next window, select the export directory. This should be " +
                "'<your flutter project>/android/unityLibrary'",
                "Select folder",
                "Cancel");

        if (!confirmOpenFolderSelection)
        {
            return ProjectExportCheckerResult.Failure();
        }
        else
        {
            // Get the current BuildPlayerOptions (this also opens a directory window to select the export path)
            BuildPlayerOptions buildPlayerOptions = BuildPlayerWindow.DefaultBuildMethods.GetBuildPlayerOptions(new BuildPlayerOptions());
            DirectoryInfo selectedDirectory = new DirectoryInfo(buildPlayerOptions.locationPathName);

            if (selectedDirectory.Name.Equals("android"))
            {
                bool createUnityLibrarySubfolder = EditorUtility.DisplayDialog(
                    "Create subfolder?",
                    "It looks like you selected the 'android' folder instead of 'android/unityLibrary'. Use 'android/unityLibrary' instead?",
                    "Yes",
                    "Cancel");

                if (createUnityLibrarySubfolder)
                {
                    buildPlayerOptions.locationPathName = Path.Combine(buildPlayerOptions.locationPathName, "unityLibrary");
                    selectedDirectory = new DirectoryInfo(buildPlayerOptions.locationPathName);
                    Directory.CreateDirectory(buildPlayerOptions.locationPathName);
                }
                else
                {
                    return ProjectExportCheckerResult.Failure();
                }
            }

            if (!selectedDirectory.Name.Equals("unityLibrary") || selectedDirectory.Parent == null || selectedDirectory.Parent.Name != "android")
            {
                ShowErrorMessage("Expected a folder named 'unityLibrary' inside 'android' folder. " +
                    "Check the plugin documentation: you need to select '<your flutter project>/android/unityLibrary'. " +
                    "Aborting export");
                return ProjectExportCheckerResult.Failure();
            }
            else
            {
                if (Directory.GetFileSystemEntries(buildPlayerOptions.locationPathName).Length != 0)
                {
                    bool confirmDeleteOldExport = EditorUtility.DisplayDialog(
                        "Confirm overwrite",
                        $"Overwrite existing directory? (this will delete all files in {buildPlayerOptions.locationPathName})",
                        "Overwrite",
                        "Cancel");

                    if (confirmDeleteOldExport)
                    {
                        Directory.Delete(selectedDirectory.FullName, true);
                    }
                }

                return ProjectExportCheckerResult.Success(buildPlayerOptions, precheckWarnings);
            }
        }
    }

    private void ShowErrorMessage(string errorMessage)
    {
        EditorUtility.DisplayDialog(
                        "Export aborted",
                        errorMessage,
                        "Okay");
    }
}
