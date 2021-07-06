import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:funciona/models/CDP.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<CDP>> _listadoCDP;
  Future<List<CDP>> _getCDP() async {
    var url = Uri.parse("http://192.168.56.101:80/get_task");
    final response = await http.get(url);

    List<CDP> list_cdp = [];
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);
      for (var item in jsonData) {
        list_cdp.add(CDP(item["description"], item["title"], item["idp"]));
      }
      return list_cdp;
    } else {
      throw Exception("Falló la conexión");
    }
  }

  Widget palabra_put(controlador) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
          hintText: "Ingrese",
          fillColor: Colors.black26,
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  //Inicio de post
  String v_titulo = '';
  String v_descripcion = '';
  final f_titulo = TextEditingController();
  final f_descripcion = TextEditingController();
  final put_titulo = TextEditingController();
  final put_descripcion = TextEditingController();

  Widget para_titulo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: f_titulo,
        decoration: InputDecoration(
          hintText: "Palabra",
          fillColor: Colors.blueGrey[600],
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget para_descripcion() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: f_descripcion,
        decoration: InputDecoration(
          hintText: "Descripcion",
          fillColor: Colors.blueGrey[600],
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget enviar() {
    return FlatButton(
        shape: StadiumBorder(),
        color: Colors.blueGrey[600],
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        onPressed: () {
          v_titulo = f_titulo.text;
          v_descripcion = f_descripcion.text;
          print(v_titulo);
          print(v_descripcion);
          ingresar(v_titulo, v_descripcion);
        },
        child: Text(
          "Agregar palabra",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ));
  }

  void ingresar(nombre, descripcion) async {
    var url = Uri.parse("http://192.168.56.101:80/create_task");

    var response = await http.post(url,
        headers: {
          "content-type": "application/json",
        },
        body: jsonEncode({
          "title": nombre,
          "description": descripcion,
        }));
  }
  //hasta aqui llega post

  //Inicio de put
  void modificar(ide, nombre, descripcion) async {
    var url = Uri.parse("http://192.168.56.101:80/tasks/$ide");
    final http.Response response = await http.put(url,
        headers: {
          "content-type": "application/json",
        },
        body: jsonEncode({
          "title": nombre,
          "description": descripcion,
        }));
  }

  Widget boton_put(descripcion, nombre, idp) {
    return RaisedButton(
        shape: StadiumBorder(),
        color: Colors.blueGrey[600],
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        onPressed: () {
          String idp1 = idp.toString();
          modificar(idp1, nombre, descripcion);
        },
        child: Text(
          "Actualizar",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ));
  }
  //Hasta aqui llega put

  //Inicio de delete
  void eliminar(String ide) async {
    var url = Uri.parse("http://192.168.56.101:80/tasks/$ide");
    final http.Response response = await http.delete(url);
  }

  Widget boton_delete(idp) {
    return RaisedButton(
        shape: StadiumBorder(),
        color: Colors.blueGrey[600],
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        onPressed: () {
          String idp1 = idp.toString();
          eliminar(idp1);
        },
        child: Text(
          "Eliminar",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ));
  }
  //Hasta aqui lleha delete

  @override
  void initState() {
    super.initState();
    _listadoCDP = _getCDP();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Claudia App',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Claudia App'),
            ),
            body: FutureBuilder(
                future: _listadoCDP,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //print(snapshot.data);
                    return ListView(
                      children: _listWidget(snapshot.data),
                    );
                  } else if (snapshot.hasError) {
                    //print(snapshot.error);
                    return Text("Error");
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                })));
  }

  List<Widget> _listWidget(List<CDP> data) {
    List<Widget> widgets = [];
    for (var i in data) {
      widgets.add(Card(
          child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(i.nombre + " : " + i.descripcion)),
          boton_put(put_descripcion, put_titulo, i.idp),
          boton_delete(i.idp),
        ],
      )));
    }
    widgets.add(para_titulo());
    widgets.add(para_descripcion());
    widgets.add(enviar());
    widgets.add(palabra_put(put_titulo));
    widgets.add(palabra_put(put_descripcion));
    //widgets.add();
    return widgets;
  }
}
