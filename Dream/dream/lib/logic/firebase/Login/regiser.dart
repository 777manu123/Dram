import 'package:dream/logic/firebase/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _headerAnimation;
  late AnimationController _photoAnimation;
  late AnimationController _fieldsAnimation;

  File? profileImage;
  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    _headerAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _photoAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fieldsAnimation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Start animations sequentially
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimation.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _photoAnimation.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fieldsAnimation.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimation.dispose();
    _photoAnimation.dispose();
    _fieldsAnimation.dispose();
    email.dispose();
    password.dispose();
    username.dispose();
    super.dispose();
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => profileImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<String?> uploadProfileImage(String uid) async {
    if (profileImage == null) return null;

    try {
      final bytes = await profileImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> register() async {
    String name = username.text.trim();
    if (name.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Check if username already exists
      var check = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: name)
          .get();

      if (check.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username already taken")),
        );
        setState(() => loading = false);
        return;
      }

      // Create user with email/password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Upload profile image if selected
      String? profileImageBase64;
      if (profileImage != null) {
        profileImageBase64 = await uploadProfileImage(uid);
      }

      // Save user info to Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "email": email.text.trim(),
        "username": name,
        "profileImage": profileImageBase64,
        "createdAt": FieldValue.serverTimestamp(),
        "friends": [],
        "pendingRequests": [],
        "pendingSent": [],
        "declined": [],
        "onlineStatus": "online",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header with animation
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-100 * (1 - _headerAnimation.value), 0),
                      child: Opacity(
                        opacity: _headerAnimation.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.blueAccent, Colors.cyan],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(0.6 * value),
                                          blurRadius: 20,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.person_add, color: Colors.white, size: 32),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [Colors.blueAccent, Colors.cyan],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Join Dream and start chatting",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Profile Photo Section with animation
                AnimatedBuilder(
                  animation: _photoAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - _photoAnimation.value)),
                      child: Opacity(
                        opacity: _photoAnimation.value,
                        child: Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: pickProfileImage,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 1, end: 1),
                                    duration: const Duration(milliseconds: 300),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Colors.blueAccent, Colors.cyan],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blueAccent.withOpacity(0.5),
                                                blurRadius: 16,
                                                spreadRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: profileImage != null
                                              ? ClipOval(
                                                  child: Image.file(
                                                    profileImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                profileImage != null ? "✓ Photo selected" : "Tap to add photo",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Form Fields with animation
                AnimatedBuilder(
                  animation: _fieldsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - _fieldsAnimation.value)),
                      child: Opacity(
                        opacity: _fieldsAnimation.value,
                        child: Column(
                          children: [
                            // Email Field
                            buildAnimatedInputField(
                              label: "Email Address",
                              hint: "Enter your email",
                              icon: Icons.email,
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              delay: 0,
                            ),

                            const SizedBox(height: 16),

                            // Username Field
                            buildAnimatedInputField(
                              label: "Username",
                              hint: "Choose a username",
                              icon: Icons.person,
                              controller: username,
                              delay: 100,
                            ),

                            const SizedBox(height: 16),

                            // Password Field
                            buildPasswordField(),

                            const SizedBox(height: 30),

                            // Register Button
                            buildRegisterButton(),

                            const SizedBox(height: 20),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(color: Colors.white60, fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                    );
                                  },
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white12,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1 * value),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(icon, color: Colors.blueAccent, size: 22),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: keyboardType,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPasswordField() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white12,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1 * value),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: password,
                    style: const TextStyle(color: Colors.white),
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: "At least 6 characters",
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.lock, color: Colors.blueAccent, size: 22),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRegisterButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5 * value),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: loading ? null : register,
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
