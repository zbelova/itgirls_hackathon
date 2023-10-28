class Task {
  final String? key;
  final String title;
  final String description;
  final bool isDone;
  final int duration;

  Task({
    this.key,
    required this.title,
    required this.description,
    required this.isDone,
    required this.duration,
  });

  Task.fromMap(String key, Map<String, dynamic> map)
      : key = key,
        title = map['title'],
        description = map['description'],
        isDone = map['isDone'],
        duration = map['duration'];
}