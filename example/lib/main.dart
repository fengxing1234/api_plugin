import 'package:api_plugin/dio/base_model/error_model.dart';
import 'package:api_plugin/dio/dio_manager.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:api_plugin/api_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ApiPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  String text = '1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              FlatButton(
                child: Text('get请求测试'),
                color: Colors.blue,
                onPressed: () {
                  print('11');
                  DioManager().request(DIOMethod.GET, 'wxarticle/chapters/json',
                      params: null, success: (data) {
                    print(data.toString());
                    text = data.toString();
                    setState(() {});
                  }, error: (message) {
                    print(message);
                  });
                },
              ),
              FlatButton(
                child: Text('post请求测试'),
                color: Colors.blue,
                onPressed: () {
                  DioManager().request(DIOMethod.POST, 'lg/collect/1165',
                      params: null, success: (data) {
                    print(data.toString());
                    text = data.toString();
                    if (data == null) text = '收藏成功';
                    setState(() {});
                  }, error: (message) {
                    print(message);
                    ErrorModel e = message;
                    text = e.message;
                    setState(() {});
                  });
                },
              ),
              FlatButton(
                child: Text('应用层地址请求测试'),
                color: Colors.blue,
                onPressed: () {
                  DioManager().request(DIOMethod.POST, 'taskListApi/selectTask',
                      params: {
                        "requestBody": {
                          "node_id": "500",
                          "riskcode": "D*",
                          "pageno": "1",
                          "pagesize": "20",
                          "state": "5"
                        }
                      }, success: (data) {
                    print(data.toString());
                    text = data.toString();
                    if (data == null) text = '请求成功';
                    setState(() {});
                  }, error: (message) {
                    print(message);
                    ErrorModel e = message;
                    text = e.message;
                    setState(() {});
                  });
                },
              ),
              FlatButton(
                child: Text('文件上传'),
                color: Colors.blue,
                onPressed: () {
                  DioManager().fileUpload();
                },
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
