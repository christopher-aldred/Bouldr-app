// ignore_for_file: prefer_const_constructors

import 'package:bouldr/models/section.dart';
import 'package:bouldr/widgets/painter_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

class AddRoute2 extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  final String name;
  final String description;
  final String grade;
  AddRoute2(this.venueId, this.areaId, this.sectionId, this.name,
      this.description, this.grade,
      {Key? key})
      : super(key: key);

  @override
  _AddRoute2State createState() => _AddRoute2State();
}

class _AddRoute2State extends State<AddRoute2> {
  Section section = Section('Loading...', '');

  static const Color red = Color(0xFFFF0000);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;

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
      }
    });

    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: FreeStyleSettings(
              enabled: false,
              color: red,
              strokeWidth: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  /// Fetches image from an [ImageProvider] (in this example, [NetworkImage])
  /// to use it as a background
  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image = await NetworkImage('https://picsum.photos/1920/1080/').image;

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Flutter Painter Example"),
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
                  ? Theme.of(context).accentColor
                  : null,
            ),
            onPressed: toggleFreeStyle,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.image,
        ),
        onPressed: renderAndDisplayImage,
      ),
      body: Column(
        children: [
          if (backgroundImage != null)
            // Enforces constraints
            AspectRatio(
              aspectRatio: backgroundImage!.width / backgroundImage!.height,
              child: FlutterPainter(
                controller: controller,
              ),
            ),
          if (controller.freeStyleSettings.enabled) ...[
            // Control free style stroke width
            Slider.adaptive(
                min: 3,
                max: 15,
                value: controller.freeStyleSettings.strokeWidth,
                onChanged: setFreeStyleStrokeWidth),

            // Control free style color hue
            Slider.adaptive(
                min: 0,
                max: 359.99,
                value:
                    HSVColor.fromColor(controller.freeStyleSettings.color).hue,
                activeColor: controller.freeStyleSettings.color,
                onChanged: setFreeStyleColor),
          ],
          if (textFocusNode.hasFocus) ...[
            // Control text font size
            Slider.adaptive(
                min: 12,
                max: 48,
                value: controller.textSettings.textStyle.fontSize ?? 14,
                onChanged: setTextFontSize),

            // Control text color hue
            Slider.adaptive(
                min: 0,
                max: 359.99,
                value: HSVColor.fromColor(
                        controller.textSettings.textStyle.color ?? red)
                    .hue,
                activeColor: controller.textSettings.textStyle.color,
                onChanged: setTextColor),
          ]
        ],
      ),
    );
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

  void renderAndDisplayImage() {
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());

    // Render the image
    // Returns a [ui.Image] object, convert to to byte data and then to Uint8List
    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    // From here, you can write the PNG image data a file or do whatever you want with it
    // For example:
    // ```dart
    // final file = File('${(await getTemporaryDirectory()).path}/img.png');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    // ```
    // I am going to display it using Image.memory

    // Show a dialog with the image
    showDialog(
        context: context,
        builder: (context) => RenderedImageDialog(imageFuture: imageFuture));
  }
}
