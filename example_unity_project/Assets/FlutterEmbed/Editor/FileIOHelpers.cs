using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

internal class FileIOHelpers
{
    static internal void DeleteDirectoryAndContents(DirectoryInfo directory) {
        foreach (FileInfo file in directory.GetFiles()) { file.Delete(); }
        foreach (DirectoryInfo dir in directory.GetDirectories()) { dir.Delete(true); }
        directory.Delete();
    }

    static internal void MoveContentsOfDirectory(DirectoryInfo from, DirectoryInfo to) {
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
