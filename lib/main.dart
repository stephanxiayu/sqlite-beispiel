import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: SqLite(),
    );
  }
}

class SqLite extends StatefulWidget {
  SqLite({Key? key}) : super(key: key);

  @override
  State<SqLite> createState() => _SqLiteState();
}

class _SqLiteState extends State<SqLite> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(controller: textController),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: ()async {
        await DatabaseHelper.instance.add(Grocery(name: textController.text));setState(() {
          textController.clear();
        });
          }),
          body: Center(child: FutureBuilder<List<Grocery>>(future: DatabaseHelper.instance.getGroceries(),
          builder: (BuildContext context, AsyncSnapshot<List<Grocery>>snapshot){
            if(!snapshot.hasData){
              return const Center(child: Text('alter, ich warte....'),);
            }
            return ListView(
              children: snapshot.data!.map((grocery) {
                return Center(child:ListTile(title: Text(grocery.name)) ,);
              }).toList(),
            );
          },
          
          )),
    );
  }
}

class Grocery {
  final int? id;
  final String name;

  Grocery({this.id, required this.name});

  factory Grocery.fromMap(Map<String, dynamic> json) => Grocery(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}


class DatabaseHelper{

DatabaseHelper._privateConstructor();
static final DatabaseHelper instance=DatabaseHelper._privateConstructor();

static Database? _database;

Future<Database> get database async=>_database??=await _initDatabase();

Future<Database>_initDatabase()async{
  Directory documentsDirectory=await getApplicationDocumentsDirectory();
  String path =join(documentsDirectory.path, 'groceries.db');
  return await openDatabase(path, version: 1, onCreate: _onCreate,);
}

Future _onCreate(Database db,int version )async{
  await db.execute('''CREATE TABLE groceries(id INTEGER PRIMARY KEY, name TEXT)''');
}


Future<List<Grocery>>getGroceries()async{
  Database db=await instance.database;
  var groceries=await db.query('groceries', orderBy: 'name');
  List<Grocery> groceryList= groceries.isNotEmpty?groceries.map((c) => Grocery.fromMap(c)).toList():[];
  return groceryList;
}

 Future<int> add(Grocery grocery) async {
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }

 

}