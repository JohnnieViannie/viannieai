import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingBubble extends StatelessWidget {
  const FloatingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // When bubble tapped, show second floating overlay (chat input)
        await FlutterOverlayWindow.showOverlay(
          height: 70,
          width: 350,
          alignment: OverlayAlignment.bottomCenter,
          flag: OverlayFlag.defaultFlag,
          enableDrag: true,
          overlayTitle: "chatInput", // 👈 distinguish second overlay
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: const Center(
          child: Text(
            "Y", // 👈 your logo here
            style: TextStyle(color: Colors.white, fontSize: 26),
          ),
        ),
      ),
    );
  }
}
