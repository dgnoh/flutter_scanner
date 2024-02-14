import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:scanner/scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner/scanner_image.dart';
import 'package:scanner/scanner_method_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  File? scannedDocument;
  Future<PermissionStatus>? cameraPermissionFuture;
  MethodChannelScanner scannerChannel = MethodChannelScanner();
  ValueNotifier<bool> isDetectedNotifier = ValueNotifier<bool>(false);
  Timer? _timer;

  void startTimer() {
    const interval = const Duration(milliseconds: 500);
    _timer = Timer.periodic(interval, (timer) async {
      // 여기에 반복적으로 실행할 코드를 작성합니다.
      var result = await scannerChannel.isScannerReady();

      // 만약 result가 원하는 값이라면 Timer를 종료합니다.
      if (result != null) {
        scannerChannel.setCaptureEnabled(true);
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    requestCamera();
    cameraPermissionFuture = Permission.camera.request();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      startTimer();
    });
  }

  Future<PermissionStatus> requestCamera() async{
    return Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Scanners app'),
          ),
          body: FutureBuilder<PermissionStatus>(
            future: requestCamera(),
            builder: (BuildContext context,
                AsyncSnapshot<PermissionStatus> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data! == PermissionStatus.granted) {
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: scannedDocument != null
                                ? Image(
                              image: FileImage(scannedDocument!),
                            )
                                : Scanner(
                              // documentAnimation: false,
                              noGrayScale: true,
                              onDocumentScanned:
                                  (ScannedImage scannedImage) {
                                print("document : " +
                                    scannedImage.croppedImage!);

                                // setState(() {
                                //   scannedDocument = scannedImage
                                //       .getScannedDocumentAsFile();
                                // });
                              },
                              onRectangleDetected: (bool isDetected) {
                                print("isDetected : " + isDetected.toString());
                                isDetectedNotifier.value = isDetected;
                              },
                            ),
                          ),
                        ],
                      ),
                     ValueListenableBuilder(valueListenable: isDetectedNotifier, builder: (contet, isDetected, child) {
                       return  Positioned(
                           top: 200,
                           child: Container(
                             width: MediaQuery.of(context).size.width, // 앱의 전체 너비로 설정
                             height: 200, // 원하는 높이
                             decoration: BoxDecoration(
                               color: Colors.transparent, // 배경을 투명하게 설정
                               border: Border.all(
                                 color: isDetected ? Colors.blue : Colors.red, // 테두리 색상을 빨간색으로 설정
                                 width: 2, // 테두리 두께 설정
                               ),
                             ),
                           ));
                     })
                    ],
                  );
                } else {
                  Permission.camera.request();
                  return const Center(
                    child: Text("camera permission denied"),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await scannerChannel.getPlatformVersion();
          await scannerChannel.setCaptureEnabled(false);
        },
        child: const Icon(Icons.camera_alt),
      ),),
    );
  }
}
