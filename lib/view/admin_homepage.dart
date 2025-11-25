
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final String adminDocId = "admin@gmail.com";

  int totalUsers = 5;
  int pendingLeaves = 5;
  int approvedLeaves = 18;

  List<String> totalUserList = [
    "Sanket",
    "Shreya",
    "Arati",
    "Vaishnavi",
    "Siddharth",
  ];

  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<String> selectedDays = ["Saturday", "Sunday"];

  List<Map<String, dynamic>> yearlyHolidayList = [
    {"name": "Sick Leave", "days": 6},
    {"name": "Emergency Leave", "days": 6},
    {"name": "Unpaid Leave", "days": 0},
    {"name": "Planned Leave", "days": 12},
  ];

  int get totalLeaveDays {
    int total = 0;
    for (var item in yearlyHolidayList) {
      total += item["days"] as int;
    }
    return total;
  }

  final List<Map<String, String>> _holidays = [
    {"name": "Republic Day", "date": "26 Jan 2025", "day": "Sunday"},
    {"name": "Holi", "date": "29 Mar 2025", "day": "Saturday"},
    {"name": "Independence Day", "date": "15 Aug 2025", "day": "Friday"},
    {"name": "Diwali", "date": "20 Oct 2025", "day": "Monday"},
    {"name": "Christmas", "date": "25 Dec 2025", "day": "Thursday"},
  ];

  int holidayIndex = 0;

  void nextHoliday() => setState(() {
        holidayIndex = (holidayIndex + 1) % _holidays.length;
      });

  void prevHoliday() => setState(() {
        holidayIndex =
            (holidayIndex - 1 + _holidays.length) % _holidays.length;
      });


  Widget _buildDashboardCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            FittedBox(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }


  void _showEmployeeList(BuildContext context) {
    TextEditingController empCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Employees",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.teal, size: 30),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Add Employee"),
                              content: TextField(
                                controller: empCtrl,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      if (empCtrl.text.isNotEmpty) {
                                        setSheet(() {
                                          totalUserList
                                              .add(empCtrl.text.trim());
                                          totalUsers =
                                              totalUserList.length;
                                        });
                                        setState(() {});
                                        empCtrl.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text("Add")),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: totalUserList.length,
                      itemBuilder: (_, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.teal),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(totalUserList[index],
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  setSheet(() {
                                    totalUserList.removeAt(index);
                                    totalUsers = totalUserList.length;
                                  });
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  void _showWeeklyOffSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text("Select Weekly Off",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: days.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(day,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Checkbox(
                                value: isSelected,
                                onChanged: (v) {
                                  setSheet(() {
                                    if (v == true) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _holidays[holidayIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Admin Dashboard",
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // FIRST ROW
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.blue.shade100,
                        icon: Icons.people_alt_outlined,
                        value: totalUsers.toString(),
                        label: "Total Employees",
                        onTap: () => _showEmployeeList(context),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.orange.shade100,
                        icon: Icons.pending_actions_outlined,
                        value: pendingLeaves.toString(),
                        label: "Pending Leaves",
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.green.shade100,
                        icon: Icons.verified_outlined,
                        value: approvedLeaves.toString(),
                        label: "Approved Leaves",
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // SECOND ROW
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.purple.shade100,
                        icon: Icons.holiday_village,
                        value: totalLeaveDays.toString(),
                        label: "Yearly Holidays",
                        onTap: () => _showWeeklyOffSelector(context),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.teal.shade100,
                        icon: Icons.event_available,
                        value: "8",
                        label: "Used Leaves",
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 3 - 10,
                      child: _buildDashboardCard(
                        color: Colors.indigo.shade100,
                        icon: Icons.calendar_today,
                        value: selectedDays.join(", "),
                        label: "Weekly Off",
                        onTap: () => _showWeeklyOffSelector(context),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFEDE7F6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(" National Holidays",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent)),
                  const SizedBox(height: 10),
                  Text(h["name"]!,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("${h['date']} • ${h['day']}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: prevHoliday),
                      IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: nextHoliday),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
