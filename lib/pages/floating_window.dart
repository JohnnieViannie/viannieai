import 'dart:developer' as developer;
import 'dart:math' show pi, cos, sin;
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
  int? _hoveredIndex;
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
        setState(() {
          _showMenu = true;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
      _hoveredIndex = null;
    });

    if (_showMenu) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    FlutterOverlayWindow.shareData("show_menu");
  }

  void _onMenuItemTap(int index, String itemName) {
    developer.log("$itemName option tapped");
    _toggleMenu();
    // Add functionality for each menu item here
  }

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.edit,
      'title': 'Edit',
      'color': Colors.blueAccent,
    },
    {
      'icon': Icons.share,
      'title': 'Share',
      'color': Colors.greenAccent,
    },
    {
      'icon': Icons.download,
      'title': 'Download',
      'color': Colors.orangeAccent,
    },
    {
      'icon': Icons.favorite,
      'title': 'Favorite',
      'color': Colors.pinkAccent,
    },
    {
      'icon': Icons.delete,
      'title': 'Delete',
      'color': Colors.redAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow effect when menu is open
          if (_showMenu)
            FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

          // Main Floating Button
          AnimatedRotation(
            turns: _rotateAnimation.value,
            duration: const Duration(milliseconds: 600),
            child: GestureDetector(
              onTap: _toggleMenu,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6AB4FF),
                        Color(0xFF1E88E5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse effect
                      AnimatedScale(
                        scale: _showMenu ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Icon(
                        _showMenu ? Icons.close : Icons.add,
                        color: Colors.white,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Circular Menu Items
          if (_showMenu)
            ...List.generate(_menuItems.length, (index) {
              final double angle = (index / _menuItems.length) * 2 * pi;
              return Positioned(
                left: 100 * cos(angle),
                top: 100 * sin(angle),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: _buildCircularMenuItem(
                      index: index,
                      icon: _menuItems[index]['icon'],
                      title: _menuItems[index]['title'],
                      color: _menuItems[index]['color'],
                    ),
                  ),
                ),
              );
            }),

          // Tooltip for hovered item
          if (_hoveredIndex != null && _showMenu)
            Positioned(
              left: 120 * cos((_hoveredIndex! / _menuItems.length) * 2 * pi) + 40,
              top: 120 * sin((_hoveredIndex! / _menuItems.length) * 2 * pi),
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    _menuItems[_hoveredIndex!]['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => _onMenuItemTap(index, title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: _hoveredIndex == index
                  ? Colors.white.withOpacity(0.8)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}