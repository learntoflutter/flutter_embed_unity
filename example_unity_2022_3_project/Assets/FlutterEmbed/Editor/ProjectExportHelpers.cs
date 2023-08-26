using System.IO;
using UnityEditor;

internal class ProjectExportHelpers
{
    static internal void ShowErrorMessage(string errorMessage)
    {
        EditorUtility.DisplayDialog(
                        "Export incomplete",
                        errorMessage,
                        "Okay");
    }

    static internal void MoveContentsOfDirectory(DirectoryInfo from, DirectoryInfo to)
    {
        Directory.CreateDirectory(to.FullName);

        // Copy each file into the new directory.
        foreach (FileInfo fi in from.GetFiles())
        {
            fi.MoveTo(Path.Combine(to.FullName, fi.Name));
        }

        // Copy each subdirectory using recursion.
        foreach (DirectoryInfo diSourceSubDir in from.GetDirectories())
        {
            DirectoryInfo nextTargetSubDir =
                to.CreateSubdirectory(diSourceSubDir.Name);
            MoveContentsOfDirectory(diSourceSubDir, nextTargetSubDir);
        }
    }
}