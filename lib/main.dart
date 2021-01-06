import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

int scheck;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    scheck = 0;
    SharedPreferences.getInstance().then((value) {
      scheck = value.getInt('key') ?? 0;
      value.setInt('key', 1);
      Future.delayed(Duration(seconds: 2)).then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    scheck == 1 ? WebViewEx() : VideoApp()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 3,
        // navigateAfterSeconds: check == 1 ? WebViewEx() : VideoApp(),
        title: new Text(
          'Welcome In Doval Club',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset('images/splash.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 150.0,
        loaderColor: Colors.red);
  }
}

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('images/splashvideo.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.addListener(() {
            setState(() {
              if (_controller.value.duration == _controller.value.position) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => WebViewEx()));
              }
            });
          });
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          )
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class WebViewEx extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewEx> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  bool check;
  @override
  void initState() {
    super.initState();
    check = false;
    // Future.delayed(Duration(seconds: 5)).then((value) {
    //   setState(() {
    //     check = true;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SplashScreen(
          seconds: 20,
          title: new Text(
            'Welcome In Doval Club',
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          image: new Image.asset('images/splash.png'),
          backgroundColor: Colors.white,
          styleTextUnderTheLoader: new TextStyle(),
          photoSize: 150.0,
          loaderColor: Colors.red,
        ),
        Container(
          height: check ? 1000 : 30,
          padding: EdgeInsets.all(10.0), color: Colors.black,
          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: InAppWebView(
            initialUrl: 'https://dovalclub.com/',
            initialHeaders: {},
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                debuggingEnabled: true,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webView = controller;
            },
            onLoadStart: (InAppWebViewController controller, String url) {},
            onLoadStop: (InAppWebViewController controller, String url) async {
              setState(() {
                this.url = url;
                check = true;
              });
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {},
          ),
        ),
      ],
    );
  }
}
