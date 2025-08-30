import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Placeholder state for account settings
  String _username = "Viannie Wasswa";
  String _email = "wasswaVianni@gmail.com";
  String _phone = "+256705640852";
  bool _notificationsEnabled = true;
  String _subscriptionPlan = "Free Plan";
  bool _twoFactorAuth = false;

  // Toggle notification setting
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Notifications ${value ? 'enabled' : 'disabled'}",
          style: const TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: const Color(0xFF172226),
      ),
    );
  }

  // Toggle two-factor authentication
  void _toggleTwoFactorAuth(bool value) {
    setState(() {
      _twoFactorAuth = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Two-factor authentication ${value ? 'enabled' : 'disabled'}",
          style: const TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: const Color(0xFF172226),
      ),
    );
  }

  // Update account details (placeholder)
  void _updateAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Account update coming soon!",
          style: TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: Color(0xFF172226),
      ),
    );
  }

  // Manage subscription (redirect to xAI for SuperGrok)
  void _manageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Visit https://x.ai/grok for subscription details",
          style: TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: Color(0xFF172226),
      ),
    );
  }

  // Sign out (placeholder)
  void _signOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Sign out coming soon!",
          style: TextStyle(color: Color(0xFF3DF2B6)),
        ),
        backgroundColor: Color(0xFF172226),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172226), // Dark teal background
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF3DF2B6),
            fontWeight: FontWeight.w700,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: const Color(0xFF172226),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3DF2B6)),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Home',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Profile Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF263238),
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
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3DF2B6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF172226),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3DF2B6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          // Settings List
          _buildSettingItem(
            icon: Icons.email,
            title: 'Email',
            subtitle: _email,
            onTap: _updateAccount,
          ),
          _buildSettingItem(
            icon: Icons.phone,
            title: 'Phone number',
            subtitle: _phone,
            onTap: _updateAccount,
          ),
          _buildSettingItem(
            icon: Icons.star,
            title: 'Upgrade to Plus',
            subtitle: '',
            onTap: _manageSubscription,
          ),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Personalization',
            subtitle: '',
            onTap: () {}, // Placeholder
          ),
          _buildSettingItem(
            icon: Icons.data_usage,
            title: 'Data Controls',
            subtitle: '',
            onTap: () {}, // Placeholder
          ),
          _buildSettingItem(
            icon: Icons.mic,
            title: 'Voice',
            subtitle: '',
            onTap: () {}, // Placeholder
          ),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Security',
            subtitle: '',
            trailing: Switch(
              value: _twoFactorAuth,
              onChanged: _toggleTwoFactorAuth,
              activeColor: const Color(0xFF3DF2B6),
              inactiveTrackColor: Colors.grey.withOpacity(0.5),
            ),
            onTap: null,
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: '',
            onTap: () {}, // Placeholder
          ),
          _buildSettingItem(
            icon: Icons.exit_to_app,
            title: 'Sign out',
            subtitle: '',
            textColor: Colors.red,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  // Helper to build setting items
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String subtitle = '',
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3DF2B6)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textColor ?? const Color(0xFF3DF2B6),
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14.0,
                color: Color(0xFF3DF2B6),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}