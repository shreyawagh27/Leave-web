import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequest {
  String name;
  String type;
  String duration;
  DateTime startDate;
  DateTime endDate;
  String description;
  String status;

  LeaveRequest({
    required this.name,
    required this.type,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.status = 'Pending',
  });
}

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  List<LeaveRequest> allLeaveRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  
  Future<void> fetchData() async {
    try {
      final response =
          await FirebaseFirestore.instance.collection('leave_request').get();
      List data = response.docs;

      allLeaveRequests.clear(); 

      DateFormat format = DateFormat("dd MMM yyyy");

      for (var document in data) {
        LeaveRequest leaveRequest = LeaveRequest(
          name: document['name'] ?? 'Unknown',
          type: document['type'] ?? 'N/A',
          duration: document['duration'] ?? 'N/A',
          startDate: format.parse(document['start']),
          endDate: format.parse(document['end']),
          description: document['description'] ?? '',
        );
        allLeaveRequests.add(leaveRequest);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: const Color(0xFF4285F4),
      ),
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allLeaveRequests.isEmpty
              ? const Center(child: Text('No leave requests found.'))
              : ListView.builder(
                  itemCount: allLeaveRequests.length,
                  itemBuilder: (context, index) {
                    final leave = allLeaveRequests[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      const Color.fromARGB(255, 108, 185, 248),
                                  child: Text(
                                    leave.name.isNotEmpty
                                        ? leave.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      leave.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Type: ${leave.type}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'From: ${DateFormat('dd MMM yyyy').format(leave.startDate)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'To: ${DateFormat('dd MMM yyyy').format(leave.endDate)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Duration: ${leave.duration}'),
                            const SizedBox(height: 8),
                            Text('Reason: ${leave.description}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _actionButton('Approve', Colors.green, () {
                                  setState(() {
                                    leave.status = 'Approved';
                                  });
                                }),
                                const SizedBox(width: 8),
                                _actionButton('Reject', Colors.redAccent, () {
                                  setState(() {
                                    leave.status = 'Rejected';
                                  });
                                }),
                                const SizedBox(width: 8),
                                _actionButton('View', Colors.blueAccent, () {
                                  _showDetailsDialog(context, leave);
                                }),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Status: ${leave.status}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: leave.status == 'Approved'
                                      ? Colors.green
                                      : leave.status == 'Rejected'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _showDetailsDialog(BuildContext context, LeaveRequest leave) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${leave.name} - Leave Details'),
        content: Text(
          'Type: ${leave.type}\n'
          'Duration: ${leave.duration}\n'
          'From: ${DateFormat('dd MMM yyyy').format(leave.startDate)}\n'
          'To: ${DateFormat('dd MMM yyyy').format(leave.endDate)}\n'
          'Reason: ${leave.description}\n'
          'Status: ${leave.status}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
