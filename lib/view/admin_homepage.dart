import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final String adminDocId = "admin@gmail.com";

  bool showDays = false;
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

  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;
  int yearlyHolidays = 0;
  List<Map<String, dynamic>> holidays = [
    {"name": "New Year", "date": DateTime(2025, 1, 1)},
    {"name": "Independence Day", "date": DateTime(2025, 8, 15)},
  ];
  List<Map<String, dynamic>> leaveTypes = [
    {"id": "1", "name": "Casual Leave", "days": 12},
    {"id": "2", "name": "Sick Leave", "days": 8},
  ];

  void addHolidayPopup() {
    TextEditingController nameCtrl = TextEditingController();
    DateTime? pickedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Holiday"),
        content: StatefulBuilder(
          builder: (context, setSB) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Holiday Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      pickedDate == null
                          ? "No date"
                          : pickedDate.toString().split(" ").first,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) setSB(() => pickedDate = date);
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (pickedDate != null && nameCtrl.text.isNotEmpty) {
                setState(() {
                  holidays.add({"name": nameCtrl.text, "date": pickedDate});
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void editHolidayPopup(Map<String, dynamic> holiday) {
    TextEditingController nameCtrl = TextEditingController(
      text: holiday["name"],
    );
    DateTime selectedDate = holiday["date"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Holiday"),
        content: StatefulBuilder(
          builder: (context, setSB) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Holiday Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(selectedDate.toString().split(" ").first),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (newDate != null)
                          setSB(() => selectedDate = newDate);
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                holidays.remove(holiday);
                holidays.add({"name": nameCtrl.text, "date": selectedDate});
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void addLeaveTypePopup() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController daysCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Leave Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Leave Type Name"),
            ),
            TextField(
              controller: daysCtrl,
              decoration: const InputDecoration(labelText: "Days per year"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                leaveTypes.add({
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "name": nameCtrl.text,
                  "days": int.tryParse(daysCtrl.text.trim()) ?? 0,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void editLeaveTypePopup(Map<String, dynamic> leaveType) {
    TextEditingController nameCtrl = TextEditingController(
      text: leaveType["name"],
    );
    TextEditingController daysCtrl = TextEditingController(
      text: leaveType["days"].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Leave Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Leave Type Name"),
            ),
            TextField(
              controller: daysCtrl,
              decoration: const InputDecoration(labelText: "Days"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                leaveTypes.remove(leaveType);
                leaveTypes.add({
                  "id": leaveType["id"],
                  "name": nameCtrl.text,
                  "days": int.tryParse(daysCtrl.text.trim()) ?? 0,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget smallBox(Color color, IconData icon, int count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 5),
            Text(count.toString(), style: const TextStyle(fontSize: 20)),
            Text(label),
          ],
        ),
      ),
    );
  }

  void showHolidaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "National Holidays",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: addHolidayPopup,
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: holidays.isEmpty
                        ? const Center(child: Text("No holidays added"))
                        : ListView.builder(
                            controller: controller,
                            itemCount: holidays.length,
                            itemBuilder: (context, index) {
                              final h = holidays[index];
                              final date = h["date"] as DateTime;
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text(h["name"]),
                                  subtitle: Text(
                                    date.toString().split(" ").first,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => editHolidayPopup(h),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            holidays.remove(h);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showLeaveTypesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Leave Types",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: addLeaveTypePopup,
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: leaveTypes.isEmpty
                        ? const Center(child: Text("No leave types added"))
                        : ListView.builder(
                            controller: controller,
                            itemCount: leaveTypes.length,
                            itemBuilder: (context, index) {
                              final item = leaveTypes[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.event_available),
                                  title: Text(
                                    item["name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${item["days"]} days per year",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () =>
                                            editLeaveTypePopup(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            leaveTypes.remove(item);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  smallBox(
                    Colors.orange.shade100,
                    Icons.pending_actions_outlined,
                    pendingCount,
                    "Pending",
                  ),
                  const SizedBox(width: 10),
                  smallBox(
                    Colors.green.shade100,
                    Icons.verified_outlined,
                    approvedCount,
                    "Approved",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  smallBox(
                    Colors.red.shade100,
                    Icons.close,
                    rejectedCount,
                    "Rejected",
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showLeaveTypesSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month, size: 26),
                            const SizedBox(height: 5),
                            Text(
                              yearlyHolidays.toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const Text("Yearly Holidays"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              sectionHeader(
                "National Holidays",
                () => showHolidaySheet(context),
              ),
              const SizedBox(height: 20),
              sectionHeader("Leave Types", () => showLeaveTypesSheet(context)),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade200, width: 1.2),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Weekly Off",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                selectedDays.join(", "),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              showDays
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.teal,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() => showDays = !showDays);
                            },
                          ),
                        ],
                      ),
                      if (showDays)
                        Column(
                          children: days.map((day) {
                            return CheckboxListTile(
                              title: Text(day),
                              value: selectedDays.contains(day),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Weekly off updated: ${selectedDays.join(', ')}",
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title, VoidCallback onAdd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(onPressed: onAdd, child: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
