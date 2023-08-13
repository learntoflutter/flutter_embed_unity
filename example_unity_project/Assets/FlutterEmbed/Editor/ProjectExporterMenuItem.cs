using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ProjectExporterMenuItem : EditorWindow
{
    private static ProjectExportChecker projectExportChecker = new ProjectExportChecker();
    private static ProjectExporter projectExporter = new ProjectExporter();

    [MenuItem("Flutter Embed/Export project to flutter app (Android)")]
    static void ExportProjectAndroid()
    {
        ProjectExportCheckerResult result = projectExportChecker.PreCheck();

        if(result.IsSuccessful) {
            projectExporter.ExportAndroid(result.BuildPlayerOptions, result.PrecheckWarnings);
        }
    }
}
