import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user["username"] ?? "User Details"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Employee Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            infoRow("Name", user["username"]),
            infoRow("Department", user["department"] ?? "Not Assigned"),
            infoRow("Joining Date", user["joiningDate"] ?? "-"),
            infoRow("Role", user["role"] ?? "Employee"),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
            
              },
              icon: const Icon(Icons.history),
              label: const Text("View Leave History"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16)),
          Expanded(
            child: Text(value?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
