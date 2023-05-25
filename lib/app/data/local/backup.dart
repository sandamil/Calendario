// import 'dart:async';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io' as io;
// import 'package:intl/intl.dart';
// // import 'package:share_extend/share_extend.dart';
// import 'package:path/path.dart';
// import 'package:file_picker/file_picker.dart';
//
// Future<bool> importDatabase() async {
//   // close current
//   await db.close();
//
//   // delete current
//   io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
//   String sourcePath = join(documentsDirectory.path, DB_NAME);
//   io.File sourceFile = io.File(sourcePath);
//   sourceFile.delete();
//
//   // Source file
//   List content = await dbToImport.readAsBytes();
//
//   // target file
//   final targetPath = join(documentsDirectory.path, DB_NAME);
//   io.File targetFile = io.File(targetPath);
//   await targetFile.writeAsBytes(content, flush: true);
//
//   io.exit(0);
//
//   return true;
// }
//
// Future<String> copyDatabase(BuildContext context) async {
//   // make all files one
//   await db.vacuum();
//
//   // Source file
//   io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
//   String sourcePath = join(documentsDirectory.path, DB_NAME);
//   io.File sourceFile = io.File(sourcePath);
//   List content = await sourceFile.readAsBytes();
//
//   // target file
//   final targetPath = join(documentsDirectory.path, '${getDateFormated(context)}.db');
//   io.File targetFile = io.File(targetPath);
//   await targetFile.writeAsBytes(content, flush: true);
//
//   return targetPath;
// }
//
//
// Future<void> share() async {
//   String path = await copyDatabase(context);
//   await ShareExtend.share(path,'file');
// }