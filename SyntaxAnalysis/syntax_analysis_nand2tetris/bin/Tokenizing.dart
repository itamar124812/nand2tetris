// ignore_for_file: unused_local_variable

import 'dart:io';

class Tokenizing{
  final _keyword=RegExp( r'(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)');
  final _symbol=RegExp(r'([{}()[\]\.,;+\-\*/&|<>=~])');
  final _integerConstant=RegExp("[0-9]+");
  final _identifier=RegExp("[A-Za-z_][A-Za-z0-9_]*");
  final _string=RegExp("\"([^\"]*)\"");
  final _symbolList=["(","[","{","}","\\","]","\"","/",".",",",";","+","-","*","&","|","<",">","=","~",")"];
  
  
 
  Tokenizing(String path)
  {
     var outputString=StringBuffer("<tokens>\n");
    var list=path.split(r"\");
    var fileNmae=list[list.length-1];
    var file=new File(path);
    var lines = removeAllComments(file.readAsStringSync()).split("\n");
    var j=1;
    for(var line in lines)
    { 
      if(line.trim().isNotEmpty){      
      var splited=line.split(" ");
      for (var item in splited) {
        item=item.trim();
       if(_keyword.hasMatch(item))
       outputString.writeln("<keyword> $item </keyword>");
       else if(_integerConstant.hasMatch(item))
         outputString.writeln("<integerConstant> $item </integerConstant>");
        else if(_string.hasMatch(item))
          outputString.writeln("<stringConstant>" + (_string.firstMatch(item)!.group(1) as String) + "</stringConstant>");
        else if(_symbol.hasMatch(item)){
        if(item=="<") item="&lt;";
        if(item==">") item="&gt;";
        if(item =="\"")item="&quot;";
        if(item=="&")item="&amp;";
        outputString.writeln("<symbol> $item </symbol>");
        }
        else if(_identifier.hasMatch(item))
        {
           outputString.writeln("<identifier> $item </identifier>");
        }
        else if(!item.isEmpty) 
        {
             outputString.writeln("<Error> $item </Error>");
        }        
      }
      }   
    }
outputString.writeln("</tokens>");
print(outputString);
  }
 
  String removeAllComments(String input)
  {
    var com1=RegExp(r"//([^\n]*)\n");
    var com2=RegExp(r"/\*(.*)\*/");  
    input= input.replaceAll(com1, "");
    input=input.replaceAll(com2, "");     
    input=input.replaceAll("  ", "");
    input=putSpaces(input);
    return input;
  }
String putSpaces(String input)
{
  var output=""; 
  for (var i = 0; i < input.length; i++) {
    if(_symbolList.contains(input[i]))
    {
      if(input[i-1]!=" ")
      {
             output+=" ";
      }
      output+=input[i];
      if(input[i+1]!=" "&&input[i+1]!="\n")
         output+=" ";
    }
    else{
    output+=input[i];
    }
  }
  return output;
}
}