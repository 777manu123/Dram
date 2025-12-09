import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/logic/auth_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String username = '';
  String? profileBase64;
  bool autoLogin = false;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    username = (data['username'] ?? '').toString();
    profileBase64 = (data['profileImage'] ?? '')?.toString();
    autoLogin = await AuthPrefs.isAutoLogin();
    setState(() {});
  }

  Future<void> _setAutoLogin(bool v) async {
    await AuthPrefs.setAutoLogin(v);
    setState(() => autoLogin = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: profileBase64 != null && profileBase64!.isNotEmpty ? MemoryImage(base64Decode(profileBase64!)) : null,
              child: profileBase64 == null || profileBase64!.isEmpty ? const Icon(Icons.person, size: 48) : null,
            ),
            const SizedBox(height: 12),
            Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Auto Login'),
              value: autoLogin,
              onChanged: _setAutoLogin,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
