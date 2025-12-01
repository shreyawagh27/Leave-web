import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final String adminDocId = "admin@gmail.com";
  final String userEmail = "user@gmail.com";

  bool showHolidays = false;

  int pending = 0, approved = 0, rejected = 0, totalBalance = 0;

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
    await fetchLeaveTypes();
    await fetchWeeklyOff();
    await fetchLeaveCounts();
    //await fetchHolidays();
    await fetchLeaveBalance();
    setState(() {});
  }

  Future<void> fetchLeaveCounts() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userEmail = pref.getString("email") ?? " ";

    final snap = await FirebaseFirestore.instance
        .collection("leave_request")
        .where("email", isEqualTo: userEmail)
        .get();

    pending = 0;
    approved = 0;
    rejected = 0;
    for (int i = 0; i < snap.docs.length; i++) {
      final doc = snap.docs[i];
      final status = doc["status"];
      if (status == "Pending") {
        pending++;
      } else if (status == "Approved") {
        approved++;
      } else if (status == "Rejected") {
        rejected++;
      }
      if (status == 'Approved') {
        final type = doc['type'];
        int dayCount = 1;
        try {
           dayCount = doc['dayCount'];
        }catch (e){
        print(e);
        }
        print(usedLeaveTypeCount[type]);
        usedLeaveTypeCount[type] = (usedLeaveTypeCount[type] ?? 0) + dayCount;
      }
    }
  }

  Future<void> fetchLeaveTypes() async {
    final doc = await FirebaseFirestore.instance
        .collection("admins")
        .doc(adminDocId)
        .get();

    leaveTypes = List<Map<String, dynamic>>.from(
      doc.data()?["yearlyLeaves"] ?? [],
    );
    holidays = List<Map<String, dynamic>>.from(
      doc.data()?["nationalHoliday"] ?? [],
    );
  }

  Future<void> fetchWeeklyOff() async {
    final doc = await FirebaseFirestore.instance
        .collection("admins")
        .doc(adminDocId)
        .get();

    weeklyOff = List<String>.from(doc.data()?["weeklyOff"] ?? []);
  }

  Future<void> fetchLeaveBalance() async {
    totalBalance = 0;

    for (int i = 0; i < leaveTypes.length; i++) {
      String leaveName = leaveTypes[i]["name"];
      int allowed = leaveTypes[i]["days"];
      int usedCount = usedLeaveTypeCount[leaveName]?? 0;
      log('leaveType: $leaveName   allowed:  $allowed   used: $usedCount  ');
      final snap = await FirebaseFirestore.instance
          .collection("leave_request")
          .where("email", isEqualTo: userEmail)
          // .where("type", isEqualTo: leaveName)
          .where("status", isEqualTo: "Approved")
          .get();

      int used = snap.docs.length;
      totalBalance += (allowed - used);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("User Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                statusBox(
                  "Pending",
                  Icons.pending_actions_outlined,
                  Colors.orange.shade100,
                  pending,
                ),
                const SizedBox(width: 12),
                statusBox(
                  "Approved",
                  Icons.verified,
                  Colors.green.shade100,
                  approved,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                statusBox(
                  "Rejected",
                  Icons.cancel,
                  Colors.red.shade100,
                  rejected,
                ),
                const SizedBox(width: 12),
                statusBox(
                  "Leave Balance",
                  Icons.event_available,
                  Colors.purple.shade100,
                  totalBalance,
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Weekly Off",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

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
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Leave Types",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Column(
              children: List.generate(leaveTypes.length, (i) {
                String name = leaveTypes[i]["name"];
                int allowed = leaveTypes[i]["days"];

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      "Allowed: $allowed",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: () => setState(() => showHolidays = !showHolidays),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      "National Holidays",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      subtitle: Text("${date.day}-${date.month}-${date.year}"),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget statusBox(String label, IconData icon, Color color, int value) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
