import 'dart:ffi';
import 'dart:io';

String basename(String path) {
  if ((path.contains(r"\"))) return path.split(r"\").last;
  return path;
}

Future<void> main(List<String> arguments) async {
  int count=1;
  var dir = Directory("C:\\Users\\USER");
  final regx = RegExp("^.*.vm\$");
  try {
    await for (final FileSystemEntity f in dir.list()) {
      var fileName = basename(f.path);
      if (regx.hasMatch(fileName) && f is File) {
        count=0;
        var outputFile =
            File(dir.path + r"\" + fileName.split('.')[0] + ".asm");
        outputFile.create(recursive: true).then((File outputFile) {});
        var lines = await (f as File).readAsLines();
        String lexical = "";
        for (var line in lines) {
          var items = line.split(" ");
          switch (items[0]) {
            case "push":
              lexical += "@SP\n";
              lexical += push(items[1], items[2]);
              break;
            case "pop":
              if (items[1] == "pointer") {
                lexical += pop(int.parse(items[2]), true, "");
              } else if (items[1] == "temp") {
                lexical += pop(5 + int.parse(items[2]), false, "");
              } else {
                var type="";
                switch(items[1])
                {
                  case "local":type="LCL";break;
                  case "argument":type="ARG";break;
                  case "this":type="THIS";break;
                  case "that":type="THAT";break;
                }
                lexical += pop(int.parse(items[2]), false, type);
              }
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
              lexical += "@SP\nA=M-1\nM=!M\n\n@SP\nM=M-1\n";
              break;
            default:
              {}
              break;
          }
          lexical+="\n//Command number is $count\n\n";
          count++;
        }   
        outputFile.writeAsString(lexical);
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

String lt() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JGT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1\n";
}

String gt() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JLT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1\n";
}

String eq() {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE0\nD;JEQ\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE0\n0;JMP\n(IF_TRUE0)\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n@SP\nM=M-1\n";
}

String neg(List<String> items) {
  return "@SP\nA=M-1\nD=-M\nM=D\n@SP\nM=M-1\n";
}

String add(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D+M \n@SP\nM=M-1 \n";
}

String sub(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D-M \n@SP\nM=M-1 \n";
}

String pop(int val, bool pointer, String type) {
  if (type.isNotEmpty) {
    return [
      "@$val",
      "D=A",
      '@' + type,
      "A=M",
      "D=D+A",
      '@' + type,
      "M=D",
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      '@' + type,
      "A=M",
      "M=D",
      "@$val",
      "D=A",
      '@' + type,
      "A=M",
      "D=A-D",
      '@' + type,
      "M=D"
    ].join('\n');
  }
  if (!pointer) {
    return ["@SP", "M=M-1", "M=A", "@$val", "D=M", "@SP", "M=M-1"].join('\n');
  } else {
    if (val == 0) {
      return ["@SP", "M=M-1", "M=A", "@THIS", "D=M", "@SP", "M=M-1"].join('\n');
    } else {
      return ["@SP", "M=M-1", "M=A", "@THAT", "D=M", "@SP", "M=M-1"].join('\n');
    }
  }
}

String push(String offset, var value) {
  String result = "";
  int val = int.parse(value);
  switch (offset) {
    case "local":
      result += "@LCL\n";
      result += "D=M+" +
          val.toString() +
          "\n" +
          "@D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "argument":
      result += "@ARG\n";
      result += "D=M+" +
          val.toString() +
          "\n" +
          "@D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "THIS":
      result += "@THIS\n";
      result +
          "D=M+" +
          val.toString() +
          "\n" +
          "@D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "THAT":
      result += "@THAT\n";
      result += "D=M+" +
          val.toString() +
          "\n" +
          "@D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "temp":
      result += "@5\nD=A\nD=M+" +
          val.toString() +
          "\nD=D+A\nA=D\nD=M\n@SP\nA=M\nM=D\n@SP\n M=M+1\n";
      break;
    case "pointer":
      if (val == 1) {
        result += "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      } else {
        result += "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      }
      break;
    case "constant":
      result += "@" + value.toString() + "\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "static":
      result +=
          "@ClassA." + val.toString() + " D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
  }
  return result;
}
