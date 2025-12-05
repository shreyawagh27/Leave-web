import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {

  final Map<String, dynamic>? user;

  const UserDashboard({Key? key, this.user}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final String adminDocId = "admin@gmail.com";

  bool showHolidays = false;
  bool isLoading = false;

  int pending = 0, approved = 0, rejected = 0, totalBalance = 0;

  List<String> weeklyOff = [];
  List<Map<String, dynamic>> leaveTypes = [];
  List<Map<String, dynamic>> holidays = [];
  Map<String, int> usedLeaveTypeCount = {};

  
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    
    if (widget.user != null) {
      user = Map<String, dynamic>.from(widget.user!);
      loadAllData(); 
    } else {
      loadUserDataFromPrefs();
    }
  }

  
  Future<void> loadUserDataFromPrefs() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      user = {
        "username": pref.getString("username") ?? "User",
        "email": pref.getString("email") ?? "no-email@example.com",
        "department": pref.getString("department") ?? "Not Assigned",
        "joiningDate": pref.getString("joiningDate") ?? "-",
        "role": pref.getString("role") ?? "Employee",
      };

      await loadAllData();
    } catch (e) {
      debugPrint("Error loading user prefs: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  
  Future<void> loadAllData() async {
    try {
      setState(() => isLoading = true);

      await fetchLeaveTypes();
      await fetchWeeklyOff();
      await fetchLeaveCounts();
      await fetchLeaveBalance();

      setState(() => isLoading = false);
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  
  Future<void> fetchLeaveCounts() async {
    final email = (user["email"] ?? "").toString();
    if (email.isEmpty) return;

    final snap = await FirebaseFirestore.instance
        .collection("leave_request")
        .where("email", isEqualTo: email)
        .get();

    pending = approved = rejected = 0;
    usedLeaveTypeCount.clear();

    for (var doc in snap.docs) {
      final status = (doc.data()["status"] ?? "").toString();

      if (status == "Pending") pending++;
      if (status == "Approved") approved++;
      if (status == "Rejected") rejected++;

      if (status == "Approved") {
        final type = doc.data()["type"] ?? "Unknown";
        int dayCount = int.tryParse(doc.data()["dayCount"].toString()) ?? 0;
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
        List<Map<String, dynamic>>.from(doc.data()?["nationalHoliday"] ?? []);
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

    for (var leave in leaveTypes) {
      String leaveName = leave["name"];
      int allowed = leave["days"];
      int used = usedLeaveTypeCount[leaveName] ?? 0;

      totalBalance += (allowed - used);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("User Dashboard"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  userInfoBox(),

                  const SizedBox(height: 20),

              
                  Row(
                    children: [
                      statusBox("Pending", Icons.pending_actions_outlined,
                          Colors.orange.shade100, pending),
                      const SizedBox(width: 12),
                      statusBox("Approved", Icons.verified,
                          Colors.green.shade100, approved),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      statusBox("Rejected", Icons.cancel,
                          Colors.red.shade100, rejected),
                      const SizedBox(width: 12),
                      statusBox("Leave Balance", Icons.event_available,
                          Colors.purple.shade100, totalBalance),
                    ],
                  ),

                  const SizedBox(height: 25),

                  
                  const Text(
                    "Weekly Off",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      weeklyOff.isNotEmpty ? weeklyOff.join(", ") : "—",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),

                  const SizedBox(height: 25),

                
                  const Text(
                    "Leave Types",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(leaveTypes.length, (i) {
                      String name = leaveTypes[i]["name"];
                      int allowed = leaveTypes[i]["days"];
                      int used = usedLeaveTypeCount[name] ?? 0;
                      int balance = allowed - used;

                      return Card(
                        child: ListTile(
                          title: Text(name),
                          subtitle: Row(
                            children: [
                              Text("Allowed: $allowed",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Colors.blue)),
                              const SizedBox(width: 20),
                              Text("Used: $used",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Colors.red)),
                              const SizedBox(width: 20),
                              Text("Remaining: $balance",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Colors.green)),
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
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "National Holidays",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Icon(showHolidays ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 26),
                        ],
                      ),
                    ),
                  ),

                  if (showHolidays)
                    Column(
                      children: List.generate(holidays.length, (i) {
                        final date = holidays[i]["date"] is Timestamp
                            ? (holidays[i]["date"] as Timestamp).toDate()
                            : (holidays[i]["date"] is DateTime ? holidays[i]["date"] as DateTime : DateTime.now());
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(holidays[i]["name"] ?? "Holiday"),
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


  Widget userInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("User Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        infoRow("Name", user["username"] ?? "—"),
        infoRow("Email", user["email"] ?? "—"),
        infoRow("Department", user["department"] ?? "—"),
        infoRow("Joining Date", user["joiningDate"] ?? "—"),
        infoRow("Role", user["role"] ?? "—"),
      ]),
    );
  }

  
  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        Expanded(child: Text(value?.toString() ?? "N/A", style: const TextStyle(fontSize: 16))),
      ]),
    );
  }

  
  Widget statusBox(String label, IconData icon, Color color, int value) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20),
          const SizedBox(height: 5),
          Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}
