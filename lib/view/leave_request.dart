import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/leave_request_model.dart';

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
  setState(() => isLoading = true);

  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("[log] No logged-in user");
      setState(() => isLoading = false);
      return;
    }

    final loggedEmail = currentUser.email ?? '';
    print("[log] Logged In Email: $loggedEmail");

  
    final response  = await FirebaseFirestore.instance
        .collection('leave_request')
        .where('email', isEqualTo: loggedEmail)
        .get();

    allLeaveRequests.clear();
    DateFormat df = DateFormat("dd MMM yyyy");

    for (int i = 0; i < response.docs.length; i++) {
      final document = response.docs[i];
      final map = document.data() as Map<String, dynamic>;

      
      String name = map['name']?.toString() ?? '';
      String email = map['email']?.toString() ?? '';
      String type = map['type']?.toString() ?? '';
      String duration = map['duration']?.toString() ?? '';
      String description = map['description']?.toString() ?? '';
      String status = map['status']?.toString() ?? 'Pending';

      
      int durationDays = int.tryParse(duration) ?? 0;

      DateTime? startDate;
      DateTime? endDate;

      try {
        startDate = df.parse(map['start'] ?? '');
        endDate = df.parse(map['end'] ?? '');
      } catch (e) {
        print("[log] Date parsing error for document ${document.id}: $e");
        continue;
      }

      print("Fetched ${i + 1}: $name ($email), Duration: $durationDays days");

      allLeaveRequests.add(
        LeaveRequest(
          id: document.id,
          name: name,
          type: type,
          email: email,
          duration: duration,
          startDate: startDate,
          endDate: endDate,
          description: description,
          status: status,
        ),
      );
    }
  } catch (e) {
    print("[log] Error fetching data: $e");
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
        backgroundColor: const Color(0xFF4285F4),
      ),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allLeaveRequests.isEmpty
              ? const Center(child: Text("No leave requests found"))
              : ListView.builder(
                  itemCount: allLeaveRequests.length,
                  itemBuilder: (context, index) {
                    final leave = allLeaveRequests[index];
                    return _leaveCard(leave);
                  },
                ),
    );
  }

  Widget _leaveCard(LeaveRequest leave) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              leave.type,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("From: ${DateFormat('dd MMM yyyy').format(leave.startDate)}"),
            Text("To:   ${DateFormat('dd MMM yyyy').format(leave.endDate)}"),
            const SizedBox(height: 6),
            Text('Duration: ${leave.duration}'),
            const SizedBox(height: 6),
            Text('Reason: ${leave.description}'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                leave.status,
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
  }
}
