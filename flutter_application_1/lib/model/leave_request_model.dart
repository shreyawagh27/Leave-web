
class LeaveRequest {
  String name;
  String type;
  String duration;
  DateTime startDate;
  DateTime endDate;
  String description;
  String status;
  String id;

  LeaveRequest({
    required this.name,
    required this.type,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.id,
    required this.status,

  });
}