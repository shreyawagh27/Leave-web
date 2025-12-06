import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String, dynamic>? user;

class UserDashboard extends StatefulWidget {
  UserDashboard({super.key, userData}) {
    user = userData;
  }

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final String adminDocId = "admin@gmail.com";

  bool isLoading = false;
  bool showHolidays = false;

  int pending = 0, approved = 0, rejected = 0;

  List<String> weeklyOff = [];
  List<Map<String, dynamic>> leaveTypes = [];
  List<Map<String, dynamic>> holidays = [];

  Map<String, int> usedLeaveTypeCount = {};

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      setState(() => isLoading = true);

      await fetchLeaveTypes();
      await fetchWeeklyOff();
      await fetchLeaveCounts();

      setState(() => isLoading = false);
    } catch (e) {
      log('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLeaveCounts() async {
    String userEmail = user?['email'] ?? '';

    final snap = await FirebaseFirestore.instance
        .collection("leave_request")
        .where("email", isEqualTo: userEmail)
        .get();

    pending = 0;
    approved = 0;
    rejected = 0;
    usedLeaveTypeCount.clear();

    for (var doc in snap.docs) {
      final data = doc.data();

      final status = data["status"];
      final type = data["type"];

      int dayCount = 1; 

      if (data.containsKey("dayCount")) {
        final raw = data["dayCount"];
        dayCount = int.tryParse(raw.toString()) ?? 1;
      }

      if (status == "Pending") pending++;
      if (status == "Approved") approved++;
      if (status == "Rejected") rejected++;

    
      if (status == "Approved") {
        usedLeaveTypeCount[type] = (usedLeaveTypeCount[type] ?? 0) + dayCount;
      }
    }
  }

 
  Future<void> fetchLeaveTypes() async {
    final doc = await FirebaseFirestore.instance
        .collection("admins")
        .doc(adminDocId)
        .get();

    leaveTypes =
        List<Map<String, dynamic>>.from(doc.data()?["yearlyLeaves"] ?? []);

    holidays =
        List<Map<String, dynamic>>.from(doc.data()?["nationalHolidays"] ?? []);
  }


  Future<void> fetchWeeklyOff() async {
    final doc = await FirebaseFirestore.instance
        .collection("admins")
        .doc(adminDocId)
        .get();

    weeklyOff = List<String>.from(doc.data()?["weeklyOff"] ?? []);
  }

  
  Widget statusBox(String title, IconData icon, Color color, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          AppBar(title: const Text("User Dashboard"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(),
    );
  }

  Widget buildContent() {
    String username = user?['username'] ?? 'User';
    String email = user?['email'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(
                username,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email),
            ),
          ),

          const SizedBox(height: 20),

          
          Row(
            children: [
              statusBox("Pending", Icons.pending_actions,
                  Colors.orange.shade100, pending),
              const SizedBox(width: 12),
              statusBox("Approved", Icons.verified, Colors.green.shade100,
                  approved),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              statusBox("Rejected", Icons.cancel, Colors.red.shade100,
                  rejected),
              const SizedBox(width: 12),
              statusBox("Leave Types", Icons.list_alt,
                  Colors.blue.shade200, leaveTypes.length),
            ],
          ),

          const SizedBox(height: 25),

         
          const Text("Weekly Off",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              weeklyOff.join(", "),
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 25),

  
          const Text("Leave Types",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          Column(
            children: List.generate(leaveTypes.length, (i) {
              String name = leaveTypes[i]["name"];
              int allowed = leaveTypes[i]["days"];
              int used = usedLeaveTypeCount[name] ?? 0;
              int remaining = allowed - used;

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Row(
                    children: [
                      Text("Allowed: $allowed",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      Text("Used: $used",
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      Text("Remaining: $remaining",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          
          GestureDetector(
            onTap: () => setState(() => showHolidays = !showHolidays),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text(
                    "National Holidays",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(
                    showHolidays
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          if (showHolidays)
            Column(
              children: List.generate(holidays.length, (i) {
                final date = holidays[i]["date"].toDate();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(holidays[i]["name"]),
                    subtitle:
                        Text("${date.day}-${date.month}-${date.year}"),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
