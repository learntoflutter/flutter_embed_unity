using UnityEditor;

public class ProjectExporterMenuItem : EditorWindow
{
    private static ProjectExportChecker projectExportChecker = new ProjectExportChecker();

#if UNITY_ANDROID
    [MenuItem("Flutter Embed/Export project to flutter app (Android)")]
    static void ExportProjectAndroid()
    {
        ProjectExportCheckerResult result = projectExportChecker.PreCheckAndroid();

        if(result.IsSuccessful) {
            new ProjectExporterAndroid().Export(result.BuildPlayerOptions, result.PrecheckWarnings);
        }
    }
#endif

#if UNITY_IOS
    [MenuItem("Flutter Embed/Export project to flutter app (iOS)")]
    static void ExportProjectIos()
    {

        // Using UNITY_IOS preprocessor because 'using UnityEditor.iOS.Xcode' is only available with iOS build tools
        ProjectExportCheckerResult result = projectExportChecker.PreCheckIos();

        if(result.IsSuccessful) {
            new ProjectExporterIos().Export(result.BuildPlayerOptions, result.PrecheckWarnings);
        }
    }
#endif
}
