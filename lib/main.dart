import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_window.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> _requestOverlayPermission() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    _requestOverlayPermission();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Screen AI Assistant')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await FlutterOverlayWindow.showOverlay();
            },
            child: Text('Start AI Assistant'),
          ),
        ),
      ),
    );
  }
}
