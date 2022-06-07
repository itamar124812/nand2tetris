import 'symbol.dart';

class SymbolTable
{
  List<Symbol> Symbols=[];
  void addSymbol(Symbol a)
  {
    Symbols.add(a);
  }
  int varCount(category kind)
  {
    int i=0;
    for (var item in Symbols) {
      if(item.cat==kind) i++;
    }
    return i;
  }
  category? kindOf(String name)
  {
    for (var item in Symbols) {
      if(item.Name==name) return item.cat;
    }
  }
String? TypeOf(String name)
{
  for (var item in Symbols) {
      if(item.Name==name) return item.Type;
    }
}
int indexOf(String name)
{
for (var item in Symbols) {
      if(item.Name==name) return item.counter;
    }
    return -1;
}
}