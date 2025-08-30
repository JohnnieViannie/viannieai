import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:intl/intl.dart'; // For date parsing
import 'setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isOverlayVisible = false;
  late AnimationController _animationController;
  late Animation<double> _statusDotAnimation;

  // Sample chat history sessions
  final List<Map<String, String>> _chatSessions = [
    {'title': 'VPS Configuration', 'date': 'Aug 30, 2025'},
    {'title': 'General Q&A', 'date': 'Aug 29, 2025'},
    {'title': 'Coding Tips', 'date': 'Aug 28, 2025'},
  ];

  @override
  void initState() {
    super.initState();
    _checkOverlayPermission();
    _sortChatSessionsByDate();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _statusDotAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sort chat sessions by date (newest first)
  void _sortChatSessionsByDate() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    _chatSessions.sort((a, b) {
      final dateA = dateFormat.parse(a['date']!);
      final dateB = dateFormat.parse(b['date']!);
      return dateB.compareTo(dateA); // Newest first
    });
  }

  // Check and request overlay permission
  Future<void> _checkOverlayPermission() async {
    bool? isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      bool? requested = await FlutterOverlayWindow.requestPermission();
      if (requested == true) {
        developer.log("Overlay permission granted");
      } else {
        developer.log("Overlay permission denied");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Overlay permission is required",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        );
      }
    }
  }

  // Toggle overlay visibility
  Future<void> _toggleOverlay() async {
    if (_isOverlayVisible) {
      await FlutterOverlayWindow.closeOverlay();
      setState(() {
        _isOverlayVisible = false;
        _animationController.reverse();
      });
    } else {
      await FlutterOverlayWindow.showOverlay(
        height: 100,
        width: 100,
        alignment: OverlayAlignment.center,
        enableDrag: true,
        positionGravity: PositionGravity.auto,
        overlayTitle: "Viannie",
        overlayContent: "Viannie is active",
        flag: OverlayFlag.defaultFlag,
      );
      setState(() {
        _isOverlayVisible = true;
        _animationController.forward();
      });
    }
  }

  // Navigate to settings screen
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  // Navigate to individual chat session
  void _openChatSession(Map<String, String> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Opening ${session['title']}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade900,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  // Start new chat session
  void _startNewChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Starting new chat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade900,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900, // Dark teal background
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Viannie',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: 24.0,
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedBuilder(
              animation: _statusDotAnimation,
              builder: (context, _) => Tooltip(
                message: _isOverlayVisible ? 'AI Orb Active' : 'AI Orb Inactive',
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOverlayVisible
                        ? Colors.teal.shade300.withOpacity(_statusDotAnimation.value)
                        : Colors.grey.shade600.withOpacity(_statusDotAnimation.value),
                    boxShadow: _isOverlayVisible
                        ? [
                            BoxShadow(
                              color: Colors.teal.shade300.withOpacity(0.5),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatSessions.length,
              itemBuilder: (context, index) {
                final session = _chatSessions[index];
                return GestureDetector(
                  onTap: () => _openChatSession(session),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            session['title']!,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Text(
                          session['date']!,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.teal.shade100,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _toggleOverlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Text(
                _isOverlayVisible ? 'Hide AI Orb' : 'Show AI Orb',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: Colors.teal.shade300,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Start New Chat',
      ),
    );
  }
}