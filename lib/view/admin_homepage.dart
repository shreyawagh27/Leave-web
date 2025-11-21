import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final String adminDocId = "admin@gmail.com";

  // FETCH NATIONAL HOLIDAYS
  Stream<List<Map<String, dynamic>>> fetchHolidays() {
    return FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        List<dynamic> list = doc.data()?["national_holiday"] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    });
  }

  // FETCH LEAVE TYPES
  Stream<List<Map<String, dynamic>>> fetchLeaveTypes() {
    return FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        List<dynamic> list = doc.data()?["leave_types"] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    });
  }

  // LIVE COUNT STREAMS
  Stream<int> fetchApprovedCount() {
    return FirebaseFirestore.instance
        .collection('leave_request')
        .where('status', isEqualTo: 'Approved')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> fetchPendingCount() {
    return FirebaseFirestore.instance
        .collection('leave_request')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> fetchRejectedCount() {
    return FirebaseFirestore.instance
        .collection('leave_request')
        .where('status', isEqualTo: 'Rejected')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ADD HOLIDAY
  void openAddHolidayDialog() {
    TextEditingController nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Holiday"),
        content: StatefulBuilder(
          builder: (context, setSB) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Holiday Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      selectedDate == null
                          ? "Pick Date"
                          : selectedDate.toString().split(" ").first,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) {
                          setSB(() => selectedDate = picked);
                        }
                      },
                      child: const Text("Select"),
                    )
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (selectedDate != null &&
                  nameController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("admin_data")
                    .doc(adminDocId)
                    .update({
                  "national_holiday": FieldValue.arrayUnion([
                    {
                      "date": Timestamp.fromDate(selectedDate!),
                      "name": nameController.text.trim(),
                    }
                  ])
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // DELETE HOLIDAY
  Future<void> deleteHoliday(Map<String, dynamic> holiday) async {
    await FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .update({
      "national_holiday": FieldValue.arrayRemove([holiday])
    });
  }

  // EDIT HOLIDAY
  Future<void> editHoliday(
      Map<String, dynamic> oldHoliday, DateTime newDate, String newName) async {
    await FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .update({
      "national_holiday": FieldValue.arrayRemove([oldHoliday])
    });

    await FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .update({
      "national_holiday": FieldValue.arrayUnion([
        {
          "date": Timestamp.fromDate(newDate),
          "name": newName,
        }
      ])
    });
  }

  // EDIT HOLIDAY POPUP
  void openEditDialog(Map<String, dynamic> holiday) {
    TextEditingController nameController =
        TextEditingController(text: holiday["name"]);
    DateTime selectedDate = holiday["date"].toDate();

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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Holiday Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(selectedDate.toString().split(" ").first),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) {
                          setSB(() => selectedDate = picked);
                        }
                      },
                      child: const Text("Pick Date"),
                    )
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await editHoliday(
                  holiday, selectedDate, nameController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ADD LEAVE TYPE
  void openAddLeaveTypeDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Leave Type"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Leave Type Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("admin_data")
                    .doc(adminDocId)
                    .update({
                  "leave_types": FieldValue.arrayUnion([
                    {"name": nameController.text.trim()}
                  ])
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // DELETE LEAVE TYPE
  Future<void> deleteLeaveType(Map<String, dynamic> type) async {
    await FirebaseFirestore.instance
        .collection("admin_data")
        .doc(adminDocId)
        .update({
      "leave_types": FieldValue.arrayRemove([type])
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
        
      // ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TOP CARDS
            Row(
              children: [
                // PENDING LEAVES
                Expanded(
                  child: Card(
                    color: Colors.orange.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.pending_actions_outlined,
                              size: 36, color: Colors.black54),

                          StreamBuilder<int>(
                            stream: fetchPendingCount(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Text("-",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold));
                              }
                              return Text(
                                snap.data.toString(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),

                          const Text("Pending Leaves"),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // APPROVED LEAVES
                Expanded(
                  child: Card(
                    color: Colors.green.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.verified_outlined,
                              size: 36, color: Colors.black54),

                          StreamBuilder<int>(
                            stream: fetchApprovedCount(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Text("-",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold));
                              }
                              return Text(
                                snap.data.toString(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),

                          const Text("Approved Leaves"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // REJECTED LEAVES CARD (optional)
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.close,
                              size: 36, color: Colors.black54),

                          StreamBuilder<int>(
                            stream: fetchRejectedCount(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Text("-",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold));
                              }
                              return Text(
                                snap.data.toString(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),

                          const Text("Rejected Leaves"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // HOLIDAY LIST
            // NATIONAL HOLIDAY CONTAINER HEADING
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  decoration: BoxDecoration(
    color: Colors.blue.shade100,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "National Holidays",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
        ],
      ),

      // ADD HOLIDAY BUTTON
      ElevatedButton.icon(
        onPressed: openAddHolidayDialog,
        icon: const Icon(Icons.add),
        label: const Text(""),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    ],
  ),
),
const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchHolidays(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final holidays = snapshot.data!;

                  if (holidays.isEmpty) {
                    return const Center(child: Text("No holidays added"));
                  }

                  return ListView.builder(
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];
                      String date =
                          holiday["date"].toDate().toString().split(" ").first;

                      return Card(
                        child: ListTile(
                          title: Text(holiday["name"]),
                          subtitle: Text(date),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      openEditDialog(holiday)),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => deleteHoliday(holiday),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // LEAVE TYPES
            // LEAVE TYPES CONTAINER HEADING
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  decoration: BoxDecoration(
    color: Colors.blue.shade100,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Leave Types",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
        ],
      ),

      // ADD LEAVE TYPE BUTTON
      ElevatedButton.icon(
        onPressed: openAddLeaveTypeDialog,
        icon: const Icon(Icons.add),
        label: const Text(""),
        style: ElevatedButton.styleFrom(
           backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    ],
  ),
),
const SizedBox(height: 10),


            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchLeaveTypes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final types = snapshot.data!;

                  if (types.isEmpty) {
                    return const Center(child: Text("No leave types added"));
                  }

                  return ListView.builder(
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final type = types[index];

                      return Card(
                        child: ListTile(
                          title: Text(type["name"]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteLeaveType(type),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
