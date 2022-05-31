import 'dart:ffi';
import 'dart:io';
import 'dart:convert';

String basename(String path) {
  if ((path.contains(r"\"))) return path.split(r"\").last;
  return path;
}
File filesource(Directory dir,String fileName,bool WORK)
{
  var outputFile;
  if(WORK) {
    outputFile= File(dir.path + r"\" + fileName.split('.')[0] + ".asm");
    outputFile.create(recursive: true).then((File outputFile) {});
  }
  else
  {
    outputFile= File(dir.path + r"\" +dir.path.split("\\").last+".asm");
    if(outputFile.existsSync()) {
      outputFile.open();
    }
    else {
      outputFile.create(recursive: true).then((File outputFile) {});
      String lexical = "//***BOOTSTRAP***\n@256\nD=A\n@SP\nM=D\n";
      outputFile.writeAsString(lexical, mode: FileMode.append);
    }
  }
  return outputFile;
}

Future<void> main(List<String> arguments) async {
  int count = 1;
  var dir = Directory(r"C:\nand2\nand2tetris\projects\08\FunctionCalls\NestedCall");
  bool WIGO = false;//int.parse(arguments[1]) == 1;
  final regx = RegExp("^.*.vm\$");
  List<FileSystemEntity> files = <FileSystemEntity>[];
  bool Sysfilexits = false;
  await for (final FileSystemEntity f in dir.list()) {
    var fileName = basename(f.path);
    if (regx.hasMatch(fileName) && f is File) {
      if(f.path.split("\\").last != "Sys.vm"){
        files.add(f);
      }
      else{
        Sysfilexits = true;
      }
    }
    if(Sysfilexits){
      files.insert(0, File(dir.path + r"\" + "Sys.vm"));
    }
  }
  try {
    for (final FileSystemEntity f in files) {
      var fileName = basename(f.path);
      if (regx.hasMatch(fileName) && f is File) {
        var outputFile = filesource(dir, fileName, WIGO);
        if (outputFile != Null) {
          bool firstCall = true;
          var lines = await (f).readAsLines();
          if(Sysfilexits){
            lines.insert(0, "call Sys.init 0");
          }
          String lexical = "";
          for (var line in lines) {
            if (!line.contains("//") && line != '\n') {
              lexical += "  //  " + line + '\n';
              lexical += "\n//Command number is $count\n\n";
            }
            var items = line.split(" ");
            switch (items[0]) {
              case "push":
                lexical += "@SP\n";
                lexical += push(items[1], items[2], fileName.split('.')[0]);
                break;
              case "pop":
                if (items[1] == "pointer") {
                  lexical += pop(int.parse(items[2]), true, "");
                }
                else if (items[1] == "temp") {
                  lexical += pop(5 + int.parse(items[2]), false, "");
                }
                else if (items[1] == "static") {
                  String filen = fileName.split(".")[0] + "." + items[2];
                  lexical += "@SP\nM=M-1\nA=M\nD=M\n@$filen\nM=D\n";
                }
                else {
                  var type = "";
                  switch (items[1]) {
                    case "local":
                      type = "LCL";
                      break;
                    case "argument":
                      type = "ARG";
                      break;
                    case "this":
                      type = "THIS";
                      break;
                    case "that":
                      type = "THAT";
                      break;
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
                lexical += "@SP\nA=M-1\nM=!M\n"; //@SP\nM=M-1\n";
                break;
              case "goto":
                lexical +=
                    "@" + fileName.split('.')[0] + '.' + items[1] + "\n0;JMP\n";
                break;
              case "label":
                lexical +=
                    '(' + fileName.split('.')[0] + '.' + items[1] + ')\n';
                break;
              case "if-goto":
                lexical +=
                    "@SP\nM=M-1\nA=M\nD=M\n" + '@' + fileName.split('.')[0] +
                        '.' + items[1] + "\nD;JNE\n";
                break;
              case "function":
                lexical += functionSyntax(items);
                break;
              case "return":
                lexical += returnSyntax();
                break;
              case "call":
                lexical += callSyntax(items, count, firstCall);
                firstCall = false;
                break;
              default:
                {}
                break;
            }
            count++;
          }
          outputFile.writeAsString(lexical, mode: FileMode.append);
        }
      }
    }
  }
  catch (e) {
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

String callSyntax(List<String> items,int index,bool mainF) {
  String cSyntax = "";
  cSyntax += "D=A\n@SP\nA=M\nM=D  // return address\n";
  cSyntax += "@SP\nM=M+1\n@LCL\nD=M\n@SP\nA=M\nM=D  // local\n";
  cSyntax += "@SP\nM=M+1\n@ARG\nD=M\n@SP\nA=M\nM=D // argument\n";
  cSyntax += "@SP\nM=M+1\n@THIS\nD=M\n@SP\nA=M\nM=D // this\n";
  cSyntax += "@SP\nM=M+1\n@THAT\nD=M\n@SP\nA=M\nM=D // that\n";
  cSyntax += "@SP\nM=M+1\nD=M\n@"+items[2]+"\nD=D-A\n@5\nD=D-A\n@ARG\nM=D\n";
  cSyntax += "@SP\nD=M\n@LCL\nM=D\n@" +items[1] + "\n0;JMP\n";
  if(mainF){
    cSyntax = "@BOOTSTRAPRETURN\n" + cSyntax + "(BOOTSTRAPRETURN)\n";
  }
  else{
    cSyntax = "@RETURN" + index.toString() + '\n' + cSyntax + "(RETURN" + index.toString() + ')\n';
  }
  return cSyntax;
}

String returnSyntax() {
  String rSyntax = "@LCL\nD=M\n@FRAME\nM=D\n@5\nD=D-A\nA=D\nD=M\n@RET\nM=D\n";
  rSyntax += "@SP\nM=M-1\nA=M\nD=M\n@ARG\nA=M\nM=D\n@ARG\nD=M+1\n@SP\nM=D\n";
  rSyntax += "@FRAME\nD=M\n@1\nD=D-A\nA=D\nD=M\n@THAT\nM=D  // THAT= *(FRAME-1)\n";
  rSyntax += "@FRAME\nD=M\n@2\nD=D-A\nA=D\nD=M\n@THIS\nM=D  // THAT= *(FRAME-2)\n";
  rSyntax += "@FRAME\nD=M\n@3\nD=D-A\nA=D\nD=M\n@ARG\nM=D  // THAT= *(FRAME-3)\n";
  rSyntax += "@FRAME\nD=M\n@4\nD=D-A\nA=D\nD=M\n@LCL\nM=D  // THAT= *(FRAME-4)\n";
  rSyntax += "@RET\nA=M\n0;JMP\n";
  return rSyntax;
}

String functionSyntax(List<String> items) {
  String fSyntax = '(' + items[1] +')\n';
  for(var i = 0; i < int.parse(items[2]) ;i++) {
    fSyntax += "@SP\nA=M\nM=0\n@SP\nM=M+1\n";
  }
  return fSyntax;
}
