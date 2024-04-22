class Message {
  final String from;
  final String text;
  final String rider;
  final String driver;
  final String timeStamp;

  const Message(
    {
      this.from = '',
      this.text = '',
      this.driver = '',
      this.rider = '',
      this.timeStamp = ''
    }
  );

  factory Message.fromJson(Map<String, dynamic>  json) {
    return Message(
      from: json['from'] as String,
      text: json['text'] as String,
      timeStamp: json['timeStamp'] as String
    );
  }

  static List<Message> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map<Message>((json) => Message.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
    'from': from,
    'text': text,
    'rider': rider,
    'driver': driver,
  };
}
