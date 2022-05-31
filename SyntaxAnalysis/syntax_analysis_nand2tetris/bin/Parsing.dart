import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'Token.dart';

class Parsing{
    int levelScope = 1;
    bool funcParam = false;
    Parsing(String path)
    {

    }
    String classGrammar(File tokenizing)
    {
        var dir;
        var fileNaume;
        var outputFile= File(dir.path + r"\" + "popA.xml");
        outputFile.create(recursive: true).then((File outputFile) {});
       String fileString = tokenizing.readAsStringSync();
       List<String> fileLine = tokenizing.readAsLinesSync();
        outputFile.writeAsString("<class>\n", mode: FileMode.append);
        for(int i = 0;i < fileLine.length; i++){
           if(fileLine[i].contains('{')){
               outputFile.writeAsString(addTabs(fileLine[i]), mode: FileMode.append);
               handleOpen1(outputFile,fileLine[i+1]);
           }
           else if(fileLine[i].contains("(")){
               handleOpen2(outputFile,fileLine[i]);
           }
           else if(fileLine[i].contains("}")){
             handleClose1(outputFile,fileLine[i]);
             outputFile.writeAsString(addTabs(fileLine[i]), mode: FileMode.append);
           }
           else if(fileLine[i].contains(")")){
              handleClose2(outputFile, fileLine[i],fileLine[i+1]);
           }
           else if(fileLine[i].contains("")){

           }
           else{
               outputFile.writeAsString(addTabs(fileLine[i]), mode: FileMode.append);
           }
       }
        outputFile.writeAsString("<class\\>\n", mode: FileMode.append);
       exit(0);
    }

    String addTabs(String line){
        for(int i= 0; i<levelScope;i++){
            line = "  " + line;
        }
        return line;
    }

  void handleOpen1(File outputFile, String fileNextLine) {
      if(fileNextLine.contains("constructor") || fileNextLine.contains("function") || fileNextLine.contains("method")){
          outputFile.writeAsString(addTabs("<subroutineDec>\n"), mode: FileMode.append);
      }
      else if(fileNextLine.contains("static") || fileNextLine.contains("field")){
          outputFile.writeAsString(addTabs("<classVarDec>\n"), mode: FileMode.append);
      }
      levelScope++;
  }

  void handleClose1(File outputFile, String fileLine) {
      levelScope--;

      outputFile.writeAsString(addTabs(fileLine), mode: FileMode.append);
  }

  void handleOpen2(File outputFile, String fileLine) {
    outputFile.writeAsString(addTabs(fileLine), mode: FileMode.append);
    if(funcParam){
        outputFile.writeAsString(addTabs("<parameterList>\n"), mode: FileMode.append);
      }
      levelScope++;
  }

  void handleClose2(File outputFile, String fileLine, String fileLineNext) {
      levelScope--;
    outputFile.writeAsString(addTabs(fileLine), mode: FileMode.append);
      if(funcParam && fileLine.contains("}")) {
        funcParam = false;
        outputFile.writeAsString(
            addTabs("<parameterList\\>\n"), mode: FileMode.append);
      }
  }
    

}