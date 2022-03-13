import 'dart:ffi';
import 'dart:io';

String basename(String path) {
  if ((path.contains(r"\"))) return path.split(r"\").last;
  return path;
}

Future<void> main(List<String> arguments) async {
  var dir = Directory("C:\\Users\\USER");
  final regx = RegExp("^.*.vm\$");
  try {
    await for (final FileSystemEntity f in dir.list()) {
      var fileName = basename(f.path);
      if (regx.hasMatch(fileName) && f is File) {
        var outputFile =
            File(dir.path + r"\" + fileName.split('.')[0] + ".asm");
        outputFile.create(recursive: true).then((File outputFile) {});
        var lines = await (f as File).readAsLines();
        String lexical = "";
        for (var line in lines) {
          var items = line.split(" ");
          switch (items[0]) {
            case "push":
              lexical += "@sp\n";
              lexical += push(items[1], items[2]);
              break;
            case "add":
              lexical += add(items);
              break;
            case "sub":
              lexical += sub(items);
              break;
            case "neg":
              lexical += neg(items);
              break;
            case "eq":
              lexical += eq();
              break;
            case "gt":
              lexical += gt();
              break;
            case "lt":
              lexical += lt();
              break;
            case "or":
              lexical += "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D|M \n@SP\nM=M-1 \n";
              break;
            case "and":
              lexical += "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D&M \n@SP\nM=M-1 \n";
              break;
            case "not":
              lexical += "@sp\nA=M-1\nM=!M\n\n@SP\nM=M-1\n";
              break;
            default:
              {}
              break;
          }
        }
        outputFile.writeAsString(lexical);
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

String push(String offset, var value) {
  String result = "";
  int val=int.parse(value);
  switch (offset) {
    case "local":
      result += "@lcl\n";
      result+="D=M+"+val.toString()+"\n"+"@D\n";
      break;
    case "argument":
      result += "@arg\n";
      result+="D=M+"+val.toString()+"\n"+"@D\n";
      break;
    case "this":
    result+="@THIS\n";
    result+="D=M+"+val.toString()+"\n"+"@D\n";
    break;
    case "that":
    result+="@that\n";
    result+="D=M+"+val.toString()+"\n"+"@D\n";
    break;
    
    case "temp":break;

  }

  return result;
}
