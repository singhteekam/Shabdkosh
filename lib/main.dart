import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String url="https://owlbot.info/api/v4/dictionary/";
  String token="Your API token. To get token, search owlbot.info and Get a free token";
  TextEditingController controller=TextEditingController();

  StreamController _streamController;
  Stream _stream;
  Timer timer;

  @override
  void initState(){
    super.initState();
    _streamController=StreamController();
    _stream=_streamController.stream;
  }

  search() async{
    if(controller.text==null|| controller.text.length==0){
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response=await get(url + controller.text.trim(),headers:{"Authorization": "Token " + token});
    _streamController.add(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Shabdkosh"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Row(children: <Widget>[
            Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left:15,bottom:8),
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: TextFormField(
                    onChanged: (String text){
                      if(timer?.isActive??false){
                        timer.cancel();
                      }
                      timer= Timer(const Duration(milliseconds: 1000), (){
                        search();
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "search any word",
                      border: InputBorder.none
                    ),
              ),
                  ),
                ),
            ),
            IconButton(icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: (){
              search();
            },
            )
          ],),
        ),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.data==null){
            return Center(
              child:Text("Enter word")
            );
          }

        if(snapshot.data=="waiting"){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

          return ListView.builder(
            itemCount: snapshot.data["definitions"].length,
            itemBuilder: (BuildContext context,int index){
              return ListBody(
                children:<Widget>[
                  Container(
                    color:Colors.blue[300],
                    child:ListTile(
                      leading:snapshot.data["definitions"][index]["image_url"]==null?null:
                      CircleAvatar(backgroundImage:NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                      ),
                      title: Text(controller.text.trim()+ "(" + snapshot.data["definitions"][index]["type"]+ ")"),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(snapshot.data["definitions"][index]["definition"]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(snapshot.data["definitions"][index]["example"]),
                  ),
                  
                ]
              );
            }
          );
        },
      ),
      backgroundColor: Colors.blue[200],
    );
  }
}