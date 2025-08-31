import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class AdvancedFloatingButton extends StatefulWidget {
  const AdvancedFloatingButton({super.key});

  @override
  _AdvancedFloatingButtonState createState() => _AdvancedFloatingButtonState();
}

class _AdvancedFloatingButtonState extends State<AdvancedFloatingButton>
    with SingleTickerProviderStateMixin {
  bool _showMenu = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    FlutterOverlayWindow.overlayListener.listen((event) {
      developer.log("Received event: $event");
      if (event == "show_menu") {
        _toggleMenu();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 void _toggleMenu() async {
  developer.log("X"); // Log "X" when button is clicked
  setState(() {
    _showMenu = !_showMenu;
  });

  final double screenWidth = ui.window.physicalSize.width / ui.window.devicePixelRatio;
  final double screenHeight = ui.window.physicalSize.height / ui.window.devicePixelRatio;

  if (_showMenu) {
    const double barHeight = 150.0;
    await FlutterOverlayWindow.resizeOverlay(screenWidth.toInt(), barHeight.toInt(), true);
    await FlutterOverlayWindow.moveOverlay(OverlayPosition(0.0, (screenHeight - barHeight).toDouble()));
    _animationController.forward();
  } else {
    const double orbSize = 100.0;
    await    await FlutterOverlayWindow.moveOverlay(OverlayPosition((screenWidth / 2 - orbSize / 2).toDouble(), (screenHeight / 2 - orbSize / 2).toDouble()));
    _animationController.reverse();
  }

  FlutterOverlayWindow.shareData("show_menu");
}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _showMenu ? _buildInputBar() : _buildFloatingOrb(),
    );
  }

  Widget _buildFloatingOrb() {
    return GestureDetector(
      onTap: _toggleMenu,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF263238),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Color(0xFF3DF2B6).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3DF2B6).withOpacity(0.2),
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      height: 150.0, // Fixed height to match barHeight
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF263238),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _toggleMenu,
            child: Icon(
              Icons.close,
              color: Color(0xFF3DF2B6),
              size: 36,
            ),
          ),
          Expanded(
            child: TextField(
              style: TextStyle(color: Color(0xFF3DF2B6)),
              decoration: InputDecoration(
                hintText: 'Ask Viannie...',
                hintStyle: TextStyle(color: Color(0xFF3DF2B6).withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.mic, color: Color(0xFF3DF2B6)),
                onPressed: () {
                  // Add mic logic here
                },
              ),
              IconButton(
                icon: Icon(Icons.send, color: Color(0xFF3DF2B6)),
                onPressed: () {
                  // Add send logic here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}