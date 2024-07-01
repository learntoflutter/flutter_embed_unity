using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

internal abstract class ProjectExporter {
    internal void Export(BuildPlayerOptions buildPlayerOptions, List<string> precheckWarnings)
    {        
        // This executes the build:
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);

        if (report.summary.result != BuildResult.Succeeded) {
            Debug.LogError("Building project for Flutter failed");
        }
        else {
            TransformExportedProject(buildPlayerOptions.locationPathName);

            // Debug.Log doesn't work until after BuildPipeline.BuildPlayer has executed
            foreach(var log in precheckWarnings) {
                Debug.LogWarning(log);
            }
            Debug.Log($"Building project for Flutter succeeded");
        }
    }

    protected abstract void TransformExportedProject(string exportPath);
}