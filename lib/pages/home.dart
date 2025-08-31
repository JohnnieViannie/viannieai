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
  String _searchQuery = '';
  List<Map<String, String>> _filteredChatSessions = [];

  // Sample chat history sessions
  final List<Map<String, String>> _chatSessions = [
    {'title': 'VPS configuration', 'date': 'Aug 30, 2025'},
    {'title': 'Cup cut video edit ', 'date': 'Aug 29, 2025'},
    {'title': 'Fixing flutter bug', 'date': 'Aug 28, 2025'},
  ];

  @override
  void initState() {
    super.initState();
    _checkOverlayPermission();
    _sortChatSessionsByDate();
    _filteredChatSessions = _chatSessions; // Initialize filtered list with all chats
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

  // Filter chat sessions based on search query
  void _filterChatSessions(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChatSessions = _chatSessions;
      } else {
        _filteredChatSessions = _chatSessions
            .where((session) =>
                session['title']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
          const SnackBar(
            content: Text(
              "Overlay permission is required",
              style: TextStyle(color: Color(0xFF3DF2B6)),
            ),
            backgroundColor: Color(0xFF172226),
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
        overlayContent: "Floating button is active",
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
          style: const TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: const Color(0xFF172226),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172226), // Original dark teal background
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Viannie ',
              style: TextStyle(
                color: Color(0xFF3DF2B6), // Original vibrant green text
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedBuilder(
              animation: _statusDotAnimation,
              builder: (context, _) => Tooltip(
                message: _isOverlayVisible ? 'AI Orb Active' : 'AI Orb Inactive',
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOverlayVisible
                        ? const Color(0xFF3DF2B6).withOpacity(_statusDotAnimation.value)
                        : Colors.grey.withOpacity(_statusDotAnimation.value),
                    boxShadow: _isOverlayVisible
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3DF2B6).withOpacity(0.5),
                              blurRadius: 6.0,
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
        backgroundColor: const Color(0xFF172226),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF3DF2B6)),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterChatSessions,
              style: const TextStyle(color: Color(0xFF3DF2B6)),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: const TextStyle(color: Color(0xFF3DF2B6)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3DF2B6)),
                filled: true,
                fillColor: const Color(0xFF263238), // Match card color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Chat list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredChatSessions.length,
              itemBuilder: (context, index) {
                final session = _filteredChatSessions[index];
                return GestureDetector(
                  onTap: () => _openChatSession(session),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF263238), // Original card color
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                              color: Color(0xFF3DF2B6), // Original vibrant green text
                            ),
                          ),
                        ),
                        Text(
                          session['date']!,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF3DF2B6), // Original vibrant green text
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // AI Orb toggle button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isOverlayVisible)
                  ElevatedButton.icon(
                    onPressed: _toggleOverlay,
                    icon: Icon(Icons.visibility, color: Color(0xFF3DF2B6)),
                    label: Text(
                      'Show AI Orb',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3DF2B6),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF263238),
                      foregroundColor: Color(0xFF3DF2B6),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                    ),
                  ),
                if (_isOverlayVisible)
                  ElevatedButton.icon(
                    onPressed: _toggleOverlay,
                    icon: Icon(Icons.visibility_off, color: Color(0xFF3DF2B6)),
                    label: Text(
                      'Hide AI Orb',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3DF2B6),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF263238),
                      foregroundColor: Color(0xFF3DF2B6),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}