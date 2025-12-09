import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/logic/firebase/firebaselogic.dart';
import 'package:dream/page/chat/chatrequest/pedding.dart';
import 'package:dream/page/setting/settingpage.dart';
import 'package:dream/page/store/small_story.dart';
import 'package:dream/widgets/joystickcontroller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final String myUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController friendSearchController = TextEditingController();
  String friendSearchText = "";
  final FocusNode friendSearchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with greeting
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6),
                      const Color(0xFF1F2937),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Messages",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Stay connected with friends",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.4)),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                child: _friendSearchBar(),
              ),

              // Friends list
              Expanded(child: _friendList()),
            ],
          ),

          // Bottom-center joystick
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AnimatedJoystick(
              onAddFriendPressed: () {
                _showAddFriendDialog();
              },
              checkPendingRequests: () {
                return Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 450),
                      pageBuilder: (_, __, ___) =>
                          PendingRequestsPage(myUid: myUid),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position:
                              Tween(begin: Offset(0, 1), end: Offset(0, 0))
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic)),
                          child: child,
                        );
                      },
                    ));
              },
              settingsMenu: () {
                return Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SettingsPage(
                              username: "",
                              email: '',
                            )));
              },
              // when joystick search icon pressed, focus the friend search field
              friendSearchBar: () async {
                try {
                  friendSearchFocusNode.requestFocus();
                } catch (_) {}
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar for existing friends
  Widget _friendSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: friendSearchFocusNode,
        controller: friendSearchController,
        onChanged: (value) => setState(() => friendSearchText = value.trim()),
        decoration: InputDecoration(
          hintText: "Search friends...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.search, color: Colors.blueAccent, size: 22),
          ),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  /// Helper to get last message from chat

  /// Existing friends list
  Widget _friendList() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection("users").doc(myUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        final myData = snapshot.data!.data() as Map<String, dynamic>;
        final friends = List<String>.from(myData["friends"] ?? []);

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline,
                    size: 80, color: Colors.blueAccent.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  "No friends yet",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap the + button to add friends",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friendUid = friends[index].toString().trim();

            if (friendUid.isEmpty) return const SizedBox();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(friendUid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final user =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final username = (user["username"] ?? '').toString();

                if (!username
                    .toLowerCase()
                    .contains(friendSearchText.toLowerCase())) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1F2937),
                          const Color(0xFF111827),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final chatRoomId = await ChatService()
                            .createChatRoom(myUid, friendUid);

                        // ✅ Mark messages as read here
                        await ChatService().markMessagesAsRead(
                          myUid: myUid,
                          friendUid: friendUid,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SmallStory(
                              chatRoomId: chatRoomId,
                              myId: myUid,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                username[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // online indicator dot
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: StreamBuilder(
                                stream: FirebaseDatabase.instance
                                    .ref("status/$friendUid")
                                    .onValue,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const SizedBox();

                                  final data =
                                      snapshot.data!.snapshot.value as Map?;
                                  final status = data?["state"] ?? "offline";

                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: status == "online"
                                          ? Colors.greenAccent
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black87, width: 1.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .ref("status/$friendUid")
                              .onValue,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            final data = snapshot.data!.snapshot.value as Map?;
                            final status = data?["state"] ?? "offline";

                            return Text(
                              status == 'online' ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: status == 'online'
                                    ? Colors.greenAccent.withOpacity(0.8)
                                    : Colors.white38,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        trailing: StreamBuilder<int>(
                          stream: ChatService().unreadCountStream(
                            myUid: myUid,
                            friendUid: friendUid,
                          ),
                          builder: (context, snap) {
                            final n = snap.data ?? 0;
                         if (n <= 0) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                n > 99 ? '99+' : n.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Show Add Friend dialog
  void _showAddFriendDialog() {
    final TextEditingController addController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      builder: (_) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1E1E).withOpacity(0.95),
                const Color(0xFF121212).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Title
              Text("Add New Friend",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600)),

              const SizedBox(height: 20),

              /// Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: addController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter username...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Buttons Row
              Row(
                children: [
                  /// Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text("Cancel",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Add Friend Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        String username = addController.text.trim();

                        if (username.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Enter a username")));
                          return;
                        }

                        final query = await FirebaseFirestore.instance
                            .collection("users")
                            .where("username", isEqualTo: username)
                            .get();

                        if (query.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User not found")));
                          return;
                        }

                        final friendUid = query.docs.first.id;

                        if (friendUid == myUid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Cannot add yourself")));
                          return;
                        }

                        final users =
                            FirebaseFirestore.instance.collection("users");

                        // Fetch both docs to check current state
                        final myDoc = await users.doc(myUid).get();
                        final friendDoc = await users.doc(friendUid).get();

                        final myData = myDoc.data() ?? {};
                        final friendData = friendDoc.data() ?? {};

                        final myFriends =
                            List<String>.from(myData["friends"] ?? []);
                        final myPendingSent =
                            List<String>.from(myData["pendingSent"] ?? []);
                        final friendPending = List<String>.from(
                            friendData["pendingRequests"] ?? []);

                        if (myFriends.contains(friendUid)) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Already friends")));
                          return;
                        }

                        if (myPendingSent.contains(friendUid) ||
                            friendPending.contains(myUid)) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Request already pending")));
                          return;
                        }

                        // Add to recipient's pendingRequests and my pendingSent
                        await users.doc(friendUid).update({
                          "pendingRequests": FieldValue.arrayUnion([myUid])
                        });

                        await users.doc(myUid).update({
                          "pendingSent": FieldValue.arrayUnion([friendUid])
                        });

                        Navigator.pop(context); // close popup

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("Friend request sent to $username")),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text("Add Friend",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
