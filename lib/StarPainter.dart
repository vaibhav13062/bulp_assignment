import 'dart:io';

import 'package:bulp_assignment/star_clipper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class StarPainerScreen extends StatefulWidget {
  const StarPainerScreen({Key? key}) : super(key: key);

  @override
  State<StarPainerScreen> createState() => _StarPainerScreenState();
}

class _StarPainerScreenState extends State<StarPainerScreen> {
  bool showStarWidget = false;
  bool toPaint = true;
  double widgetSize = 100;
  double internalRaduis = 100 / 4;
  int starCount = 5;

  Uint8List? _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          children: [
            // Expanded(
            //     child: Container(
            //   color: Colors.white,
            // )),
            Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: DraggingArea(
                  child: showStarWidget
                      ? SizedBox(
                          height: widgetSize,
                          width: widgetSize,
                          child: CustomPaint(
                            painter:
                                StarPainter(starCount, toPaint, internalRaduis),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Wrap(
                children: [
                  SafeArea(child: Container()),
                  Row(
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                showStarWidget = !showStarWidget;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: !showStarWidget
                                      ? Colors.transparent
                                      : Colors.cyan),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Visibility(
                            visible: showStarWidget,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  toPaint = !toPaint;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.transparent),
                                child: Icon(
                                  toPaint ? Icons.star : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Visibility(
                        visible: showStarWidget,
                        child: Expanded(
                            child: Column(
                          children: [
                            Slider(
                              value: widgetSize,
                              min: 100,
                              max: MediaQuery.of(context).size.width - 10,
                              label: widgetSize.round().toString(),
                              activeColor: Colors.cyan,
                              onChanged: (double value) {
                                setState(() {
                                  widgetSize = value;
                                  internalRaduis = value / 4;
                                });
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Slider(
                              value: starCount.toDouble(),
                              min: 3,
                              activeColor: Colors.cyan,
                              max: 40,
                              label: starCount.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  starCount = value.toInt();
                                });
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Slider(
                              value: internalRaduis,
                              min: 10,
                              // divisions: 1,
                              activeColor: Colors.cyan,
                              max: widgetSize / 2.5,
                              label: internalRaduis.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  internalRaduis = value;
                                });
                              },
                            ),
                          ],
                        )),
                      )
                      // InkWell(
                      //   onTap: () {
                      //     colorPicker();
                      //   },
                      //   child: Container(
                      //     padding: EdgeInsets.all(20),
                      //     decoration: BoxDecoration(
                      //         border:
                      //         Border.all(color: Colors.white, width: 1.5),
                      //         borderRadius: BorderRadius.circular(50),
                      //         color: currentColor),
                      //   ),
                      // ),
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
                           await screenshotController
                                .capture()
                                .then((Uint8List? image) {
                              //Capture Done
                              setState(() {
                                _imageFile = image;
                              });
                            }).catchError((onError) {
                              print(onError);
                            });

                            if (_imageFile != null) {
                              final tempDir = await getTemporaryDirectory();
                              final file =
                                  await File('${tempDir.path}/image.png')
                                      .create();
                              file.writeAsBytesSync(_imageFile!);
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
            ),
          ],
        ),
      ),
    );
  }
}

class DraggingArea extends StatefulWidget {
  final Widget child;

  const DraggingArea({Key? key, required this.child}) : super(key: key);

  @override
  _DragAreaStateStateful createState() => _DragAreaStateStateful();
}

class _DragAreaStateStateful extends State<DraggingArea> {
  Offset position = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: widget.child,
            childWhenDragging: Opacity(
              opacity: .3,
              child: widget.child,
            ),
            onDragEnd: (details) => setState(() => position = details.offset),
            child: widget.child,
          ),
        )
      ],
    );
  }
}
