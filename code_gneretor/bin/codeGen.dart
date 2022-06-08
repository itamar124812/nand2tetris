import 'dart:io';
import 'Table.dart';
import 'symbol.dart';

class code_genretor {
  StringBuffer output=StringBuffer();
  SymbolTable symbolTable=SymbolTable();
  int index=2;
  String _filename = "";
  String _className = "";
  int varlibels = 0;
   var inputFile;
  code_genretor(String path)
  {
    var outputFile = File(
    path.substring(0, path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first + ".vm");
    inputFile = File(path).readAsLinesSync();
    outputFile.create(recursive: true).then((File outputFile) {});
    classf();
  }

  String currentTok() {
    String str = inputFile![index];
    var w = str.substring(
        str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    return w;
  }

  int findClassVarDec() {
    int temp = index;
    while(!inputFile[temp].contains("<classVarDec>") || !inputFile[temp].contains("<subroutineDec>") || !inputFile[temp].contains("}") ) {
      temp++;
    }
    if(inputFile[temp].contains("<subroutineDec>") || inputFile[temp].contains("}")) {
      return -1;
    }
    return temp;
  }

 void classf()
 {
    _className=currentTok();
    index++;
    if(_className!="Main") output.writeln("function $_className.new 0");
    if(findClassVarDec() != -1){
      index = findClassVarDec();
      while(currentTok()=="static" || currentTok()=="field"){
          if(currentTok()=="field"){
            index++;
            String type = currentTok();
            index++;
            symbolTable.addSymbol(Symbol(currentTok(),type,category.field,varlibels++));
            while(currentTok()==","){
              index++;
              symbolTable.addSymbol(Symbol(currentTok(),type,category.field,varlibels++));
              index++;
            }
          }

          break;
        }

      }
 }
}
