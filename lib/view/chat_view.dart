import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/chat_controller.dart';
//import '../model/chat_message.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController chatCtrl = GetIt.I.get<ChatController>();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatCtrl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat com Advogado",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00796B),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatCtrl.messages.length,
              itemBuilder: (context, index) {
                final msg = chatCtrl.messages[index];
                return Container(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(msg.message),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Digite sua mensagem...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.trim().isNotEmpty) {
                      chatCtrl.sendMessage(messageController.text.trim());
                      messageController.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
