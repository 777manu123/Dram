// small_story.dart

import 'package:dream/logic/firebase/firebaselogic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hive_flutter/hive_flutter.dart';

class SmallStory extends StatefulWidget {
  final String chatRoomId;
  final String myId;
  const SmallStory({super.key, required this.chatRoomId, required this.myId});

  @override
  State<SmallStory> createState() => _SmallStoryState();
}

class _SmallStoryState extends State<SmallStory> with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final ScrollController scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late String chatRoomId;
  late String myId;
  late String receiverId;

  bool isUploading = false;
  Map<String, Uint8List> _localMedia = {};

  // reply state
  String? replyToMessageId;
  Map<String, dynamic>? replyToMessageData;

  @override
  void initState() {
    super.initState();
    chatRoomId = widget.chatRoomId;
    myId = widget.myId;
    _ensureHiveBox();
    _getReceiverId();
  }

  void _ensureHiveBox() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isBoxOpen('messages')) {
        await Hive.openBox('messages');
      }
    } catch (e) {
      debugPrint('Hive box open error: $e');
    }
  }

  void _getReceiverId() async {
    try {
      final roomDoc = await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .get();
      final users = List<String>.from(roomDoc['users'] ?? []);
      receiverId = users.firstWhere((u) => u != myId);
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching receiverId: $e');
    }
  }

  void _clearReply() {
    setState(() {
      replyToMessageId = null;
      replyToMessageData = null;
    });
  }

  void sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || receiverId.isEmpty) return;

    await ChatService().sendMessage(
      chatRoomId: chatRoomId,
      text: text,
      userId: myId,
      receiverId: receiverId,
      replyToId: replyToMessageId,
      replyToText: replyToMessageData != null ? replyToMessageData!['text'] : null,
    );

    controller.clear();
    _clearReply();

    Future.delayed(const Duration(milliseconds: 180), () {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickAndSendPhoto() async {
    if (receiverId.isEmpty) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();

      final send = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0A0E27),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(bytes, width: 300, height: 300, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
                ],
              )
            ],
          ),
        ),
      );

      if (send != true) return;

      setState(() => isUploading = true);
      await ChatService().sendMedia(
        chatRoomId: chatRoomId,
        filePath: image.path,
        mediaType: "photo",
        userId: myId,
        receiverId: receiverId,
        replyToId: replyToMessageId,
        replyToText: replyToMessageData != null ? replyToMessageData!['text'] : null,
      );
      setState(() => isUploading = false);
      _clearReply();

      Future.delayed(const Duration(milliseconds: 200), () {
        if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo sent!")));
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> pickAndSendVideo() async {
    if (receiverId.isEmpty) return;
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final fileName = video.name;
      final send = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0A0E27),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 180,
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.videocam, size: 48, color: Colors.white54),
                    const SizedBox(height: 8),
                    Text(fileName, style: const TextStyle(color: Colors.white70)),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
              ])
            ],
          ),
        ),
      );

      if (send != true) return;

      setState(() => isUploading = true);
      await ChatService().sendMedia(
        chatRoomId: chatRoomId,
        filePath: video.path,
        mediaType: "video",
        userId: myId,
        receiverId: receiverId,
        replyToId: replyToMessageId,
        replyToText: replyToMessageData != null ? replyToMessageData!['text'] : null,
      );
      setState(() => isUploading = false);
      _clearReply();

      Future.delayed(const Duration(milliseconds: 200), () {
        if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video sent!")));
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // --- TOP RIGHT menu (3-dot) ---
  void _openChatMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1220),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.person), title: const Text("View contact", style: TextStyle(color: Colors.white)), onTap: () {}),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text("Media & files", style: TextStyle(color: Colors.white)), onTap: () {}),
            ListTile(leading: const Icon(Icons.settings), title: const Text("Chat settings", style: TextStyle(color: Colors.white)), onTap: () {}),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text("Clear chat", style: TextStyle(color: Colors.redAccent)), onTap: () {}),
          ]),
        );
      },
    );
  }

  // --- message actions bottom sheet (modern / telegram style) ---
  void _showActionsSheet(Map<String, dynamic> msg, String messageId) {
    final bool isMine = msg['userId'] == myId;
    final bool isText = (msg['type'] ?? 'text') == 'text';
    final bool isStarred = msg['starred'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0C1220),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // icon row
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _actionCircle(icon: Icons.reply, label: "Reply", onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    replyToMessageId = messageId;
                    replyToMessageData = msg;
                  });
                }),
                _actionCircle(icon: Icons.forward, label: "Forward", onTap: () {
                  Navigator.pop(context);
                  // implement forward - open contact selection
                }),
                _actionCircle(icon: isStarred ? Icons.star : Icons.star_border, label: isStarred ? "Unstar" : "Star", onTap: () async {
                  Navigator.pop(context);
                  await ChatService().Statandunstar(chatRoomId, messageId, isStarred);
                }),
                if (isText) _actionCircle(icon: Icons.copy, label: "Copy", onTap: () {
                  Clipboard.setData(ClipboardData(text: msg['text']?.toString() ?? ""));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied")));
                }),
                if (isMine) _actionCircle(icon: Icons.edit, label: "Edit", onTap: () {
                  Navigator.pop(context);
                  _editMessageDialog(context, msg, messageId);
                }),
                if (isMine) _actionCircle(icon: Icons.delete_outline, label: "Delete", onTap: () async {
                  Navigator.pop(context);
                  await ChatService().deleteMessage(chatRoomId, messageId);
                }),
              ]),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ]),
          ),
        );
      },
    );
  }

  Widget _actionCircle({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkResponse(
          onTap: onTap,
          radius: 28,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF152033),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(width: 70, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      ],
    );
  }

  // edit dialog
  void _editMessageDialog(BuildContext context, Map<String, dynamic> message, String messageId) {
    final editController = TextEditingController(text: message['text']?.toString() ?? "");
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text("Edit message", style: TextStyle(color: Colors.white)),
        content: TextField(controller: editController, maxLines: null, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () async {
            final newText = editController.text.trim();
            if (newText.isNotEmpty) {
              await ChatService().edit(chatRoomId, messageId, newText);
            }
            Navigator.pop(context);
          }, child: const Text("Save", style: TextStyle(color: Colors.blue))),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF1F2937),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blueAccent, size: 24), onPressed: () => Navigator.pop(context)),
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("chatRooms").doc(chatRoomId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) return const SizedBox();
              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final users = List<String>.from(data['users'] ?? []);
              final otherId = users.firstWhere((u) => u != myId, orElse: () => '');
              if (otherId.isEmpty) return const SizedBox();

              return StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance.ref("status/$otherId").onValue,
                builder: (context, snap) {
                  String status = "offline";
                  if (snap.hasData && snap.data!.snapshot.value != null) {
                    final d = snap.data!.snapshot.value as Map?;
                    status = d?["state"] ?? "offline";
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(otherId).snapshots(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData || userSnap.data == null) return const SizedBox();
                        final udata = userSnap.data!.data() as Map<String, dynamic>? ?? {};
                        final otherUsername = (udata['username'] ?? '').toString();
                        return Text(otherUsername.isEmpty ? 'Chat' : otherUsername, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600));
                      },
                    ),
                    Text(status == 'online' ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: status == 'online' ? Colors.greenAccent.withOpacity(0.8) : Colors.white38)),
                  ]);
                },
              );
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: _openChatMenu),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: ChatService().getMessages(chatRoomId),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            final messages = snap.data!.docs;
            return ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final messageDoc = messages[index];
                final data = messageDoc.data() as Map<String, dynamic>;
                final bool isMe = data["userId"] == myId;
                final messageType = data["type"] ?? "text";
                final status = data['status'] ?? 'sent';
                final timestamp = data["timestamp"] as Timestamp?;
                final time = formatTime(timestamp);
                final isStarred = data['starred'] == true;
                // delivered/viewed marking (kept from your logic)
                if (!isMe && status == 'sent') {
                  ChatService().markMessageDelivered(chatRoomId, messageDoc.id);
                }
                if (!isMe && status != 'viewed') {
                  ChatService().markMessageViewed(chatRoomId, messageDoc.id);
                }

                return GestureDetector(
                  onLongPress: () => _showActionsSheet(data, messageDoc.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) _avatarForNotMe(),
                        const SizedBox(width: 8),
                        Flexible(child: _messageBubble(data, messageType, isMe, isStarred, time, status)),
                        if (isMe) const SizedBox(width: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )),
        // reply preview
        if (replyToMessageData != null) _replyPreview(),
        // input area
        _inputBar(),
      ]),
    );
  }

  Widget _avatarForNotMe() {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.blueAccent, Colors.cyan])),
      child: const Center(child: Text("U", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

Widget _messageBubble(Map<String, dynamic> data, String messageType, bool isMe, bool isStarred, String time, String status) {
  final text = data['text'] ?? '';
  final replyText = data['replyToText'];
  Widget content;

  if (messageType == "text") {
    content = Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500));
  } else if (messageType == "photo") {
    // decrypt and show the image
    final bytes = ChatService().decryptBase64ToBytes(data['mediaData'] ?? '');
    content = bytes.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          )
        : const Icon(Icons.broken_image, color: Colors.white, size: 50);
  } else if (messageType == "video") {
    content = Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 200, height: 120, color: Colors.black26),
        const Icon(Icons.play_circle, size: 40, color: Colors.white),
      ],
    );
  } else {
    content = const SizedBox();
  }

  return Column(
    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      if (replyText != null && replyText.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
          child: Text(
            replyText.length > 90 ? "${replyText.substring(0, 90)}..." : replyText,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? null : const Color(0xFF1F2937),
          gradient: isMe ? LinearGradient(colors: [Colors.blueAccent, Colors.blue.shade700]) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(time, style: const TextStyle(fontSize: 11, color: Colors.white38)),
        const SizedBox(width: 6),
        if (isMe)
          if (status == 'sent')
            const Icon(Icons.done, size: 14, color: Colors.white38)
          else if (status == 'delivered')
            const Icon(Icons.done_all, size: 14, color: Colors.white38)
          else if (status == 'viewed')
            const Icon(Icons.done_all, size: 14, color: Colors.greenAccent),
      ]),
    ],
  );
}


  Widget _replyPreview() {
    final previewText = replyToMessageData?['text']?.toString() ?? (replyToMessageData?['type'] ?? 'Media');
    return Container(
      color: const Color(0xFF0C1220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Replying to', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(previewText.length > 120 ? '${previewText.substring(0, 120)}...' : previewText, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        ),
        IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: _clearReply)
      ]),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1F2937), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1))),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 24), onPressed: () {}),
        IconButton(icon: const Icon(Icons.image, color: Colors.lightBlueAccent, size: 24), onPressed: isUploading ? null : pickAndSendPhoto),
        IconButton(icon: const Icon(Icons.videocam, color: Colors.orangeAccent, size: 24), onPressed: isUploading ? null : pickAndSendVideo),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10, width: 1)),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                suffixIcon: isUploading
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
                    : null,
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue]), borderRadius: BorderRadius.circular(24)),
          child: IconButton(
            icon: isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.send, color: Colors.white, size: 20),
            onPressed: isUploading ? null : sendMessage,
          ),
        )
      ]),
    );
  }
}
