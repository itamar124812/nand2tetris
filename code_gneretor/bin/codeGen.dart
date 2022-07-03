import 'dart:developer';
import 'dart:io';
import 'dart:math';


import 'Table.dart';
import 'symbol.dart';

class code_genretor {
  StringBuffer output=StringBuffer();
  SymbolTable symbolTable=SymbolTable();
  
  int index = 0;
  String _filename = "";
  String _className = "";
  int varlibels = 0, staticVar = 0;
  List<String> inputFile=[];
  String stringinput="";
  
  code_genretor(String path)
  {
    var outputFile = File(
    path.substring(0, path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first + ".vm");
    inputFile = File(path).readAsLinesSync();
    firstclass();
    stringinput = File(path).readAsStringSync();
    outputFile.create(recursive: true).then((File outputFile) {});
    _filename = path.split("\\").last.split(".").first;
    classf();
  }
String getTok(int index)
{
  if(index>=0&&index<inputFile.length)
  {
    String str= inputFile[index];
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
    String str = inputFile[index];
    
    var w="";
    RegExp c=RegExp("<([a-zA-Z0-9]*)> [a-zA-Z0-9\,\.\*]* <\/([a-zA-Z0-9]*)>");
    if(c.hasMatch(str.trim()))
    {
      str=str.trim();
      int strindex= str.trim().indexOf('>');
       w = str.trim().substring(
        strindex + 2, str.indexOf('<',strindex + 1) - 1);
    }
    else if(RegExp(r"^<\w*>$").hasMatch(str.trim()))
    {
        str=str.trim();
        w=str.substring(str.indexOf("<"),str.indexOf(">"));
    }
    else if(str.contains("<\w*> \w*"))
    {
    w = str.substring(
        str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    }  
    return w;
  }

  int findClassVarDec() {
    int temp = index;
   while(temp < inputFile.length)
   {
     if(inputFile[temp].contains("<classVarDec>")){
       return ++temp;
     }
     else{
        temp +=1;
     }
   }
    return -1;
  }

  int findToken(String token,[int end=1000000]) {
    int temp = index;
  if(stringinput.contains(token,temp))
   {
      temp=inputFile.indexWhere((String str)=>str.trim().startsWith(token),temp);
      if(temp>=end) return -1;
      return temp;
   }
    return -1;
  }

 void classf() {
   index += 2;
   _className = currentTok();
   if (_className != "Main") output.writeln("function $_className.new 0");
     while (findClassVarDec() != -1) {
       index = findClassVarDec();
       String ForS = currentTok();
       index++;
       String type = currentTok();
       index++;
       if (ForS == "field") {
         symbolTable.addSymbol(
             Symbol(currentTok(), type, category.field, varlibels++));
       }
       else{
         symbolTable.addSymbol(
             Symbol(currentTok(), type, category.field, staticVar++));
       }
       index++;
       while (currentTok() == ",") {
         index++;
         if (ForS == "field") {
           symbolTable.addSymbol(
               Symbol(currentTok(), type, category.field, varlibels++));
         }
         else{
           symbolTable.addSymbol(
               Symbol(currentTok(), type, category.field, staticVar++));
         }
         index++;
       }
       index++;
     }

     while (findToken("<subroutineDec>") != -1) {
       {
         int varcount = 0;
         var pushThis;
         SymbolTable subroutineTable = SymbolTable();
         index = findToken("<subroutineDec>");
         index = findToken("<keyword>", index++);
         String funcName = getTok(index + 2);
         if (currentTok() == "method") {
           pushThis = "push argument 0 \npop pointer 0\n";
           subroutineTable.addSymbol(
               Symbol("this", _className, category.argument, 0));
         }
          else if (currentTok() == "constructor") {
            funcName="new";
          }
         int finalindex = findToken("</subroutineDec>");
         if (findToken("<parameterList>", finalindex) != -1) {
           index = findToken("<parameterList>", finalindex);
           if (findToken("</parameterList>") != index + 1) {
             do {
               index++;
               subroutineTable.addSymbol(Symbol(
                   getTok(index + 1), currentTok(), category.argument,
                   varcount++));
               index += 2;
             } while (currentTok() == ",");
           }
         }
         while (findToken("<varDec>", finalindex) != -1) {
           index = findToken("<varDec>");
           String _type = getTok(index + 2);
           subroutineTable.addSymbol(
               Symbol(getTok(index + 3), _type, category.local, ++varcount));
           index += 4;
           while (currentTok() == ",") {
             index++;
             subroutineTable.addSymbol(
                 Symbol(getTok(index), _type, category.local, ++varcount));
             index++;
           }
         }
         output.writeln("function $_className.$funcName $varcount");
         output.write(pushThis);
       }
     }

 }
void Statements(SymbolTable SRTable,int funcType)
{
  int finalIndex=findToken("</statements>");
  while(index<finalIndex)
  {
  switch(getTok(index))
  {
    case "letStatement":{
      int  classindex=symbolTable.indexOf(getTok(index+2));
      int funcindex=SRTable.indexOf(getTok(index+2));
      String popSome="";
      String type=SRTable.TypeOf(getTok(index+2))??"";
      if(funcindex!=-1)
      {       
        index+=3;
        if(currentTok()=="<symbol> [ </symbol>"){ 
          expression();
          output.writeln("push $type $funcindex\nadd \n");
          popSome="pop temp 0\npop pointer 1\npush temp 0\n push that 0\n";
          index=findToken("<symbol> ] </symbol>");
        }
        else    
        {
          popSome="pop "+type+" $funcindex";
        }
        expression();
        output.write(popSome);
             }
      else if(classindex!=-1)
      {
         
      }
      else
      {

      }
      output.writeln(popSome);
break;
    }
    case "returnStatement":
    {
      if(getTok(index+2)!=";")
      {
        expression();
      }
      output.writeln("return");
      break;
    }
    case "doStatement":
    {
      index+=2;
      String funcName=getTok(index);
      int finalindex=findToken("</doStatement>");
      index+=2;
      int argumentesNum=0;
      if(findToken("<expressionList>",finalindex)!=-1)
      {
        index=findToken("<expressionList>",finalindex);
        index+=2;
        while(currentTok()!=")")
        {
          expression();
          index++;
          argumentesNum++;
        }
      }
      output.writeln("call $_className.$funcName $argumentesNum");
      output.writeln("pop temp 0");
      index=finalindex;
      break;
    }
    case "ifStatement":
    {
      
      break;
    }
    case "whileStatement":
    {
      break;
    }
  }
  }
}
void expression()
{
  switch(getTok(index))
  {
    case "term":
    {
      index++;
      break;
    }
    case "unaryOp":
    {
      index++;
      expression();
      break;
    }
    case "op":
    {
      index++;
      expression();
      expression();
      break;
    }
    case "expression":
    {
      index++;
      break;
    }
  }
}


  void firstclass() {
    int i = 0;
    bool flag = true;
    while(flag){
      if (i >= inputFile.length) flag = false;
      else if(inputFile[i].contains("<class>")){
        flag = false;
        index = i;
      }
      else{
        i +=1;
      }
    }
  }

  }

