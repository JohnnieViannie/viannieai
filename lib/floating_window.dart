import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isAndroid) {
    await _requestOverlayPermission();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Floating Window',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isOverlayActive = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _checkOverlayStatus();
    }
  }

  Future<void> _checkOverlayStatus() async {
    try {
      final bool? isActive = await FlutterOverlayWindow.isActive();
      if (mounted) {
        setState(() => isOverlayActive = isActive ?? false);
      }
    } catch (e) {
      debugPrint('Error checking overlay status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Controller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(isOverlayActive ? Icons.close : Icons.open_in_new),
              label: Text(isOverlayActive ? 'Close Chat' : 'Open Floating Chat'),
              onPressed: !kIsWeb && Platform.isAndroid ? _toggleOverlay : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              !kIsWeb && Platform.isAndroid
                  ? 'The chat window will appear as a floating bubble over all apps'
                  : 'Floating chat is only supported on Android',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleOverlay() async {
    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
        if (mounted) {
          setState(() => isOverlayActive = false);
        }
      } else {
        if (await _requestOverlayPermission()) {
          await FlutterOverlayWindow.showOverlay(
            enableDrag: true,
            overlayTitle: "AI Assistant",
            overlayContent: "Tap to open chat", // Placeholder; custom widget not supported directly
            flag: OverlayFlag.defaultFlag,
            visibility: NotificationVisibility.visibilityPublic,
            positionGravity: PositionGravity.auto,
            height: (MediaQuery.sizeOf(context).height * 0.6).toInt(),
            width: (MediaQuery.sizeOf(context).width * 0.8).toInt(),
          );
          if (mounted) {
            setState(() => isOverlayActive = true);
          }
          debugPrint('Overlay launched successfully');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Overlay permission denied. Please enable it in settings.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggling overlay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching overlay: $e')),
        );
      }
    }
  }
}

Future<bool> _requestOverlayPermission() async {
  if (kIsWeb || !Platform.isAndroid) return false;
  try {
    final status = await Permission.systemAlertWindow.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  } catch (e) {
    debugPrint('Error requesting overlay permission: $e');
    return false;
  }
}

// FloatingWindow Widget (to be used if custom overlay is supported)
class FloatingWindow extends StatefulWidget {
  const FloatingWindow({super.key});

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow> {
  bool isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your AI assistant. How can I help you today?",
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];
  String? selectedModel = 'GPT-4';

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (!mounted) return;
      if (event == "toggle") {
        setState(() => isExpanded = !isExpanded);
      }
    }, onError: (error) => debugPrint('Overlay listener error: $error'));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: isExpanded ? _buildExpandedChat() : _buildCollapsedBubble(),
    );
  }

  Widget _buildCollapsedBubble() {
    return GestureDetector(
      onTap: () => FlutterOverlayWindow.shareData('toggle'),
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.chat, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildExpandedChat() {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {},
                  tooltip: 'Add Context',
                ),
                const SizedBox(width: 10),
                const Text(
                  'main.dart Current file',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  color: Colors.grey[800],
                  onSelected: (value) {
                    setState(() => selectedModel = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'GPT-4',
                      child: Text('GPT-4', style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(
                      value: 'Ask Copilot',
                      child: Text('Ask Copilot', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => FlutterOverlayWindow.shareData('toggle'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:  CrossAxisAlignment.end,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Icon(Icons.auto_awesome, size: 12, color: Colors.white),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[700],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 16 : 0),
                  topRight: Radius.circular(message.isUser ? 0 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
          if (message.isUser)
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 12, color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      text: _messageController.text.trim(),
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getAIResponse(newMessage.text, selectedModel),
          isUser: false,
          time: DateTime.now(),
        ));
      });
    });
  }

  String _getAIResponse(String userMessage, String? model) {
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('hello')) {
      return "Hi there! How can I assist you today? (Using $model)";
    } else if (lowerMessage.contains('help')) {
      return "I can answer questions or chat! (Using $model)";
    } else {
      return "I understand you said: '$userMessage'. This is a simulated response. (Using $model)";
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}