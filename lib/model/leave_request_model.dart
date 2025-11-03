class LeaveRequest {
  String name;
  String leaveType;
  DateTime startDate;
  DateTime endDate;
  int daysCount;
  String note;
  String initial;
  String status;

  LeaveRequest({
    required this.name,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.note,
    required this.initial,
    this.status = 'Pending',
  });
}
