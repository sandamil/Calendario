
import 'dart:io';
import 'dart:convert';
import 'package:calendario2/app/components/toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/data/local/taskDatabase.dart';

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
  final String newPath = join('${downloadDirectory.absolute.path}$nombre');
  final String db = await databaseRepository.databasePath();
  final File file = File(db);
// Todo fotos?
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      if (await Permission.storage.request().isGranted) {
        print('yes <<<<<32');
        await file.copy(newPath);
        return true;
      } else {
        print('nooooooooo <<<<<32');
        return false;
      }
    }  else {
      if (await Permission.photos.request().isGranted) {
        print('yes > 32');
        await file.copy(newPath);
        return true;
      } else {
        print('nooooooooo  >>>>>32');
        return false;
      }
    }

  }


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
