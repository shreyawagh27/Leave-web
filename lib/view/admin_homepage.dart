import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Use this doc id as provided
  final String adminDocId = "admin@gmail.com";

  // Dashboard values (defaults)
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
    "Sunday",
  ];

  List<String> selectedDays = ["Saturday", "Sunday"];

  // YEARLY LEAVES
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

  // NATIONAL HOLIDAYS (defaults)
  List<Map<String, String>> _holidays = [
    {"name": "Republic Day", "date": "26 Jan 2025", "day": "Sunday"},
    {"name": "Holi", "date": "29 Mar 2025", "day": "Saturday"},
    {"name": "Independence Day", "date": "15 Aug 2025", "day": "Friday"},
    {"name": "Diwali", "date": "20 Oct 2025", "day": "Monday"},
    {"name": "Christmas", "date": "25 Dec 2025", "day": "Thursday"},
  ];

  int holidayIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // load data from Firestore (if available)
    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      final docRef = _firestore.collection('admins').doc(adminDocId);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;

        setState(() {
          totalUsers = (data['totalUsers'] ?? totalUserList.length) as int;
          pendingLeaves = (data['pendingLeaves'] ?? pendingLeaves) as int;
          approvedLeaves = (data['approvedLeaves'] ?? approvedLeaves) as int;

          // load totalUserList (List<String>)
          if (data['totalUserList'] != null) {
            final list = List.from(data['totalUserList']);
            totalUserList = list.map((e) => e.toString()).toList();
          }

          // load weeklyOff as List<String>
          if (data['weeklyOff'] != null) {
            final list = List.from(data['weeklyOff']);
            selectedDays = list.map((e) => e.toString()).toList();
          }

          // load yearlyLeaves as list of maps {'name':..., 'days':...}
          if (data['yearlyLeaves'] != null) {
            final list = List.from(data['yearlyLeaves']);
            yearlyHolidayList = list.map((e) {
              return {
                "name": e['name'].toString(),
                // ensure days is int
                "days": (e['days'] is int)
                    ? e['days']
                    : int.tryParse(e['days'].toString()) ?? 0,
              };
            }).toList();
          }

          // load nationalHolidays as list of maps
          if (data['nationalHolidays'] != null) {
            final list = List.from(data['nationalHolidays']);
            _holidays = list.map((e) {
              return {
                "name": e['name'].toString(),
                "date": e['date'].toString(),
                "day": e['day'].toString(),
              };
            }).toList();
          }

          // clamp holidayIndex
          if (_holidays.isNotEmpty) {
            holidayIndex = holidayIndex % _holidays.length;
          } else {
            holidayIndex = 0;
          }
        });
      } else {
        // no doc exists - write defaults to Firestore so future loads fetch them
        await _updateFirestore(); // create doc with default values
      }
    } catch (e) {
      // ignore for now or show message
      // print('Error loading Firestore data: $e');
    }
  }

  Future<void> _updateFirestore() async {
    try {
      final docRef = _firestore.collection('admins').doc(adminDocId);

      // convert lists to plain maps/primitives for Firestore
      final yearlyLeavesToSave = yearlyHolidayList
          .map((e) => {"name": e['name'].toString(), "days": e['days']})
          .toList();

      final nationalHolidaysToSave = _holidays
          .map(
            (e) => {"name": e['name']!, "date": e['date']!, "day": e['day']!},
          )
          .toList();

      await docRef.set({
        "totalUsers": totalUsers,
        "pendingLeaves": pendingLeaves,
        "approvedLeaves": approvedLeaves,
        "totalUserList": totalUserList,
        "weeklyOff": selectedDays,
        "yearlyLeaves": yearlyLeavesToSave,
        "nationalHolidays": nationalHolidaysToSave,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // handle error (optional)
      // print('Error updating Firestore: $e');
    }
  }

  void nextHoliday() => setState(() {
    if (_holidays.isNotEmpty) {
      holidayIndex = (holidayIndex + 1) % _holidays.length;
    }
  });

  void prevHoliday() => setState(() {
    if (_holidays.isNotEmpty) {
      holidayIndex = (holidayIndex - 1 + _holidays.length) % _holidays.length;
    }
  });

  // ADD NEW NATIONAL HOLIDAY (and save to Firestore)
  void addNewHoliday() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController dateCtrl = TextEditingController();
    TextEditingController dayCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add National Holiday"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Holiday Name"),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: "Date (e.g., 26 Jan 2025)",
              ),
            ),
            TextField(
              controller: dayCtrl,
              decoration: const InputDecoration(
                labelText: "Day (e.g., Sunday)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty &&
                  dateCtrl.text.isNotEmpty &&
                  dayCtrl.text.isNotEmpty) {
                setState(() {
                  _holidays.add({
                    "name": nameCtrl.text.trim(),
                    "date": dateCtrl.text.trim(),
                    "day": dayCtrl.text.trim(),
                  });
                  holidayIndex = _holidays.length - 1;
                });

                await _updateFirestore();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // YEARLY HOLIDAY LIST (BOTTOM SHEET)
  void _showYearlyLeaveList() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController daysCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
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
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Yearly Holiday Types",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add new yearly leave type
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Add Yearly Leave Type"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Leave Type",
                                    ),
                                  ),
                                  TextField(
                                    controller: daysCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Days",
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (nameCtrl.text.isNotEmpty &&
                                        daysCtrl.text.isNotEmpty) {
                                      setSheet(() {
                                        yearlyHolidayList.add({
                                          "name": nameCtrl.text.trim(),
                                          "days":
                                              int.tryParse(
                                                daysCtrl.text.trim(),
                                              ) ??
                                              0,
                                        });
                                      });
                                      setState(() {});
                                      await _updateFirestore();
                                      nameCtrl.clear();
                                      daysCtrl.clear();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          size: 30,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: yearlyHolidayList.length,
                      itemBuilder: (_, index) {
                        final item = yearlyHolidayList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.beach_access,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${item['name']} - ${item['days']} days",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Edit item
                                  final editNameCtrl = TextEditingController(
                                    text: item['name'],
                                  );
                                  final editDaysCtrl = TextEditingController(
                                    text: item['days'].toString(),
                                  );

                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Edit Leave Type"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: editNameCtrl,
                                            decoration: const InputDecoration(
                                              labelText: "Name",
                                            ),
                                          ),
                                          TextField(
                                            controller: editDaysCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Days",
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            setSheet(() {
                                              yearlyHolidayList[index] = {
                                                "name": editNameCtrl.text
                                                    .trim(),
                                                "days":
                                                    int.tryParse(
                                                      editDaysCtrl.text.trim(),
                                                    ) ??
                                                    0,
                                              };
                                            });
                                            setState(() {});
                                            await _updateFirestore();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Save"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  setSheet(() {
                                    yearlyHolidayList.removeAt(index);
                                  });
                                  setState(() {});
                                  await _updateFirestore();
                                },
                              ),
                            ],
                          ),
                        );
                      },
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

  // Employee list modal (Add/Delete) — synced with Firestore
  void _showEmployeeList(BuildContext context) {
    TextEditingController empCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      const Text(
                        "Total Employees",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.teal,
                          size: 30,
                        ),
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
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (empCtrl.text.isNotEmpty) {
                                      setSheet(() {
                                        totalUserList.add(empCtrl.text.trim());
                                        totalUsers = totalUserList.length;
                                      });
                                      setState(() {});
                                      await _updateFirestore();
                                      empCtrl.clear();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                                child: Text(
                                  totalUserList[index],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  setSheet(() {
                                    totalUserList.removeAt(index);
                                    totalUsers = totalUserList.length;
                                  });
                                  setState(() {});
                                  await _updateFirestore();
                                },
                              ),
                            ],
                          ),
                        );
                      },
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

  // Weekly Off selector — sync changes to Firestore immediately
  void _showWeeklyOffSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text(
                    "Select Weekly Off",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
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
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                onChanged: (v) async {
                                  setSheet(() {
                                    if (v == true) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                  setState(() {});
                                  await _updateFirestore();
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  // Small dashboard card widget
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
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // handle case where holidays might be empty
    final h = _holidays.isNotEmpty
        ? _holidays[holidayIndex]
        : {"name": "", "date": "", "day": ""};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // FIRST ROW CARDS
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

            // SECOND ROW CARDS
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
                        onTap: _showYearlyLeaveList,
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

            const SizedBox(height: 25),

            // NATIONAL HOLIDAYS CONTAINER (with add)
            Stack(
              children: [
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
                      const Text(
                        "National Holidays",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        h["name"] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${h['date']} • ${h['day']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: prevHoliday,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: nextHoliday,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: addNewHoliday,
                    child: const Icon(
                      Icons.add_circle,
                      size: 28,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
