// ignore_for_file: prefer_const_constructors

import 'package:bouldr/models/grade.dart';
import 'package:bouldr/models/route.dart' as route;
import 'package:bouldr/models/section.dart';
import 'package:bouldr/pages/area_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_painter/flutter_painter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AddRoute2 extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  final String name;
  final String description;
  final String grade;
  final Grade gradeconversion = Grade();

  AddRoute2(this.venueId, this.areaId, this.sectionId, this.name,
      this.description, this.grade,
      {Key? key})
      : super(key: key);

  @override
  _AddRoute2State createState() => _AddRoute2State();
}

class _AddRoute2State extends State<AddRoute2> {
  Section section = Section('Loading...', '');
  FirebaseStorage storage = FirebaseStorage.instance;
  DataRepository dr = DataRepository();

  static const Color red = Color(0xFFFF0000);
  static const Color yellow = Colors.yellow;
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;

  bool saving = false;

  late SharedPreferences prefs;

  Future<String> getGradingScale() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getString('gradingScale');
    return Future.value(defaultHomeTab);
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          section = Section.fromSnapshot(querySnapshot);
        });
        initBackground();
      }
    });

    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: yellow, fontSize: 18),
            ),
            freeStyle: FreeStyleSettings(
              enabled: false,
              color: yellow,
              strokeWidth: 3,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    toggleFreeStyle();
  }

  void initBackground() async {
    final image = await NetworkImage(section.imagePath.toString()).image;
    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getGradingScale(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text("Add route"),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.undo,
                  ),
                  onPressed: removeLastDrawable,
                ),
                IconButton(
                  icon: Icon(
                    Icons.gesture,
                    color: controller.freeStyleSettings.enabled
                        ? Colors.black
                        : null,
                  ),
                  onPressed: toggleFreeStyle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.zoom_in,
                    color: controller.freeStyleSettings.enabled != true
                        ? Colors.black
                        : null,
                  ),
                  onPressed: zoomScreen,
                )
              ],
            ),
            floatingActionButton: Visibility(
              visible: !saving,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: renderAndUpload,
                label: Text('Save'),
                icon: Icon(Icons.save),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Column(
                  children: [
                    if (backgroundImage != null)
                      // Enforces constraints
                      AspectRatio(
                          aspectRatio:
                              backgroundImage!.width / backgroundImage!.height,
                          child: InteractiveViewer(
                            panEnabled: true, // Set it to false
                            minScale: 1,
                            maxScale: 4,
                            child: FlutterPainter(
                              controller: controller,
                            ),
                          )),
                    Row(children: <Widget>[
                      Expanded(
                        child: Container(
                            margin:
                                const EdgeInsets.only(left: 10.0, right: 20.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                      Text("Line width", style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: Container(
                            margin:
                                const EdgeInsets.only(left: 20.0, right: 10.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                    ]),
                    // Control free style stroke width
                    Slider.adaptive(
                        min: 2,
                        max: 15,
                        value: controller.freeStyleSettings.strokeWidth,
                        onChanged: setFreeStyleStrokeWidth),

                    /*
            // Control free style color hue
            Slider.adaptive(
                min: 0,
                max: 359.99,
                value:
                    HSVColor.fromColor(controller.freeStyleSettings.color).hue,
                activeColor: controller.freeStyleSettings.color,
                onChanged: setFreeStyleColor),
                */

                    Row(children: <Widget>[
                      Expanded(
                        child: Container(
                            margin:
                                const EdgeInsets.only(left: 10.0, right: 20.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                      Text("Holds", style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: Container(
                            margin:
                                const EdgeInsets.only(left: 20.0, right: 10.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                    ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setFreeStyleColor(195);
                                    brushModeOn();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text('Start'))),
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setFreeStyleColor(60);
                                    brushModeOn();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.yellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text('Hand',
                                      style: TextStyle(color: Colors.black)))),
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setFreeStyleColor(345);
                                    brushModeOn();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text('Foot'))),
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setFreeStyleColor(105);
                                    brushModeOn();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text('Finish'))),
                        ]),
                    if (textFocusNode.hasFocus) ...[
                      // Control text font size
                      Slider.adaptive(
                          min: 12,
                          max: 48,
                          value:
                              controller.textSettings.textStyle.fontSize ?? 14,
                          onChanged: setTextFontSize),

                      // Control text color hue
                      Slider.adaptive(
                          min: 0,
                          max: 359.99,
                          value: HSVColor.fromColor(
                                  controller.textSettings.textStyle.color ??
                                      red)
                              .hue,
                          activeColor: controller.textSettings.textStyle.color,
                          onChanged: setTextColor),
                    ]
                  ],
                ),
                Visibility(
                    visible: saving,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.75),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.grey),
                        ),
                      ),
                    )),
              ],
            ),
          );
        });
  }

  void removeLastDrawable() {
    controller.removeLastDrawable();
  }

  void toggleFreeStyle() {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings = controller.freeStyleSettings
          .copyWith(enabled: !controller.freeStyleSettings.enabled);
    });
  }

  void addText() {
    if (controller.freeStyleSettings.enabled) toggleFreeStyle();
    controller.addText();
  }

  void zoomScreen() {
    if (controller.freeStyleSettings.enabled) toggleFreeStyle();
    //controller.addText();
  }

  void brushModeOn() {
    if (!controller.freeStyleSettings.enabled) toggleFreeStyle();
  }

  void setFreeStyleStrokeWidth(double value) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings =
          controller.freeStyleSettings.copyWith(strokeWidth: value);
    });
  }

  void setFreeStyleColor(double hue) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings = controller.freeStyleSettings.copyWith(
        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      );
    });
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle:
              controller.textSettings.textStyle.copyWith(fontSize: size));
    });
  }

  void setTextColor(double hue) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle: controller.textSettings.textStyle.copyWith(
        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      ));
    });
  }

  void uploadImage(route.Route newRoute) async {
    final backgroundImageSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());

    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    String filePath = "/images/" +
        widget.venueId +
        "/" +
        widget.sectionId +
        "/" +
        newRoute.referenceId.toString() +
        ".png";

    imageFuture.then((uint8List) async {
      try {
        var storageImage = FirebaseStorage.instance.ref().child(filePath);
        UploadTask task1 = storageImage.putData(uint8List!);

        Future<String> url = (await task1).ref.getDownloadURL();
        url.then((value) => {
              {newRoute.imagePath = value},
              dr.updateRoute(
                  widget.venueId, widget.areaId, widget.sectionId, newRoute),
              Navigator.of(context).pop(),
              Navigator.of(context).pop(),
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AreaPage(widget.venueId, widget.areaId),
                ),
              )
            });
      } on FirebaseException catch (error) {
        print(error);
      }
    });
  }

  Future<void> renderAndUpload() async {
    if (backgroundImage == null ||
        widget.name == "" ||
        AuthenticationHelper().user == null) return;

    setState(() {
      saving = true;
    });

    route.Route newRoute = route.Route(
        widget.name,
        widget.gradeconversion.getIndexByGrade(
            widget.grade, prefs.getString('gradingScale').toString()),
        AuthenticationHelper().user.uid,
        widget.description);

    Future<DocumentReference> response =
        dr.addRoute(widget.venueId, widget.areaId, widget.sectionId, newRoute);

    response.then((value) => {
          newRoute.referenceId = value.id,
          uploadImage(newRoute),
        });
  }
}
