import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database/database_helper.dart';

class BackupService {
  static Future<void> exportBackup(BuildContext context) async {
    try {
      final dbPath = join(await getDatabasesPath(), 'mave_sales.db');
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final name =
          'mave_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.db';
      final exportPath = join(tempDir.path, name);

      await File(dbPath).copy(exportPath);

      await Share.shareXFiles(
        [XFile(exportPath)],
        subject: 'MAVE Sales — резервная копия',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    }
  }

  // Returns true if import succeeded and app needs full reload.
  static Future<bool> importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return false;
      final pickedPath = result.files.single.path;
      if (pickedPath == null) return false;

      // Close the current database connection before overwriting.
      await DatabaseHelper().close();

      final dbPath = join(await getDatabasesPath(), 'mave_sales.db');
      await File(pickedPath).copy(dbPath);

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка импорта: $e')),
        );
      }
      return false;
    }
  }
}
