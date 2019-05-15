import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'image2ascii/image2ascii.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image2Ascii',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String contents;
  MODE currentMode = MODE.simple;
  String pathImage;
  Image2Ascii image2ascii;
  double _textScaleFactor = 0.5;
  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('Image2Ascii'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: contents == null ? Container() : _getCodeView(context),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildDropdownButton(),
              SizedBox(
                width: 10,
              ),
              OutlineButton(
                onPressed: () async {
                  var file =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (file == null) return;
                  pathImage = file.path;
                  image2ascii = Image2Ascii(path: pathImage, mode: currentMode);
                  setState(() {
                    contents = image2ascii.getASCII();
                  });
                },
                child: Text('Select image'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildDropdownButton() {
    return Center(
      child: DropdownButton<MODE>(
        value: currentMode,
        items: MODE.values
            .map((mode) => DropdownMenuItem(
                child: Text(mode.toString().split('.')[1]), value: mode))
            .toList(),
        onChanged: (MODE value) async {
          currentMode = value;
          image2ascii.mode = currentMode;
          setState(() {
            contents = image2ascii.getASCII();
          });
        },
      ),
    );
  }

  Widget _getCodeView(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RichText(
                  textScaleFactor: this._textScaleFactor,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 3,
                      color: Colors.black,
                    ),
                    text: contents,
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.zoom_out),
              onPressed: () => setState(() {
                    this._textScaleFactor =
                        max(0.8, this._textScaleFactor - 0.1);
                  }),
            ),
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: () => setState(() {
                    this._textScaleFactor += 0.1;
                  }),
            ),
          ],
        ),
      ],
    );
  }
}
