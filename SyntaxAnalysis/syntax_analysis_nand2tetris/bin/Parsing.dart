import 'dart:core';
import 'dart:ffi';
import 'package:stack/stack.dart';
import 'dart:io';
import 'Token.dart';

class Parsing{
    int levelScope = 1;
    bool funcParam = false,ifParam =false, whileParam = false;
    String fileString="";
    var outputFile;
    List<String>? fileLine;
    final Map<int,String> scoopMap = new Map();
    Stack<String> stack=Stack();

    Parsing(String path)
    {       
        var tokenizing=File(path);        
        outputFile= File(path.substring(0,path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first+ "popA.xml");
        outputFile.create(recursive: true).then((File outputFile) {});
       fileString = tokenizing.readAsStringSync();
       fileLine = tokenizing.readAsLinesSync();
    }
   void classGrammar(File tokenizing) {
     outputFile.writeAsString("<class>\n", mode: FileMode.append);

     String nextcommend;
     switch(nextcommend){

     }
   }
}