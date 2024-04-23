class Chat {
  final String? rider;
  final String? driver;
  final dynamic messages;

  const Chat(
    {
      this.rider,
      this.driver,
      this.messages = const [],
    }
  );

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      rider: json['rider'] as String,
      driver: json['driver'] as String,
      messages: json['messages'] as dynamic
    );
  }

  static List<Chat> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map<Chat>((json) => Chat.fromJson(json)).toList();
  }
}
