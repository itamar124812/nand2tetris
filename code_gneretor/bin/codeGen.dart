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
  List<String> inputFile=[];
  String stringinput="";
  
  code_genretor(String path)
  {
    var outputFile = File(
    path.substring(0, path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first + ".vm");
    inputFile = File(path).readAsLinesSync();
    stringinput = File(path).readAsStringSync();
    outputFile.create(recursive: true).then((File outputFile) {});
    _filename = path.split("\\").last.split(".").first;
    classf();
  }
String getTok(int index)
{
  if(index>=0&&index<inputFile.length)
  {
    String str= inputFile![index];
    var w = str.substring(
        str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    return w;
  }
  else
  {
    return "";
  }
}
  String currentTok() {
    String str = inputFile![index];
    var w = str.substring(
        str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    return w;
  }

  int findClassVarDec() {
    int temp = index;
   while(stringinput.contains("<classVarDec>",temp))
   {
      temp=stringinput.indexOf("<classVarDec>",temp);
      return temp;
   }
    return -1;
  }
  int findToken(String token) {
    int temp = index;
  if(stringinput.contains(token,temp))
   {
      temp=inputFile.indexWhere((String str)=>str.trim().startsWith(token),temp);
      return temp;
   }
    return -1;
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
    if(findToken("<subroutineDec>")!=-1){
      {
        int varcount=0;
        SymbolTable subroutineTable=SymbolTable();
        index=findToken("<subroutineDec>");
        String funcName=getTok(index+3);
        while(findToken("<varDec>")!=-1){       
          index=findToken("<varDec>");
            String _type=getTok(index+2);
          subroutineTable.addSymbol(Symbol(getTok(index+3),_type,category.local,++varcount));
          index+=4;
          while(currentTok()==","){
            index++;
            subroutineTable.addSymbol(Symbol(getTok(index),_type,category.local,++varcount));
            index++;
          }        
       }
        output.writeln("function $_className.$funcName $varcount");
       
 }
    }
}
}
