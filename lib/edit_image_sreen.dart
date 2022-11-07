import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bulp_assignment/star_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

enum Mode {
  none,
  pencil,
  erase,
}

class EditImageScreen extends StatefulWidget {
  final File image;
  const EditImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  ui.Image? myImage;
  PainterController controller = PainterController();
  Mode mode = Mode.none;
  Color currentColor = const Color(0xff000000);
  @override
  void initState() {
    super.initState();
    setBackground();
  }

  void changeColor(Color color) {
    controller.freeStyleColor = color;
    setState(() => currentColor = color);
  }

  void colorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setBackground() async {
    final ui.Image myImage = await FileImage(widget.image).image;
    controller.background = myImage.backgroundDrawable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          children: [
            FlutterPainter(
              controller: controller,
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Wrap(
                children: [
                  SafeArea(child: Container()),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (mode == Mode.pencil) {
                            controller.freeStyleMode = FreeStyleMode.none;
                            setState(() {
                              mode = Mode.none;
                            });
                          } else {
                            controller.freeStyleMode = FreeStyleMode.draw;
                            controller.freeStyleStrokeWidth = 5;
                            setState(() {
                              mode = Mode.pencil;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: mode == Mode.pencil
                                  ? Colors.cyan
                                  : Colors.transparent),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () {
                          if (mode == Mode.erase) {
                            controller.freeStyleMode = FreeStyleMode.none;
                            setState(() {
                              mode = Mode.none;
                            });
                          } else {
                            controller.freeStyleMode = FreeStyleMode.erase;
                            controller.freeStyleStrokeWidth = 50;
                            setState(() {
                              mode = Mode.erase;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: mode == Mode.erase
                                  ? Colors.cyan
                                  : Colors.transparent),
                          child: Icon(
                            Icons.cleaning_services_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            mode = Mode.none;
                            controller.freeStyleMode = FreeStyleMode.none;
                          });
                          controller.textStyle = TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              color: currentColor);
                          // controller.freeStyleMode = FreeStyleMode.erase;
                          controller.addText();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.transparent),
                          child: Icon(
                            Icons.text_fields,
                            color: controller.textSettings.focusNode == null
                                ? Colors.white
                                : controller.textSettings.focusNode!.hasFocus
                                    ? Colors.cyan
                                    : Colors.white,
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          colorPicker();
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              borderRadius: BorderRadius.circular(50),
                              color: currentColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Wrap(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        InkWell(
                          onTap: () async {
                            final ui.Image renderedImage = await controller
                                .renderImage(MediaQuery.of(context).size);

                            final Uint8List? byteData =
                                await renderedImage.pngBytes;
                            if (byteData != null) {
                              final tempDir = await getTemporaryDirectory();
                              final file =
                                  await File('${tempDir.path}/image.png')
                                      .create();
                              file.writeAsBytesSync(byteData);
                              GallerySaver.saveImage(file.path).then((value) {
                                Fluttertoast.showToast(
                                    msg: "Image Saved To Gallery",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.cyan,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 50),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.cyan),
                            child: Text(
                              "Save Image",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
