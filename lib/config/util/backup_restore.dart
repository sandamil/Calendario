
import 'dart:convert';
import 'dart:io';
import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';



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
      // mimeType: mimeType,
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
                      // mimeType: mimeType,
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




  Future<void> restoreFileToDirectory(context, currentFile, databaseRepository,) async {
    final String db = await databaseRepository.databasePath();
    final params = SaveFileDialogParams(sourceFilePath: db,data: currentFile);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    print(filePath);

    final fileData = currentFile!.readAsBytesSync();

  }



  static Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/notas_database.db');
  }



  static Future<File> writeBackup(path) async {
    print(path);
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


final ajustesController = Get.find<AjustesController>();

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
  FilePickerResult? picker = await FilePicker.platform.pickFiles();
  if (picker != null) {
    final String? path = picker.files.single.path;
    if (path != null) {
      final File file = File(path);
      return file;
    }
  }
  return null;
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
  final File? fileBackup = await getFileStorage();

  if (fileBackup != null) {
    try {
      final backup = await getStringFile(fileBackup);
      await databaseRepository.clearAllTables();
      final List json =
          databaseRepository.jsonBackup(backup, isEncrypted: ENCRYPT_DB);
      await databaseRepository.restoreBackup(json);
      return true;
    } on Exception catch (_) {}
  }
  return false;
}


  backupDb(databaseRepository) async {
  print('backupDb');
  final Directory downloadDirectory = Directory('/sdcard/Download/');
  final DateTime now = DateTime.now();
  final String fecha = DateFormat('yyMMdd').format(now);
  final String nombre = '${fecha}_bkp_${databaseRepository.databaseName}';
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final String newPath = join('${downloadDirectory.absolute.path}$nombre');
  final String db = await databaseRepository.databasePath();
  final File file = File(db);
  final params = SaveFileDialogParams(sourceFilePath: newPath);
  // final filePath = await FlutterFileDialog.saveFile(params: params);

   await Backup().pickDirectory;




  // if (!await FlutterFileDialog.isPickDirectorySupported()) {
  //   print("Picking directory not supported");
  //   return;
  // }
  //
  // final pickedDirectory = await FlutterFileDialog.pickDirectory();
  //
  // if (pickedDirectory != null) {
  //   final filePath = await FlutterFileDialog.saveFileToDirectory(
  //     directory: pickedDirectory!,
  //     data: file.readAsBytesSync(),
  //     mimeType: "image/jpeg",
  //     fileName: "fileName.jpeg",
  //     replace: true,
  //   );
  //   await Backup.writeBackup(filePath);
  //
  // }


// // Todo fotos?
//   if (Platform.isAndroid) {
//     final androidInfo = await DeviceInfoPlugin().androidInfo;
//     if (androidInfo.version.sdkInt <= 32) {
//       if (await Permission.storage.request().isGranted) {
//
//         print('yes <<<<<32  ');
//         // await file.copy(path);
//         final params = SaveFileDialogParams(sourceFilePath: newPath);
//         // final filePath = await FlutterFileDialog.saveFile(params: params);
//         // await Backup.writeBackup(filePath);
//
//         // await Backup.writeBackup(path);
//         // ajustesController.errorBackup = false;
//
//         return true;
//       } else {
//         print('nooooooooo <<<<<32');
//         // ajustesController.errorBackup = true;
//
//         return false;
//       }
//     }  else {
//       if (await Permission.photos.request().isGranted) {
//         print('yes > 32');
//         // await file.copy(path);
//         final params = SaveFileDialogParams(sourceFilePath: newPath);
//         final filePath = await FlutterFileDialog.saveFile(params: params);
//         await Backup.writeBackup(filePath);
//
//         // ajustesController.errorBackup = false;
//
//         return true;
//       } else {
//         print('nooooooooo  >>>>>32');
//         // ajustesController.errorBackup = true;
//
//         return false;
//       }
//     }
//
//   }


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

// Future<bool> restoreDb() async {
//
//   DbProvider databaseRepository = DbProvider();
//
//   final File? fileBackup = await getFileStorage();
//   final String db = await databaseRepository.databasePath();
//   databaseRepository.close();
//   if (fileBackup != null) {
//     try {
//       final Uint8List backup = await getBytesFile(fileBackup);
//       final String txt = utf8.decode(backup.sublist(0, 6));
//       if (txt != 'SQLite') {
//         throw Exception();
//       }
//       await fileBackup.copy(db);
//       Get.snackbar('Database restaurada', '$db');
//
//       return true;
//     } on Exception catch (_) {
//       Get.snackbar('Error', '$_');
//     }
//   }
//   return false;
// }
