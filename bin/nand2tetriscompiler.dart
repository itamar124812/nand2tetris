import 'dart:ffi';
import 'dart:io';

String basename(String path) {
  if ((path.contains(r"\"))) return path.split(r"\").last;
  return path;
}

Future<void> main(List<String> arguments) async {
  int count=1;
  var dir = Directory(arguments[0]);
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
              lexical += push(items[1], items[2],fileName.split('.')[0]);
              break;
            case "pop":
              if (items[1] == "pointer") {
                lexical += pop(int.parse(items[2]), true, "");
              }
              else if (items[1] == "temp") {
                lexical += pop(5 + int.parse(items[2]), false, "");
              }
              else if(items[1] == "static"){
                 String filen = fileName.split(".")[0]+"."+items[2];
                 lexical += "@SP\nM=M-1\nA=M\nD=M\n@$filen\nM=D\n";

          }
              else {
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
              lexical += eq(count);
              break;
            case "gt":
              lexical += gt(count);
              break;
            case "lt":
              lexical += lt(count);
              break;
            case "or":
              lexical += "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D|M \n@SP\nM=M-1 \n";
              break;
            case "and":
              lexical += "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D&M \n@SP\nM=M-1 \n";
              break;
            case "not":
              lexical += "@SP\nA=M-1\nM=!M\n";//@SP\nM=M-1\n";
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

String lt(int j) {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE"+j.toString()+"\nD;JGT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE"+j.toString()+"\n0;JMP\n(IF_TRUE"+j.toString()+")\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE"+j.toString()+")\n@SP\nM=M-1\n";
}

String gt(int j) {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE"+j.toString()+"\nD;JLT\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE"+j.toString()+"\n0;JMP\n(IF_TRUE"+j.toString()+")\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE"+j.toString()+")\n@SP\nM=M-1\n";
}

String eq(int j) {
  return "@SP \nA=M-1\nD=M\nA=A-1\nD=D-M\n@IF_TRUE"+j.toString()+"\nD;JEQ\nD=0\n@SP\nA=M-1\nA=A-1\nM=D\n@IF_FALSE"+j.toString()+"\n0;JMP\n(IF_TRUE"+j.toString()+")\nD=-1\n@SP\nA=M-1\nA=A-1\nM=D\n(IF_FALSE"+j.toString()+")\n@SP\nM=M-1\n";
}

String neg(List<String> items) {///
  return "@SP\nA=M-1\nD=-M\nM=D\n";
}

String add(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=D+M \n@SP\nM=M-1 \n";
}

String sub(List<String> items) {
  return "@SP\nA=M-1 \nD=M \nA=A-1 \nM=M-D \n@SP\nM=M-1 \n";
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
    return ["@SP", "M=M-1", "A=M","D=M", "@$val", "M=D"].join('\n');
  }
  else {
    if (val == 0) {
      return ["@SP", "M=M-1", "A=M",  "D=M", "@THIS", "M=D"].join('\n');
    } else {
      return ["@SP", "M=M-1", "A=M",  "D=M", "@THAT", "M=D"].join('\n');
    }
  }
}

String push(String offset, var value,String filename) {
  String result = "";
  int val = int.parse(value);
  switch (offset) {
    case "local":
      result += "@$val" +  "\nD=A\n@LCL\n";
      result += "A=M\nD=D+A\nA=D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "argument":
      result += "@$val" +  "\nD=A\n@ARG\n";
      result += "A=M\nD=D+A\nA=D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "this":
      result += "@$val" +  "\nD=A\n@THIS\n";
      result += "A=M\nD=D+A\nA=D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "that":
      result += "@$val" + "\nD=A\n@THAT\n";
      result += "A=M\nD=D+A\nA=D\n" +
          "D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
    case "temp":
      val += 5;
      result += "@$val\n" +
          "\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
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
          "@$filename." + val.toString() + "\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
      break;
  }
  return result;
}
