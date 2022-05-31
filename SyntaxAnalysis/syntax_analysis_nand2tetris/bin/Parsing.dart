import 'dart:core';
import 'dart:ffi';
import 'package:stack/stack.dart';
import 'dart:io';
import 'Token.dart';

class Parsing{
    int index=0;
    bool funcParam = false,ifParam =false, whileParam = false;
    String fileString="";
    File outputFile;
    List<String>? fileLine;
    final Map<int,String> scoopMap = new Map();
    Stack<String> stack=Stack();
    void pushForStack()
    {
        String str=fileLine![index];
        var w=str.substring(str.indexOf('<')+1,str.indexOf('>')-1);
        switch (w) {
          case "keyword":
          case "symbol":
            w=str.substring(str.indexOf('>')+1,str.indexOf('<',str.indexOf('>')+1)-1);
            stack.push(w);
            break;
          default:
             stack.push(w);
        }
        index++;
    }
    void reduceVarDec()
    {
      
    }
    void reducetype()
    {
           String type=stack.pop();
           outputFile.writeAsString("<keyword>$type</keyword>");
           stack.push("type");    
    }

    Parsing(String path): outputFile=File(path.substring(0,path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first+ "popA.xml")
    {       
        var tokenizing=File(path);        
        outputFile.create(recursive: true).then((File outputFile) {});
       fileString = tokenizing.readAsStringSync();
       fileLine = tokenizing.readAsLinesSync();
    }
   void classGrammar(File tokenizing) {
     outputFile.writeAsString("<class>\n", mode: FileMode.append);
     

     
     }
   }
