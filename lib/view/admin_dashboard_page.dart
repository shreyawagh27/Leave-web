import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

 // int totalUsers = 0;
  int? pendingLeaves = 0 ;
  int approvedLeaves = 0;

  //List totalUserList = ["Sanket", "Shreya", "Arati", "Vaishnavi", "Siddharth"];


    int totalUsers = 0;
List<Map<String, dynamic>> totalUserList = [];

  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  List<String> selectedDays = ["Thursday"];

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

  List<Map<String, String>> _holidays = [
    {"name": "Republic Day", "date": "26 Jan 2025", "day": "Sunday"},
    {"name": "Holi", "date": "29 Mar 2025", "day": "Saturday"},
    {"name": "Independence Day", "date": "15 Aug 2025", "day": "Friday"},
    {"name": "Diwali", "date": "20 Oct 2025", "day": "Monday"},
    {"name": "Christmas", "date": "25 Dec 2025", "day": "Thursday"},
  ];

  String _monthName(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }

  String _dayName(int weekday) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return days[weekday - 1];
  }

  int holidayIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchYearlyLeaves();
    _loadUserDataFromFirestore();
  }

  Future<void> saveWeeklyOffToFirestore() async {
    final docRef = FirebaseFirestore.instance
        .collection('admins')
        .doc('admin@gmail.com');

    await docRef.update({
      'weeklyOff': selectedDays,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> saveHolidayToFirestore(Map<String, dynamic> holiday) async {
    final docRef = FirebaseFirestore.instance
        .collection('admins')
        .doc('admin@gmail.com'); 

    await docRef.update({
      'nationalHolidays': FieldValue.arrayUnion([holiday]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveYearlyLeavesToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc('admin@gmail.com')
          .set({"yearlyLeaves": yearlyHolidayList}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yearly Leaves Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error Saving Data: $e")));
    }
  }

  Future<void> fetchYearlyLeaves() async {
    var doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc('admin@gmail.com')
        .get();

    if (doc.exists && doc.data()!.containsKey('yearlyLeaves')) {
      setState(() {
        yearlyHolidayList = List<Map<String, dynamic>>.from(
          doc['yearlyLeaves'],
        );
      });
    }
  }



Future<void> _loadUserDataFromFirestore() async {
  try {
    final pendingCountSnapshot = await FirebaseFirestore.instance
    .collection('leave_request')
    .where('status', isEqualTo: 'Pending')
    .count()
    .get();
    pendingLeaves = pendingCountSnapshot.count;

    final snapshot = await FirebaseFirestore.instance.collection('user_data').get();

    setState(() {
      totalUserList = snapshot.docs.map((doc) => doc.data()).toList();
      totalUsers = totalUserList.length;
    });
  } catch (e) {
    print("Error loading user data: $e");
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
            const SizedBox(height: 12),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Select Date"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  String formatted =
                      "${picked.day} ${_monthName(picked.month)} ${picked.year}";
                  setState(() {
                    dateCtrl.text = formatted;
                    dayCtrl.text = _dayName(picked.weekday);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dayCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Day"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  dateCtrl.text.isNotEmpty &&
                  dayCtrl.text.isNotEmpty) {
                final newHoliday = {
                  "name": nameCtrl.text,
                  "date": dateCtrl.text,
                  "day": dayCtrl.text,
                };

                setState(() {
                  _holidays.add(newHoliday);
                  saveYearlyLeavesToFirestore();
                });

                saveHolidayToFirestore(newHoliday);

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

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
                                              int.tryParse(daysCtrl.text) ?? 0,
                                        });
                                      });
                                      setState(() {});
                                      await saveYearlyLeavesToFirestore();

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
                          color: Colors.lightBlue,
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
                                Icons.event_note,
                                color: Colors.blueGrey,
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

                              /// EDIT BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
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
                                                      editDaysCtrl.text,
                                                    ) ??
                                                    0,
                                              };
                                            });
                                            setState(() {});
                                            await saveYearlyLeavesToFirestore();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Save"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              /// DELETE BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Leave Type"),
                                      content: Text(
                                        "Are you sure you want to delete '${item['name']}'?",
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
                                              yearlyHolidayList.removeAt(index);
                                            });
                                            setState(() {});
                                            await saveYearlyLeavesToFirestore();
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
void _showEmployeeList(BuildContext context) {
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
                const Text(
                  "Employee List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: totalUserList.length,
                    itemBuilder: (_, index) {
                      final user = totalUserList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.teal),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user["username"] ?? "Unknown User",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                                onChanged: (v) {
                                  setSheet(() {
                                    if (v == true)
                                      selectedDays.add(day);
                                    else
                                      selectedDays.remove(day);
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveWeeklyOffToFirestore();
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
            /// FIRST ROW
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

            /// SECOND ROW
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
