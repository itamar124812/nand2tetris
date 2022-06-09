import 'dart:ffi';
import 'package:stack/stack.dart';
import 'dart:io';
import 'Token.dart';


class Parsing {
  int levelScope = 0;
  int index = 0;
  bool funcParam = false,
      ifParam = false,
      whileParam = false;
  //String fileString = "";
  List<String>? fileLine;
  List<String> tokens = [];
  var outputString = StringBuffer();

  Parsing(String path) {
    var outputFile = File(
        path.substring(0, path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first + "++.xml");
    var tokenizing = File(path);
    outputFile.create(recursive: true).then((File outputFile) {});
    //fileString = tokenizing.readAsStringSync();
    fileLine = tokenizing.readAsLinesSync();
    fileLine = classfunc(nextTok());
    var outfile = fileLine?.join();
    outputFile.writeAsString(outfile!, mode: FileMode.append);
  }

  String nextTok() {
    index += 1;
    String str = fileLine![index];
    var w = str.substring(
        str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    return w;
  }

  String copyline() {
    return addTabs(fileLine![index])+"\n";
  }

  String addTabs(String str){
    for(int i=0;i<levelScope;i++){
      str = "  " + str;
    }
    return str;
  }
  void classGrammar(File tokenizing) {


  }

  List<String> classfunc(String pattern) {
    switch (pattern) {
      case "class":
        {
          tokens.add(addTabs("<class>\n"));
          levelScope+=1;
          tokens.add(copyline());
          classfunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</class>\n"));
        }
        break;
      case "method":
      case "function":
      case "constructor":

        {
          tokens.add(addTabs("<subroutineDec>\n"));
          levelScope+=1;
          classfunction(pattern);
          levelScope-=1;
          tokens.add(addTabs(addTabs("</subroutineDec>\n")));
          classfunc(nextTok());
        }
        break;
      case "{":
        {
          tokens.add(copyline());
          classfunc(nextTok());
        }
        break;
      case "static":
      case "field":
        {
          tokens.add(addTabs("<classVarDec>\n"));
          levelScope+=1;
          classVarD(pattern);
          levelScope-=1;
          tokens.add(addTabs("</classVarDec>\n"));
          classfunc(nextTok());
        }
        break;
      case "}":
        {
          tokens.add(copyline());
        }
        break;
      default:
        {
          tokens.add(copyline());
          classfunc(nextTok());
        }
        break;
    }
    return tokens;
  }

  void classfunction(String pattern) {
    switch (pattern) {
      case "method":
      case "function":
      case "constructor":
        {
          tokens.add(copyline());
          classfunction(nextTok());
        }
        break;
      case "{":
        {
          tokens.add(addTabs("<subroutineBody>\n"));
          levelScope+=1;
          functionBody(pattern);
          levelScope-=1;
          tokens.add(addTabs("</subroutineBody>\n"));
        }
        break;
      case "(":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<parameterList>\n"));
          levelScope+=1;
          parmeterlistfunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</parameterList>\n"));
          tokens.add(copyline());
          classfunction(nextTok());
        }
        break;
      default:
        {
          tokens.add(copyline());
          classfunction(nextTok());
        }
        break;
    }
  }

  void classVarD(String pattern) {
    switch (pattern) {
      case "static":
      case "field":
        {
          tokens.add(copyline());
          classVarD(nextTok());
        }
        break;
      case ";":
        {
          tokens.add(copyline());
        }
        break;
      default:
        {
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          String temp = nextTok();
          while(temp == ","){
            tokens.add(copyline());
            nextTok();
            tokens.add(copyline());
            temp = nextTok();
          }
          classVarD(temp);
        }
        break;
    }
  }

  void parmeterlistfunc(String pattern) {
    switch (pattern) {
      case ")":
        {
        }
        break;
      default:
        {
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          String temp = nextTok();
          while(temp == ","){
            tokens.add(copyline());
            nextTok();
            tokens.add(copyline());
            nextTok();
            tokens.add(copyline());
            String temp = nextTok();
          }
        }
        break;
    }
  }

  void functionBody(String pattern) {
    switch (pattern) {
      case "{":
        {
          tokens.add(copyline());
          functionBody(nextTok());
        }
        break;
      case "if":
      case "while":
      case "let":
      case "do":
      case "return":
        {
          tokens.add(addTabs("<statements>\n"));
          levelScope +=1;
          statementsFunc(pattern);
          levelScope -=1;
          tokens.add(addTabs("</statements>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      case "var":
        {
          tokens.add(addTabs("<varDec>\n"));
          levelScope+=1;
          functionVar(pattern);
          levelScope-=1;
          tokens.add(addTabs("</varDec>\n"));
          functionBody(nextTok());
        }
        break;
      case "}":
        {
          tokens.add(copyline());
        }
        break;
      default:
        {
        }
        break;
    }
  }

  void functionVar(String pattern) {
    switch (pattern) {
      case "var":
        {
          tokens.add(copyline());
          functionVar(nextTok());
        }
        break;
      case ";":
        {
          tokens.add(copyline());
        }
        break;
      default:
        {
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          String temp = nextTok();
          while(temp == ","){
            tokens.add(copyline());
            nextTok();
            tokens.add(copyline());
            temp = nextTok();
          }
          functionVar(temp);
        }
        break;
    }
  }

  void statementsFunc(String pattern) {
    switch (pattern) {
      case "if":
        {
          tokens.add(addTabs("<ifStatement>\n"));
          levelScope+=1;
          ifStfunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</ifStatement>\n"));
          statementsFunc(nextTok());
        }
        break;
      case "let":
        {
          tokens.add(addTabs("<letStatement>\n"));
          levelScope+=1;
          letStfunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</letStatement>\n"));
          statementsFunc(nextTok());
        }
        break;
      case "while":
        {
          tokens.add(addTabs("<whileStatement>\n"));
          levelScope+=1;
          whileStfunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</whileStatement>\n"));
          statementsFunc(nextTok());
        }
        break;
      case "do":
        {
          tokens.add(addTabs("<doStatement>\n"));
          levelScope+=1;
          doStfunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</doStatement>\n"));
          statementsFunc(nextTok());
        }
        break;
      case "return":
        {
          tokens.add(addTabs("<returnStatement>\n"));
          levelScope+=1;
          returnStfunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</returnStatement>\n"));
          statementsFunc(nextTok());
        }
        break;
      default:
        {
          index-=1;
        }
        break;
    }
  }

  void ifStfunc(String pattern) {
    switch (pattern) {
      case "if":
        {
          tokens.add(copyline());
          ifStfunc(nextTok());
        }
        break;
      case "(":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
          ifStfunc(nextTok());
        }
        break;
      case "{":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<statements>\n"));
          levelScope+=1;
          statementsFunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</statements>\n"));
          nextTok();
          tokens.add(copyline());
          if(nextTok() == "else"){
            index-=1;
            ifStfunc(nextTok());
          }
          index-=1;
        }
        break;
      case "else":
        {
          tokens.add(copyline());
          ifStfunc(nextTok());
        }
        break;
      default:
        {
        }
        break;
    }
  }

  void letStfunc(String pattern) {
    switch (pattern) {
      case "let":
        {
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          letStfunc(nextTok());
        }
        break;
      case "[":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
          letStfunc(nextTok());
        }
        break;
      case "=":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      default:
        {
        }
        break;
    }
  }

  void whileStfunc(String pattern) {
    switch (pattern) {
      case "while":
        {
          tokens.add(copyline());
          whileStfunc(nextTok());
        }
        break;
      case "(":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
          whileStfunc(nextTok());
        }
        break;
      case "{":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<statements>\n"));
          levelScope+=1;
          statementsFunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</statements>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      default:
        {
        }
        break;
    }
  }

  void doStfunc(String pattern) {
    switch (pattern) {
      case "do":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<subroutineCall>\n"));
          levelScope+=1;
          subroutineCallFunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</subroutineCall>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      default:{
      }
      break;
    }
  }

  void returnStfunc(String pattern) {
    switch (pattern) {
      case "return":
        {
          tokens.add(copyline());
          returnStfunc(nextTok());
        }
        break;
      case ";":
        {
          tokens.add(copyline());
        }
        break;
      default:{
        tokens.add(addTabs("<expression>\n"));
        levelScope+=1;
        expressionF(nextTok());
        levelScope-=1;
        tokens.add(addTabs("</expression>\n"));
        returnStfunc(nextTok());
      }
      break;
    }
  }

  void expressionF(String pattern) {
    switch (pattern) {
      default:
        {
          tokens.add(addTabs("<term>\n"));
          levelScope += 1;
          termFunc(pattern);
          levelScope -= 1;
          tokens.add(addTabs("</term>\n"));
          String temp = nextTok();
          while (temp == "+" || temp == "-" || temp == "*" || temp == "/" ||
              temp == "&amp;" || temp == "|" || temp == "&lt;" || temp == "&gt;" ||
              temp == "=") {
            tokens.add(copyline());
            tokens.add(addTabs("<term>\n"));
            levelScope += 1;
            termFunc(nextTok());
            levelScope -= 1;
            tokens.add(addTabs("</term>\n"));
            temp = nextTok();
          }
          index-=1;
        }
        break;
    }
  }

  void subroutineCallFunc(String pattern) {
    switch (pattern) {
      case "(":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expressionList>\n"));
          levelScope+=1;
          exprListFunc(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expressionList>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      case ".":
        {
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          subroutineCallFunc(nextTok());
        }
        break;
      default:{
        tokens.add(copyline());
        subroutineCallFunc(nextTok());
      }
      break;
    }
  }

  void termFunc(String pattern) {
    switch (pattern) {
      case "~":
      case "-":
        {
          tokens.add(copyline());
          termFunc(nextTok());
        }
        break;
      case "(":
        {
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
        }
        break;
      default:{
        String temp = nextTok();// . or ( "or ["
        if(temp == "["){
          index-=1;
          tokens.add(copyline());
          nextTok();
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          nextTok();
          tokens.add(copyline());
        }
        else if(temp == "." || temp == "("){
          index-=1;
          tokens.add(addTabs("<subroutineCall>\n"));
          levelScope+=1;
          subroutineCallFunc(pattern);
          levelScope-=1;
          tokens.add(addTabs("</subroutineCall>\n"));
        }
        else{
          index-=1;
          tokens.add(copyline());
        }
      }
      break;
    }
  }

  void exprListFunc(String pattern) {
    switch (pattern) {
      case ")":
        {
          index-=1;
        }
        break;
      default:{
        tokens.add(addTabs("<expression>\n"));
        levelScope+=1;
        expressionF(pattern);
        levelScope-=1;
        tokens.add(addTabs("</expression>\n"));
        String temp = nextTok();
        while(temp == ","){
          tokens.add(copyline());
          tokens.add(addTabs("<expression>\n"));
          levelScope+=1;
          expressionF(nextTok());
          levelScope-=1;
          tokens.add(addTabs("</expression>\n"));
          temp = nextTok();
        }
        index-=1;
      }
      break;
    }
  }
}

