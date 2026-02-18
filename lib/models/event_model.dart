class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final String minutesOfMeeting;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.minutesOfMeeting,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      description: json['description'] as String,
      minutesOfMeeting: json['minutesOfMeeting'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'minutesOfMeeting': minutesOfMeeting,
    };
  }
}
