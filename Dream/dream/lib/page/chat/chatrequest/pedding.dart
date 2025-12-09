import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingRequestsPage extends StatefulWidget {
  final String myUid;
  const PendingRequestsPage({super.key, required this.myUid});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  int currentTab = 0;

  Future<List<String>> getList(String field) async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(widget.myUid).get();
    return List<String>.from(doc.data()?[field] ?? []);
  }

  Future<Map<String, dynamic>> getUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return doc.data() ?? {};
  }

  Future<void> acceptRequest(String uid) async {
    final users = FirebaseFirestore.instance.collection("users");

    // Remove from my pendingRequests and add to my friends
    await users.doc(widget.myUid).update({
      "pendingRequests": FieldValue.arrayRemove([uid]),
      "friends": FieldValue.arrayUnion([uid])
    });

    // Remove my uid from the sender's pendingSent and add me to their friends
    await users.doc(uid).update({
      "pendingSent": FieldValue.arrayRemove([widget.myUid]),
      "friends": FieldValue.arrayUnion([widget.myUid])
    });

    setState(() {});
  }

  Future<void> declineRequest(String uid) async {
    final users = FirebaseFirestore.instance.collection("users");

    await users.doc(widget.myUid).update({
      "pendingRequests": FieldValue.arrayRemove([uid]),
      "declined": FieldValue.arrayUnion([uid])
    });

    // Remove the pendingSent entry from the requester
    await users.doc(uid).update({
      "pendingSent": FieldValue.arrayRemove([widget.myUid])
    });

    setState(() {});
  }

  Future<void> cancelSentRequest(String uid) async {
    final users = FirebaseFirestore.instance.collection("users");

    // Remove from my pendingSent
    await users.doc(widget.myUid).update({
      "pendingSent": FieldValue.arrayRemove([uid])
    });

    // Remove from their pendingRequests
    await users.doc(uid).update({
      "pendingRequests": FieldValue.arrayRemove([widget.myUid])
    });

    setState(() {});
  }

  Widget buildList(String field) {
    // Use a stream on the current user's document so lists update in real-time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(widget.myUid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final raw = data[field];
        final list = <String>[];
        if (raw is List) {
          for (var v in raw) {
            final s = v?.toString() ?? '';
            if (s.trim().isNotEmpty) list.add(s);
          }
        }

        if (list.isEmpty) return const Center(child: Text("No users", style: TextStyle(color: Colors.grey)));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final uid = list[i];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
              builder: (_, userSnap) {
                if (!userSnap.hasData) return const ListTile();
                final user = userSnap.data!.data() as Map<String, dynamic>? ?? {};
                final username = (user['username'] ?? '').toString();
                final email = (user['email'] ?? '').toString();
                return ListTile(
                  leading: CircleAvatar(child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?')),
                  title: Text(username.isNotEmpty ? username : 'Unknown', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(email, style: const TextStyle(color: Colors.white54)),
                  trailing: field == "pendingRequests"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () => acceptRequest(uid),
                                icon: const Icon(Icons.check_circle, color: Colors.green)),
                            IconButton(onPressed: () => declineRequest(uid),
                                icon: const Icon(Icons.highlight_remove_rounded, color: Colors.red)),
                          ],
                        )
                      : field == "pendingSent"
                      ? IconButton(onPressed: () => cancelSentRequest(uid),
                          icon: const Icon(Icons.cancel, color: Colors.orange))
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["Pending Received", "Pending Sent", "Friends", "Declined"];

    return Scaffold(
      backgroundColor: const Color(0xff101010),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Friend Requests"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(Icons.hourglass_bottom, color: Colors.yellow),
          const SizedBox(width: 15),
        ],
      ),

      body: Column(
        children: [

          /// TAB SELECTOR
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => currentTab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: currentTab == i ? Colors.blueAccent : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tabs[i], style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 15),

          /// LISTS AREA
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: [
                buildList("pendingRequests"),
                buildList("pendingSent"),
                buildList("friends"),
                buildList("declined"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
