package com.appclonepro.appclone_pro

import android.content.Context
import java.io.File

/// Manages isolated storage and virtual container filesystem for each clone.
/// Each clone gets its own dedicated data directories:
///   /data/data/com.appclonepro.appclone_pro/files/containers/{cloneId}/
///     ├── files/
///     ├── databases/
///     ├── shared_prefs/
///     └── cache/
class VirtualContainerManager(private val context: Context) {

    private val baseDir: File = File(context.filesDir, "containers").apply { mkdirs() }

    fun getContainerDir(cloneId: String): File {
        return File(baseDir, cloneId).apply {
            if (!exists()) {
                mkdirs()
                File(this, "files").mkdirs()
                File(this, "databases").mkdirs()
                File(this, "shared_prefs").mkdirs()
                File(this, "cache").mkdirs()
            }
        }
    }

    fun calculateStorageBytes(cloneId: String): Long {
        val dir = File(baseDir, cloneId)
        if (!dir.exists()) return 0L
        return getFolderSize(dir)
    }

    fun clearContainer(cloneId: String): Boolean {
        val dir = File(baseDir, cloneId)
        return if (dir.exists()) {
            dir.deleteRecursively()
        } else {
            true
        }
    }

    private fun getFolderSize(file: File): Long {
        var size: Long = 0
        val files = file.listFiles() ?: return 0L
        for (f in files) {
            size += if (f.isDirectory) getFolderSize(f) else f.length()
        }
        return size
    }
}
