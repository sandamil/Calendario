import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Backup {
  DirectoryLocation? _pickedDirecotry;

  Future<void> pickDirectory() async {
    _pickedDirecotry = (await FlutterFileDialog.pickDirectory());
  }

  Future<void> saveFileToDirectory(context, currentFile) async {
    final fileData = currentFile!.readAsBytesSync();
    FlutterFileDialog.saveFileToDirectory(
      directory: _pickedDirecotry!,
      data: fileData,
      fileName: 'newFileName',
      replace: false,
      onFileExists: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('File already exists'),
              children: <Widget>[
                SimpleDialogOption(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                SimpleDialogOption(
                  child: const Text('Replace'),
                  onPressed: () {
                    Navigator.pop(context);
                    FlutterFileDialog.saveFileToDirectory(
                      directory: _pickedDirecotry!,
                      data: fileData,
                      fileName: 'newFileName',
                      replace: true,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> restoreFileToDirectory(
    context,
    currentFile,
    databaseRepository,
  ) async {
    final String db = await databaseRepository.databasePath();
    final params = SaveFileDialogParams(sourceFilePath: db, data: currentFile);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    debugPrint(filePath);
  }

  static Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/notas_database.db');
  }

  static Future<File> writeBackup(path) async {
    debugPrint(path);
    final file = await _localFile;
    print(file);
    return file.copy(path);
  }

  static Future<String> readBackup(String path) async {
    try {
      final file = File(path);
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }
}

createBackup(notas) async {
  try {
    var file = await Backup.writeBackup(notas);
    final params = SaveFileDialogParams(
      sourceFilePath: file.path,
      mimeTypesFilter: ['application/json'],
    );
    await FlutterFileDialog.saveFile(params: params);
  } catch (e) {
    print('ERROR: Creating backup failed. $e');
  }
}

const ENCRYPT_DB = false;

Future<Uint8List> getBytesFile(File file) async {
  final data = await file.readAsBytes();
  return data;
}

Future<String> getStringFile(File file) async {
  final data = await file.readAsString();
  return data;
}

Future<File?> getFileStorage() async {
  final pickedFile = await FilePicker.pickFile();
  final path = pickedFile?.path;
  if (path == null) return null;
  return File(path);
}

Future<bool> backupJson(databaseRepository) async {
  final String backup =
      await databaseRepository.generateBackup(isEncrypted: ENCRYPT_DB);
  final Directory downloadDirectory = Directory('storage/emulated/0/Download/');
  final DateTime now = DateTime.now();
  final String fecha = DateFormat('yyMMdd').format(now);
  final String nombre = '${fecha}_lista_series.json';
  final String path = join('${downloadDirectory.absolute.path}$nombre');
  final File file = File(path);

  if (await Permission.storage.request().isGranted) {
    file.writeAsString(backup);
    return true;
  } else {
    return false;
  }
}

Future<bool> restoreJson(databaseRepository) async {
  try {
    final pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb,
    );

    if (pickedFile == null) return false;

    final String backup;

    if (kIsWeb) {
      final bytes = pickedFile.bytes;
      if (bytes == null) return false;
      backup = String.fromCharCodes(bytes);
    } else {
      final path = pickedFile.path;
      if (path == null) return false;
      backup = await File(path).readAsString();
    }

    final List json =
        databaseRepository.jsonBackup(backup, isEncrypted: ENCRYPT_DB);
    await databaseRepository.clearAllTables();
    await databaseRepository.restoreBackup(json);
    return true;
  } catch (e, stackTrace) {
    debugPrint('ERROR: Restoring JSON backup failed: $e');
    debugPrint('$stackTrace');
    return false;
  }
}

backupDb(databaseRepository) async {
  debugPrint('backupDb');
  await Backup().pickDirectory();
}

Future<bool> restaurarDb(databaseRepository) async {
  print('backupDb');
  final Directory downloadDirectory = Directory('/sdcard/Download/');
  final DateTime now = DateTime.now();
  final String fecha = DateFormat('yyMMdd').format(now);
  final String nombre = '${fecha}_bkp_${databaseRepository.databaseName}';
  final String newPath = join('${downloadDirectory.absolute.path}$nombre');
  final String db = await databaseRepository.databasePath();
  final File file = File(newPath);

  if (await Permission.photos.request().isGranted) {
    print('yes');
    await file.copy(db);
    print('yes¡¡¡¡¡');

    return true;
  } else {
    print('nooooooooo');
    return false;
  }
}
