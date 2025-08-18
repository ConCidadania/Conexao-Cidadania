class ChatMessage {
  final String message;
  final bool
      isUser; // true se a mensagem for do usuário, false se for do advogado
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
