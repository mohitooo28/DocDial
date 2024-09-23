class Booking {
  final String date;
  final String description;
  final String id;
  final String receiver;
  final String sender;
  final String status;
  final String time;
  final String name;
  final String review;
  final String profilePhoto;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.status,
    required this.time,
    required this.name,
    required this.review,
    required this.profilePhoto,
  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      receiver: data['receiver'] ?? '',
      sender: data['sender'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',
      name: data['name'] ?? '',
      review: data['review'] ?? '',
      profilePhoto: data['profilePhoto'] ?? '',
    );
  }

  // get name => null;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'receiver': receiver,
      'sender': sender,
      'status': status,
      'time': time,
      'name': name,
      'profilePhoto': profilePhoto,
    };
  }
}
