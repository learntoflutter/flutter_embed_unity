
// Using UNITY_IOS preprocessor because 'using UnityEditor.iOS.Xcode' is only available with iOS build tools
#if UNITY_IOS

using System.IO;
using UnityEditor;
using UnityEditor.iOS.Xcode;
using UnityEngine;


internal class ProjectExporterIos : ProjectExporter
{

    protected override void TransformExportedProject(string exportPath)
    {
        Debug.Log("Transforming Unity export for Flutter integration...");

        FileInfo pbxProjFileInfo = new FileInfo(Path.Combine(exportPath, "Unity-iPhone.xcodeproj", "project.pbxproj"));

        if(!pbxProjFileInfo.Exists) {
            ProjectExportHelpers.ShowErrorMessage($"Error transforming iOS export: couldn't find {pbxProjFileInfo.FullName}");
            return;
        }

        // Add UnityFramework to the build
        // var pbx = new PBXProject();
        // pbx.ReadFromFile(pbxProjFileInfo.FullName);
        // var unityFrameworkGuid = pbx.TargetGuidByName("UnityFramework");
        // var dataFolderGuid = pbx.AddFolderReference(Path.Combine(exportPath, "Data"), "Data");
        // pbx.AddFileToBuild(unityFrameworkGuid, dataFolderGuid);
        // pbx.WriteToFile(pbxProjFileInfo.FullName);

        DirectoryInfo burstDebugInformation = new DirectoryInfo(Path.Join(exportPath, "..", "unityLibrary_BurstDebugInformation_DoNotShip"));
        if(burstDebugInformation.Exists) {
            Directory.Delete(burstDebugInformation.FullName, true);
            Debug.Log($"Deleted {burstDebugInformation.FullName}");
        }

        Debug.Log("Transforming Unity export for Flutter integration complete");
    }
}

#endif