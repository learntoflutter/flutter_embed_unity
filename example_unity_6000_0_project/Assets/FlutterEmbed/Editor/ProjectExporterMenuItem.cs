using UnityEditor;

public class ProjectExporterMenuItem : EditorWindow
{
    private static ProjectExportChecker projectExportChecker = new ProjectExportChecker();

    [MenuItem("Flutter Embed/Export project to flutter app (Android)")]
    static void ExportProjectAndroid()
    {
        ProjectExportCheckerResult result = projectExportChecker.PreCheckAndroid();

#if UNITY_ANDROID
        if(result.IsSuccessful) {
            new ProjectExporterAndroid().Export(result.BuildPlayerOptions, result.PrecheckWarnings);
        }
#endif
    }

    [MenuItem("Flutter Embed/Export project to flutter app (iOS)")]
    static void ExportProjectIos()
    {
        // Using UNITY_IOS preprocessor because 'using UnityEditor.iOS.Xcode' is only available with iOS build tools
        ProjectExportCheckerResult result = projectExportChecker.PreCheckIos();
#if UNITY_IOS
        if(result.IsSuccessful) {
            new ProjectExporterIos().Export(result.BuildPlayerOptions, result.PrecheckWarnings);
        }
#endif
    }
}
