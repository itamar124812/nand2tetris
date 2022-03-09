import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart';
import 'package:nand2tetriscompiler/nand2tetriscompiler.dart'
    as nand2tetriscompiler;

Future<void> main(List<String> arguments) async {
  var dir = Directory(arguments[0]);
  final regx = RegExp("^.*.vm\$");
  try {
    await for (final FileSystemEntity f in dir.list()) {
      var fileName = basename(f.path);
      if (regx.hasMatch(fileName) && f is File) {
        var lines = await (f as File).readAsLines();
        for (var line in lines) {
          var items = line.split(" ");
          String lexical="";
          switch (items[0]) {
            case "add":
            lexical += add(items);
              break;
            case "sub":
              lexical+=sub(items);
              break;
            case "neg":
              lexical+=neg(items);
              break;
            case "eq":
             lexical+=eq();
              break;
            case "gt":
               lexical+=gt();
              break;
            case "lt":
             lexical+=lt();
              break;
            case "or":
              lexical+="@SP\nA=M-1 \nD=M \nA=A-1 \nM=D|M \n@SP\nM=M-1 \n";
              break;
            case "and":
              lexical+="@SP\nA=M-1 \nD=M \nA=A-1 \nM=D&M \n@SP\nM=M-1 \n";
              break;
            case "not":
            lexical+="@sp\nA=M-1\nM=!M\n\n@SP\nM=M-1\n";
              break;
            default:
              {}
              break;
          }
        }
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

String lt() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JGT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1";
}

String gt() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JLT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1";
}

String eq() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JEQ\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1";
}

String neg(List<String> items) {
  return "@sp\nA=M-1\nD=-M\nM=D\n@SP\nM=M-1\n";
}

String add(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D+M \n@SP\nM=M-1 \n";
}
String sub(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D-M \n@SP\nM=M-1 \n";
}



