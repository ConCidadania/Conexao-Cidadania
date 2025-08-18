import 'package:flutter/material.dart';
import '../model/chat_message.dart';

class ChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  // Envia uma mensagem do usuário e adiciona uma resposta automática
  void sendMessage(String message) {
    // Adiciona a mensagem do usuário
    _messages.add(ChatMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Após um breve atraso, adiciona uma resposta automática do advogado
    Future.delayed(const Duration(seconds: 1), () {
      _messages.add(ChatMessage(
        message: "O JustiBot não esta pronto no momento.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
