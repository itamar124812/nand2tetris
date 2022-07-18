import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'Table.dart';
import 'symbol.dart';

class code_genretor {
  StringBuffer output = StringBuffer();
  SymbolTable symbolTable = SymbolTable();

  int index = 0;
  int iflabel = -1;
  int whilelabel = -1;
  String _filename = "";
  String _className = "";
  int varlibels = 0, staticVar = 0;
  List<String> inputFile = [];
  String stringinput = "";
  

  code_genretor(String path) {
    var outputFile = File(path.substring(0, path.lastIndexOf(r"\")) +
        r"\" +
        path.split("\\").last.split(".").first +
        ".vm");
    inputFile = File(path).readAsLinesSync();
    firstclass();
    stringinput = File(path).readAsStringSync();
    outputFile.create(recursive: true).then((File outputFile) {});
    _filename = path.split("\\").last.split(".").first;
    classf();
   outputFile.writeAsStringSync(output.toString());
  }
  String getTok(int index) {
    if (index >= 0 && index < inputFile.length) {
      String str = inputFile[index];
      try {
        var w = str.substring(
            str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
        return w;
      } catch (e) {
        return "";
      }
    } else {
      return "";
    }
  }

  String currentTok() {
    String str = inputFile[index];

    var w = "";
    RegExp c =
        RegExp("<([a-zA-Z0-9]*)> [a-zA-Z0-9\,\.\*\)\(]* <\/([a-zA-Z0-9]*)>");
    if (c.hasMatch(str.trim())) {
      str = str.trim();
      int strindex = str.trim().indexOf('>');
      w = str
          .trim()
          .substring(strindex + 2, str.indexOf('<', strindex + 1) - 1);
    } else if (RegExp(r"^<\w*>$").hasMatch(str.trim())) {
      str = str.trim();
      w = str.substring(str.indexOf("<") + 1, str.indexOf(">"));
    } else if (str.contains("<\w*> \w*")) {
      w = str.substring(
          str.indexOf('>') + 2, str.indexOf('<', str.indexOf('>') + 1) - 1);
    }
    return w;
  }

  int findClassVarDec() {
    int temp = index;
    while (temp < inputFile.length) {
      if (inputFile[temp].contains("<classVarDec>")) {
        return ++temp;
      } else {
        temp += 1;
      }
    }
    return -1;
  }

  String getAngelBarCon(int Index) {
    String str = inputFile[Index].trim();
    if (!str.contains(">") ||
        !str.contains("<") ||
        str.indexOf(">") < str.indexOf("<")) {
      return "";
    }
    return str.substring(str.indexOf("<") + 1, str.indexOf(">"));
  }

  int findToken(String token, [int end = 1000000]) {
    int temp = index;
    if (stringinput.contains(token, temp)) {
      temp = inputFile.indexWhere(
          (String str) => str.trim().startsWith(token), temp);
      if (temp >= end) return -1;
      return temp;
    }
    return -1;
  }

  int findScope(String token, [int end = 1000000]) {
    int temp = index;
    int temp1 = 0;
    while (temp <= end) {
      if (inputFile[temp].contains("<$token>")) {
        temp1++;
      }
      if (inputFile[temp].contains("</$token>")) {
        if (temp1 == 0)
          return temp;
        else
          temp1--;
      }
      temp++;
    }
    return -1;
  }

  void classf() {
    index += 2;

    _className = currentTok();
    while (findClassVarDec() != -1) {
      index = findClassVarDec();
      String ForS = currentTok();
      index++;
      String type = currentTok();
      index++;
      if (ForS == "field") {
        symbolTable
            .addSymbol(Symbol(currentTok(), type, category.field, varlibels++));
      } else {
        symbolTable.addSymbol(
            Symbol(currentTok(), type, category.static, staticVar++));
      }
      index++;
      while (currentTok() == ",") {
        index++;
        if (ForS == "field") {
          symbolTable.addSymbol(
              Symbol(currentTok(), type, category.field, varlibels++));
        } else {
          symbolTable.addSymbol(
              Symbol(currentTok(), type, category.static, staticVar++));
        }
        index++;
      }
      index++;
    }

    while (findToken("<subroutineDec>") != -1) {
      {
        String funcType = "";
        int varcount = 0, varcount1 = 0;
        var pushThis;
        SymbolTable subroutineTable = SymbolTable();
        index = findToken("<subroutineDec>");
        String funcName = getTok(index + 3);
        index++;
        if (currentTok() == "method") {
          funcType = "method";
          pushThis = "push argument 0 \npop pointer 0\n";
          subroutineTable
              .addSymbol(Symbol("this", _className, category.argument, 0));
        } else if (currentTok() == "constructor") {
          funcType = "constructor";
          funcName = "new";
        } else {
          funcType = "function";
        }
        int finalindex = findToken("</subroutineDec>");
        if (findToken("<parameterList>", finalindex) != -1) {
          index = findToken("<parameterList>", finalindex);
          if (findToken("</parameterList>") != index + 1) {
            do {
              index++;
              subroutineTable.addSymbol(Symbol(getTok(index + 1), currentTok(),
                  category.argument, varcount++));
              index += 2;
            } while (currentTok() == ",");
          }
        }
        while (findToken("<varDec>", finalindex) != -1) {
          index = findToken("<varDec>");
          String _type = getTok(index + 2);
          subroutineTable.addSymbol(
              Symbol(getTok(index + 3), _type, category.local, varcount1++));
          index += 4;
          while (currentTok() == ",") {
            index++;
            subroutineTable.addSymbol(
                Symbol(getTok(index), _type, category.local, varcount1++));
            index++;
          }
        }
        output.writeln("function $_className.$funcName $varcount1");
        if (funcType == "constructor") {
          output.writeln(
              "push constant $varlibels \ncall Memory.alloc 1 \npop pointer 0");
        }
        if (pushThis != null) output.write(pushThis);
        index = findToken("<statements>", finalindex) + 1;

        Statements(subroutineTable, funcType);
      }
    }
    print(output.toString());
  }

  void Statements(SymbolTable SRTable, String funcType) {
    int finalIndex = findScope("statements");
    while (index < finalIndex) {
      switch (currentTok()) {
        case "letStatement":
          {
            index++;
            int endScope = findScope("letStatement");
            int classindex = symbolTable.indexOf(getTok(index + 1));
            int funcindex = SRTable.indexOf(getTok(index + 1));
            String popSome = "";
            String type =
                SRTable.kindOf(getTok(index + 1)).toString().split('.').last;
            if (funcindex != -1) {
              index += 2;
              if (getTok(index) == "[") {
                index = findToken("<expression>") + 1;
                expression(SRTable);
                output.write("push $type $funcindex\nadd \n");
                popSome =
                    "pop temp 0\npop pointer 1\npush temp 0\npop that 0\n";
                index = findToken("<symbol> ] </symbol>");
              } else {
                popSome = "pop " + type + " $funcindex\n";
              }
              index = findToken("<expression>") + 1;
              expression(SRTable);
              output.write(popSome);
            } else if (classindex > -1) {
              type = symbolTable
                  .kindOf(getTok(index + 1))
                  .toString()
                  .split('.')
                  .last;
              index += 2;
              if (getTok(index) == "[") {
                expression(SRTable);
                output.writeln("push this $classindex\nadd\n");
                popSome =
                    "pop temp 0 \npop pointer 1 \npush temp 0 \npop that 0\n";
                index = findToken("<symbol> ] </symbol>");
              } else {
                if (type != "static") {
                  popSome = "pop " + "this" + " $classindex";
                } else {
                  popSome = "pop " + "static" + " $classindex";
                }
              }
              index += 2;
              expression(SRTable);
              output.writeln(popSome);
            } else {}
            index = endScope + 1;
            break;
          }
        case "returnStatement":
          {
            index++;
            int finalScope = findScope("returnStatement");
            if (getTok(index + 1) != ";") {
              index = findToken("<expression>") + 1;
              expression(SRTable);
            } else {
              output.writeln("push constant 0");
            }
            output.writeln("return");
            index = finalScope + 1;
            break;
          }
        case "doStatement":
          {
            index += 2;
            int finalindex = findScope("doStatement");
            index = findToken("<subroutineCall>") + 1;
            SubrotineCall(SRTable);
            output.writeln("pop temp 0");
            index = finalindex + 1;
            break;
          }
        case "ifStatement":
          {
            int temp=++iflabel;
            index++;
            int finalScope =
                findScope("ifStatement"); //find the end of if statement
            String elseCase = "";
            index = findToken("<expression>") + 1;
            expression(SRTable);
            output.writeln(
                "if-goto IF_TRUE$temp\ngoto IF_FALSE$temp\nlabel IF_TRUE$temp");
            index = findToken("<statements>") + 1;
            int endScope = findScope("statements") + 1;
            if (getTok(endScope + 1) == "else") {
              endScope = endScope += 2;
              elseCase = "Raz&Itamar Kings";
            }
            Statements(SRTable, funcType);
            output.writeln("goto IF_END$temp\nlabel IF_FALSE$temp");
            if (elseCase != "") {
              index = endScope;
              index = findToken("<statements>") + 1;
              Statements(SRTable, funcType);
            }
            output.writeln("label IF_END$temp");
            index = finalScope+1;
            break;
          }
        case "whileStatement":
          { 
            index++;
            int temp=++whilelabel;
            int finalScope =
                findScope("whileStatement"); //find the end of while statement
            output.writeln("label WHILE_EXP$temp");
            index = findToken("<expression>") + 1;
            expression(SRTable);
            output.writeln("not");
            output.writeln("if-goto WHILE_END$temp");
            index = findToken("<statements>") + 1;
            Statements(SRTable, funcType);
            output.writeln("goto WHILE_EXP$temp");
            output.writeln("label WHILE_END$temp");
            index = finalScope+1;
            break;
          }
      }
    }
  }

  void expression(SymbolTable SRTable) {
    String term=getAngelBarCon(index);
    switch (getAngelBarCon(index)) {
      case "term":
        {
         index++;
          int finalindex = findScope("term");
           switch (getAngelBarCon(index)) {
            case "integerConstant":
              output.writeln("push constant " + getTok(index));
              break;
            case "stringConstant":
              {
                String content = getTok(index);
                output.writeln("push constant " + content.length.toString());
                output.writeln("call String.new 1");
                for (int i = 0; i < content.length; i++) {
                  output.writeln(
                      "push constant " + content.codeUnitAt(i).toString());
                  output.writeln("call String.appendChar 2");
                }
                break;
              }
            case "keyword":
              {
                if (currentTok() == "this") {
                  output.writeln("push pointer 0");
                } else if (currentTok() == "null") {
                  output.writeln("push constant 0");
                } else if (currentTok() == "true") {
                  output.writeln("push constant 0");
                  output.writeln("not");
                } else if (currentTok() == "false") {
                  output.writeln("push constant 0");
                } else {
                  output.writeln("push constant 0");
                }
                break;
              }
            case "symbol":
              {
                if (currentTok() == "(") {
                  index++;
                  index = findToken("<expression>") + 1;
                  expression(SRTable);
                  index = findToken("<symbol> )") + 1;
                }
                switch (getTok(index)) {
                  case "-":
                    {
                      index = findToken("<term>");
                      expression(SRTable);                  
                        output.writeln("neg");                    
                      break;
                    }

                  case "~":
                    {                  
                      index = findToken("<term>");
                      expression(SRTable); 
                      output.writeln("not");         
                      break;
                    }
                }
                break;
              }
              case "subroutineCall":
              {
                index++;
                SubrotineCall(SRTable);
                break;
              }
            case "identifier":
              {
                int classindex = symbolTable.indexOf(getTok(index));
                int funcindex = SRTable.indexOf(getTok(index));
                String type =
                    SRTable.kindOf(getTok(index)).toString().split('.').last;
                String popSome = "";
                if (funcindex > -1) {
                  index++;
                  if (getTok(index) == "[") {
                    index = findToken("<expression>") + 1;
                    expression(SRTable);
                    output.writeln("push $type $funcindex\nadd");
                    popSome = "pop pointer 1\npush that 0\n";
                    index = findToken("<symbol> ] </symbol>");
                  } else {
                    popSome = "push " + type + " $funcindex\n";
                  }
                  output.write(popSome);
                } else if (classindex > -1) {
                  type = symbolTable
                      .kindOf(getTok(index))
                      .toString()
                      .split('.')
                      .last;
                  index += 1;
                  if (getTok(index) == "[") {
                    expression(SRTable);
                    output.writeln("push this $classindex\nadd \n");
                    popSome =
                        "pop temp 0\npop pointer 1\npush temp 0\n push that 0\n";
                    index = findToken("<symbol> ] </symbol>");
                  } else {
                    if (type != "static") {
                      popSome = "push " + "this" + " $classindex";
                    } else {
                      popSome = "push " + "static" + " $classindex";
                    }
                    output.writeln(popSome);
                  }
                } else {
                  SubrotineCall(SRTable);
                }
                break;
              }
            default:
          }
          index++;
          if (RegExp(r"^(\/|\+|-|\||\*|\&amp;|\&lt;|\&gt;|=)$").hasMatch(getTok(index))) {
            int temp = index;
            index++;
            expression(SRTable);
            index = temp;
            expression(SRTable);
            index += 2;
            index = findScope("term");
            break;
          }
          index = finalindex;
          break;
        }
      case "symbol":
        {
          switch (getTok(index)) {
            case "+":
              {
                output.writeln("add");
                index++;
                break;
              }
            case "(":
              {
                index++;
                expression(SRTable);
                index = findToken(")") + 1;
                break;
              }
            case "-":
              {
                index++;
                if (currentTok() == "term") {
                  output.writeln("sub");
                } else {
                  output.writeln("not");
                }
                break;
              }
            case "*":
              {
                output.writeln("call Math.multiply 2");
                index++;
                break;
              }
            case "|":
              {
                output.writeln("or");
                index++;
                break;
              }
            case "&amp;":
              {
                output.writeln("and");
                index++;
                break;
              }
            case "/":
              {
                output.writeln("call Math.divide 2");
                index++;
                break;
              }
            case "&gt;":
              {
                output.writeln("gt");
                index++;
                break;
              }
            case "&lt;":
              {
                output.writeln("lt");
                index++;
                break;
              }
            case "=":
              {
                output.writeln("eq");
                index++;
                break;
              }
            case "~":
              {
                output.writeln("neg");
                index++;
                break;
              }
          }
          break;
        }

      case "expression":
        {
          index++;
          break;
        }
    }
  }

  void SubrotineCall(SymbolTable SRTable) {
    
    String funcname = currentTok();
    String classname = "";
    index++;
    int temp = index;
    int argumentesNum = 0;
    if (currentTok() == ".") index += 2;
    index=findToken("<expressionList>");
    if (findToken("</expressionList>") != index+1) {
      do {
        index=findToken("<expression>")+1;
        expression(SRTable);
        index+=2;
        argumentesNum++;
      } while (currentTok() == ",");
    }
    index = temp;
    if (currentTok() == ".") {
      classname = funcname;
      index++;
      funcname = currentTok();
      if (symbolTable.indexOf(classname) > -1) {      
        output.writeln("push this "+symbolTable.indexOf(classname).toString());
        argumentesNum++;
         classname = symbolTable.TypeOf(classname) ?? "";
      } else if (SRTable.indexOf(classname) > -1) {
        output.writeln("push local "+SRTable.indexOf(classname).toString());
        argumentesNum++;
        classname = SRTable.TypeOf(classname) ?? "";
      }
      output.writeln("call $classname.$funcname $argumentesNum");
    } else {
      output.writeln("push pointer 0");
      argumentesNum++;
      output.writeln("call $_className.$funcname $argumentesNum");
    }
  }

  void firstclass() {
    int i = 0;
    bool flag = true;
    while (flag) {
      if (i >= inputFile.length)
        flag = false;
      else if (inputFile[i].contains("<class>")) {
        flag = false;
        index = i;
      } else {
        i += 1;
      }
    }
  }
}
