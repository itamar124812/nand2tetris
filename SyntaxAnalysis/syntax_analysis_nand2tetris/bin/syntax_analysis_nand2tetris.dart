

import 'dart:io';
import 'Parsing.dart';
import 'Tokenizing.dart';
String basename(String path) {
  if ((path.contains(r"\"))) return path.split(r"\").last;
  return path;
}
Future<void> main(List<String> arguments) async {
  var path=r"C:\nand2\nand2tetris\projects\10\ArrayTest";
  var dir = Directory(path);
 final regx = RegExp("^.*.jack\$");
  await for (final FileSystemEntity f in dir.list()) {
      var fileName = basename(f.path);
      if (regx.hasMatch(fileName) && f is File) {
        Tokenizing(f.path);
      }}
  
  
}
