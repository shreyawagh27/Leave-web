

import 'package:intl/intl.dart';

class LeaveRequest {
  String name;
  String type;
  String email;
  String duration;
  DateTime startDate;
  DateTime endDate;
  String description;
  String status;
  String id;

  LeaveRequest({
    required this.name,
    required this.type,
    required this.email,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.id,
    required this.status,

  });

   Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start': DateFormat('dd MMM yyyy').format(startDate),
      'end': DateFormat('dd MMM yyyy').format(endDate),
      'type': type,
      'duration': duration,
      'description': description,
      'id': id,
      'status': status,
      'email': email,
    };
  }
  
 
}

