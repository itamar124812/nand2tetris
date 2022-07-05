enum category
{
  static,field,argument,local

}
class Symbol
{
  String Name;
  String Type;
  category cat;
  int counter;
  Symbol(String _name,String _type,category _cat,int _counter ):Name=_name, Type=_type,cat=_cat,counter=_counter
  {

  }
}