using System;
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
    internal ProjectExportCheckerResult PreCheckAndroid()
    {
        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            ProjectExportHelpers.ShowErrorMessage("Can't export until you change the build target to Android: see File -> Build settings -> Platform, then Switch Target");
            return ProjectExportCheckerResult.Failure();
        }

        // Because Debug.Log does not work until after the build, collect any log messages to show at the end:
        List<string> precheckWarnings = new();

        // Carry out checks common to Android and iOS. May add precheckWarnings to the list (hence using ref)
        bool passedCommonChecks = PreCheckCommon(ref precheckWarnings, NamedBuildTarget.Android, BuildTargetGroup.Android);

        if (passedCommonChecks)
        {
            if (!EditorUserBuildSettings.exportAsGoogleAndroidProject)
            {
                ProjectExportHelpers.ShowErrorMessage("Can't export until you tick 'Export project': see File -> Build settings");
                return ProjectExportCheckerResult.Failure();
            }

            AndroidArchitecture architectures = PlayerSettings.Android.targetArchitectures;
            if (!architectures.HasFlag(AndroidArchitecture.ARMv7) || !architectures.HasFlag(AndroidArchitecture.ARM64))
            {
                ProjectExportHelpers.ShowErrorMessage("You must include ARMv7 and ARM64 as target architectures " +
                    "(see File -> Build settings -> Player Settings -> Other Settings -> Target architectures)");
                return ProjectExportCheckerResult.Failure();
            }

            return PrepareExportDirectory("android", "unityLibrary", precheckWarnings);
        }
        else
        {
            return ProjectExportCheckerResult.Failure();
        }
    }

    internal ProjectExportCheckerResult PreCheckIos()
    {
        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.iOS)
        {
            ProjectExportHelpers.ShowErrorMessage("Can't export until you change the build target to iOS: see File -> Build settings -> Platform, then Switch Target");
            return ProjectExportCheckerResult.Failure();
        }

        // Because Debug.Log does not work until after the build, collect any log messages to show at the end:
        List<string> precheckWarnings = new();

        // Carry out checks common to Android and iOS. May add precheckWarnings to the list (hence using ref)
        bool passedCommonChecks = PreCheckCommon(ref precheckWarnings, NamedBuildTarget.iOS, BuildTargetGroup.iOS);

        if (passedCommonChecks)
        {
            if(EditorUserBuildSettings.iOSXcodeBuildConfig == XcodeBuildConfig.Debug) {
                precheckWarnings.Add("iOS XCode build configuration is set to 'debug'. This should be set to 'release' for release builds");
            }

            return PrepareExportDirectory("ios", "unityLibrary", precheckWarnings);
        }
        else
        {
            return ProjectExportCheckerResult.Failure();
        }
    }

    private bool PreCheckCommon(ref List<string> precheckWarnings, NamedBuildTarget namedBuildTarget, BuildTargetGroup buildTargetGroup)
    {
#if !UNITY_2022_3
        ShowErrorMessage("This plugin only supports Unity 2022.3 LTS (Long Term Support).");
        return ProjectExportCheckerResult.Failure();
#endif

        if (PlayerSettings.GetScriptingBackend(EditorUserBuildSettings.selectedBuildTargetGroup) != ScriptingImplementation.IL2CPP)
        {
            ProjectExportHelpers.ShowErrorMessage("You must set IL2CPP as the scripting backend " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> Scripting backend)");
            return false;
        }

        if (EditorUserBuildSettings.allowDebugging)
        {
            precheckWarnings.Add("'Allow debugging' is set to 'true'. This should be disabled for release builds" +
                "(see File -> Build settings -> Player settings -> untick 'Development build' and 'Script debugging')");
        }

        Il2CppCodeGeneration il2CppCodeGeneration = PlayerSettings.GetIl2CppCodeGeneration(namedBuildTarget);
        if (il2CppCodeGeneration == Il2CppCodeGeneration.OptimizeSize)
        {
            precheckWarnings.Add($"'IL2CPP code generation' is set to 'Faster (smaller) builds'. This can improve build time (useful for development) " +
                "but should be set to 'Faster runtime' when building your release version " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> IL2CPP code generation)");
        }

        Il2CppCompilerConfiguration il2CppCompilerConfiguration = PlayerSettings.GetIl2CppCompilerConfiguration(buildTargetGroup);
        if (il2CppCompilerConfiguration == Il2CppCompilerConfiguration.Debug)
        {
            precheckWarnings.Add($"'C++ compiler configuration' is set to 'Debug'. This can be useful for debugging during development " +
                "but should be set to 'Release' when building your release version " +
                "(see File -> Build settings -> Player Settings -> Other Settings -> C++ compiler configuration)");
        }

        return true;
    }

    private ProjectExportCheckerResult PrepareExportDirectory(String subfolderName, String folderName, List<string> precheckWarnings)
    {
        bool confirmOpenFolderSelection = EditorUtility.DisplayDialog(
                    "Select export directory",
                    "In the next window, select the export directory. This should be " +
                    $"'<your flutter project>/{subfolderName}/{folderName}'",
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

            if (selectedDirectory.Name.Equals(subfolderName))
            {
                bool createUnityLibrarySubfolder = EditorUtility.DisplayDialog(
                    "Create subfolder?",
                    $"It looks like you selected the '{subfolderName}' folder instead of '{subfolderName}/{folderName}'. " +
                        $"Use '{subfolderName}/{folderName}' instead?",
                    "Yes",
                    "Cancel");

                if (createUnityLibrarySubfolder)
                {
                    buildPlayerOptions.locationPathName = Path.Combine(buildPlayerOptions.locationPathName, folderName);
                    selectedDirectory = new DirectoryInfo(buildPlayerOptions.locationPathName);
                    Directory.CreateDirectory(buildPlayerOptions.locationPathName);
                }
                else
                {
                    return ProjectExportCheckerResult.Failure();
                }
            }

            if (!selectedDirectory.Name.Equals(folderName) || selectedDirectory.Parent == null || selectedDirectory.Parent.Name != subfolderName)
            {
                ProjectExportHelpers.ShowErrorMessage($"Expected a folder named {folderName} inside '{subfolderName}' folder. " +
                    $"Check the plugin documentation: you need to select '<your flutter project>/{subfolderName}/{folderName}'. " +
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
}
