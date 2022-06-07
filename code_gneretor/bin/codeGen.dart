import 'dart:io';

import 'Table.dart';

class code_genretor {
  StringBuffer output=StringBuffer();
  SymbolTable symbolTable=SymbolTable();
  int index=2;
  String _filename="";
  String _className="";
  int varlibels=0;
   var inputFile;
  code_genretor(String path)
  {
    var outputFile = File(
    path.substring(0, path.lastIndexOf(r"\")) + r"\" + path.split("\\").last.split(".").first + ".vm");
    inputFile = File(path).readAsLinesSync();
    outputFile.create(recursive: true).then((File outputFile) {});
    classf();
  }
  
 void classf()
 {
    _className=inputFile[index++];
    if(_className!="Main") output.writeln("function $_className.new 0"); 
    while(inputFile[imdex]==r"(field|static)"){        
        varlibels+=1;
        
        break;     
      }
      case "static":
      {
        
        
        break;
        }    
    case "function":
    {

    }
    case "constructor":

   {

   }
    }
 }
}