class Chat {
  final String? to;
  final String? from;
  final String? message;

  const Chat(
      {
      this.to,
      this.from,
      this.message
      });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      to: json['to'] as String,
      from: json['from'] as String,
      message: json['message'] as String,
    );
  }
  static List<Chat> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map<Chat>((json) => Chat.fromJson(json)).toList();
  }
}
