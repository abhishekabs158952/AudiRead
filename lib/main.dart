import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_text/pdf_text.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'AdiReader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts ftts= FlutterTts();

  PDFDoc _pdfDoc;
  String _text = "";

  int flag=0;
  int i=0;

  bool _buttonsEnabled = true;

  @override
  void initState() {
    super.initState();
  }
  
  final myController = TextEditingController();

  String text1="";

  int pgno=0;  

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  String text2="";
      

  @override
  Widget build(BuildContext context) {
    speak() async {
      print("yes");
      await ftts.speak(myController.text);
    }
    speak2() async {
      print("yes");
      await ftts.speak("hello i am abhishek here i go ");
      text2="";

      String ttsword="";
      for(;i<text1.length;){
        while(flag==0){
          continue;
        }
        for(;i<text1.length;i++){
          if(text1[i]==' '||text1[i]=='\n'){
            i++;
            break;
          }else{
            ttsword+=text1[i];
          }
        }
        await ftts.speak(ttsword);
      }
      i=0;

      /*for(int i=0;i<text1.length;i++){
        if(text1[i]=="\n"){
          text2+=" ";
        }else{
          text2+=text1[i];
        }
      }
      text2.replaceAll("\n", " ");
      print("...............................................................");
      print("here it start");
      print(text2);
      await ftts.speak(text2);*/
    }
    nevigate(){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondRoute()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: myController,
              ),
            ),
            Padding(
              child: RaisedButton(
                child: Text("Speak"),
                onPressed: () => speak(),
              ),
              padding: EdgeInsets.all(15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: FlatButton(
                  child: Text(
                      "Pick PDF document",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                    onPressed: _pickPDFText,
                    padding: EdgeInsets.all(5),
                  )
                ),
                Expanded(
                  flex: 3,
                  child: FlatButton(
                  child: Text(
                    "Read random page",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: _buttonsEnabled ? _readRandomPage : () {},
                  padding: EdgeInsets.all(5),
                  )
                ),
                Expanded(
                  flex: 3,
                  child: FlatButton(
                    child: Text(
                      "Read whole document",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                    onPressed: _buttonsEnabled ? _readWholeDoc : () {},
                    padding: EdgeInsets.all(5),
                  )
                ),    
              ]
            ),  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "Speak document",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: _buttonsEnabled ? _speakWholeDoc : () {},
                  padding: EdgeInsets.all(5),
                ),
                FlatButton(
                  child: Text(
                    "Speak",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: () => speak2(),
                  padding: EdgeInsets.all(5),
                ),
              ]
            ),
            /*Padding(
              child:FlatButton(
                  child: Text(
                    "nevigate",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: () => nevigate(),
                  padding: EdgeInsets.all(5),
                ), 
              padding: EdgeInsets.all(15),
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "Previous",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: _buttonsEnabled ? _next : () {},
                  padding: EdgeInsets.all(5),
                ),
                FlatButton(
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed:  _buttonsEnabled ? _prev : () {},
                  padding: EdgeInsets.all(5),
                ),
              ]
            ),
            Padding(
              child: Text(
                _pdfDoc == null
                    ? "Pick a new PDF document and wait for it to load..."
                    : "PDF document loaded, ${_pdfDoc.length} pages\n",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(15),
            ),
            Padding(
              child: Text(
                _text == "" ? "" : "Text:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(15),
            ),         
            Text(_text),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => speak2(),
        tooltip: 'Show me the value!',
        child: Icon(Icons.text_fields),
      ), 
    );
  }
  /// Picks a new PDF document from the device
  /// 
  
  Future _pickPDFText() async {

    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      File file = File(result.files.single.path);
      _pdfDoc = await PDFDoc.fromFile(file);
    }
    i=0;
    //File file = await FilePicker.getFile();
    
    setState(() {});
  }


  /// Reads a random page of the document
  Future _readRandomPage() async {
    if (_pdfDoc == null) {
      return;
    }
    i=0;
    setState(() {
      _buttonsEnabled = false;
    });

    String text =
        await _pdfDoc.pageAt(Random().nextInt(_pdfDoc.length) + 1).text;

    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }

  Future _next() async {
    if (_pdfDoc == null) {
      return;
    }
    if(pgno+1>=_pdfDoc.length){
      return;
    }
    i=0;
    setState(() {
      _buttonsEnabled = false;
    });

    pgno+=1;
    String text =
        await _pdfDoc.pageAt(pgno).text;
    text1=text;
    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }

  Future _prev() async {
    if (_pdfDoc == null) {
      return;
    }
    if(pgno-1<0){
      return;
    }
    i=0;
    setState(() {
      _buttonsEnabled = false;
    });
    pgno-=1;
    String text =
        await _pdfDoc.pageAt(pgno).text;
    text1=text;
    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }

  Future _speakWholeDoc() async{
    if (_pdfDoc == null) {
      return;
    }
    setState(() {
      _buttonsEnabled = false;
    });

    final FlutterTts ftts2= FlutterTts();
    print("yes");
    String text = await _pdfDoc.pageAt(pgno).text;
    print(text);
    String ttsword="";
    for(;i<text.length;){
      while(flag==0){
        continue;
      }
      for(;i<text.length;i++){
        if(text[i]==' '){
          i++;
          break;
        }else{
          ttsword+=text[i];
        }
      }
      await ftts2.speak(ttsword);
    }
    i=0;
    setState(() {
      _text = text;
      _buttonsEnabled = true;
      text1=_text;
    });
  }
  /// Reads the whole document
  Future _readWholeDoc() async {
    if (_pdfDoc == null) {
      return;
    }
    i=0;
    setState(() {
      _buttonsEnabled = false;
    });

    String text = await _pdfDoc.text;

    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }
}


class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}