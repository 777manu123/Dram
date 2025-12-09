import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final String? username;
  final String? email;
  final String? profileUrl;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLogout;
  final VoidCallback? onPrivacy;
  final VoidCallback? onNotification;
  final VoidCallback? onBlockedUsers;
  final Function(bool)? onThemeChange;

  const SettingsPage({
    super.key,
    required this.username,
    required this.email,
    this.profileUrl,
    this.onEditProfile,
    this.onLogout,
    this.onPrivacy,
    this.onNotification,
    this.onBlockedUsers,
    this.onThemeChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    
    /// SAFETY — Prevent Null or Empty Crashes
    final safeName = (widget.username != null && widget.username!.trim().isNotEmpty)
        ? widget.username!.trim()
        : "Unknown User";

    final safeEmail = (widget.email != null && widget.email!.trim().isNotEmpty)
        ? widget.email!.trim()
        : "No Email Linked";

    final avatarInitial = safeName[0].toUpperCase(); // 🔥 Always valid now

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // ================= PROFILE ==========================
          _sectionTitle("Profile"),

          Container(
            decoration: _boxStyle(),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      (widget.profileUrl != null && widget.profileUrl!.isNotEmpty)
                          ? NetworkImage(widget.profileUrl!)
                          : null,
                  backgroundColor: Colors.blueAccent,
                  child: (widget.profileUrl == null || widget.profileUrl!.isEmpty)
                      ? Text(avatarInitial,
                          style: const TextStyle(
                              fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(safeName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(safeEmail,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Edit profile - Coming soon")),
                    );
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ================= GENERAL ==========================
          _sectionTitle("General"),
          _tile(
            Icons.notifications,
            "Notifications",
            "Sound, alerts, vibration",
            () {
              setState(() => notificationsEnabled = !notificationsEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(notificationsEnabled ? "Notifications enabled" : "Notifications disabled")),
              );
            },
          ),
          _tile(
            Icons.privacy_tip,
            "Privacy",
            "Last seen, profile info",
            () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text("Privacy Settings", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "• Show last seen: ON\n• Show online status: ON\n• Allow message requests: ON\n• Profile visibility: Public",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close", style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          _tile(
            Icons.block,
            "Blocked Users",
            "View blocked list",
            () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text("Blocked Users", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "No users blocked",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close", style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // ================= APPEARANCE ==========================
          _sectionTitle("Appearance"),
          _themeToggle(),

          const SizedBox(height: 25),

          // ================= ACCOUNT ============================
          _sectionTitle("Account"),
          _tile(
            Icons.logout,
            "Log out",
            "Exit from account",
            () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text("Log out?", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            // Pop dialog first
                            Navigator.pop(context);
                            // Then pop settings page
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                      },
                      child: const Text("Log out", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------------
  Widget _tile(IconData icon, String title, String subtitle, VoidCallback tap,
      {Color color = Colors.blueAccent}) {
    return Container(
      decoration: _boxStyle(),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 24),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 16),
        onTap: tap,
      ),
    );
  }

  //---------------------------------------------------------
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  //---------------------------------------------------------
  BoxDecoration _boxStyle() => BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      );

  //---------------------------------------------------------
  Widget _themeToggle() {
    return Container(
      decoration: _boxStyle(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SwitchListTile(
        activeThumbColor: Colors.blueAccent,
        activeTrackColor: Colors.blueAccent.withOpacity(0.3),
        value: isDarkMode,
        onChanged: (value) {
          setState(() => isDarkMode = value);
          widget.onThemeChange?.call(value);
        },
        title: const Text("Dark Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: const Text("Switch light / dark theme",
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      ),
    );
  }
}
