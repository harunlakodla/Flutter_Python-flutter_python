import 'package:flutter/material.dart';
import 'dart:async';
import 'package:starflut/starflut.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Python Console'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  StarSrvGroupClass srvGroup;
  String _outputString = "python 3.6";

  _MyHomePageState()
  {
    _initStarCore();
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _initStarCore() async{
    StarCoreFactory starcore = await Starflut.getFactory();
    StarServiceClass Service = await starcore.initSimple("test", "123", 0, 0, []);
    await starcore.regMsgCallBackP(
            (int serviceGroupID, int uMsg, Object wParam, Object lParam) async{
          if( uMsg == Starflut.MSG_DISPMSG || uMsg == Starflut.MSG_DISPLUAMSG ){
            ShowOutput(wParam);
          }
          print("$serviceGroupID  $uMsg   $wParam   $lParam");
          return null;
        });
    srvGroup = await Service["_ServiceGroup"];
    bool isAndroid = await Starflut.isAndroid();
    if( isAndroid == true ){
      String libraryDir = await Starflut.getNativeLibraryDir();
      String docPath = await Starflut.getDocumentPath();
      if( libraryDir.indexOf("arm64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-arm64.zip", docPath, true);
      }else if( libraryDir.indexOf("x86_64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-x86_64.zip", docPath, true);
      }else if( libraryDir.indexOf("arm") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-armeabi.zip", docPath, true);
      }else{  //x86
        Starflut.unzipFromAssets("lib-dynload-x86.zip", docPath, true);
      }
      await Starflut.copyFileFromAssets("python3.6.zip", "flutter_assets/starfiles",null);  //desRelatePath must be null
    }
    if( await srvGroup.initRaw("python36", Service) == true ){
      _outputString = "init starcore and python 3.6 successfully";
    }else{
      _outputString = "init starcore and python 3.6 failed";
    }

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //_counter++;
    });
  }

  void ShowOutput(String Info) async{
    if( Info == null || Info.length == 0)
      return;
    _outputString = _outputString + "\n" + Info;
    setState((){

    });
  }

  void runScriptCode() async{

    String data = await getFileData("starfiles/deneme.py");
    await srvGroup.runScript("python", data, null);

    setState((){

    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter and Python'),
        ),
        body: new Center(
          child: new Column(
              children: <Widget>[
          new RaisedButton(
            child: const Text('Connect Python'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: runScriptCode
          ),
          new Container(
            alignment: Alignment.topLeft,
            child : new Text(
              '$_outputString',
              style: new TextStyle(color:Colors.blue),
            ),
          ),
        ]
        ),
        ),
      ),
    );
  }
}

