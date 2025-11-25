import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/leave_request_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String? selectedLeaveType;
  String? selectedDate;
  String? selectedEndDate;
  String? selectedDurationType;

  TextEditingController desController = TextEditingController();

  final List<String> leaveType = [
    'NH/RH',
    'Sick',
    'Planned',
    'Unplanned',
    'Emergency',
    'Compensatory',
  ];

  final List<String> durationType = ['Half Day', 'Full Day'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apply Leave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 108, 185, 248),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Leave Type
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text(
                  'Leave Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                value: selectedLeaveType,
                items: leaveType.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLeaveType = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // Start Date
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: InkWell(
                onTap: () async {
                  DateTime? datePicked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1970),
                    lastDate: DateTime(2074),
                  );
                  if (datePicked != null) {
                    setState(() {
                      selectedDate =
                          DateFormat('dd MMM yyyy').format(datePicked);
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate ?? "Start Date",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // End Date
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: InkWell(
                onTap: () async {
                  DateTime? start = selectedDate != null
                      ? DateFormat('dd MMM yyyy').parse(selectedDate!)
                      : DateTime.now();

                  DateTime? datePicked = await showDatePicker(
                    context: context,
                    initialDate: start,
                    firstDate: start,
                    lastDate: DateTime(2074),
                  );

                  if (datePicked != null) {
                    setState(() {
                      selectedEndDate =
                          DateFormat('dd MMM yyyy').format(datePicked);
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedEndDate ?? "End Date",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Duration
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text(
                  'Duration Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                value: selectedDurationType,
                items: durationType.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDurationType = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Container(
              height: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: desController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Briefly describe your reason...",
                ),
              ),
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: () async {
                if (selectedLeaveType == null ||
                    selectedDurationType == null ||
                    selectedDate == null ||
                    selectedEndDate == null ||
                    desController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill all required fields")),
                  );
                  return;
                }

                // Fetch user data
                final prefs = await SharedPreferences.getInstance();
                String email = prefs.getString('email') ?? '';
                String username = prefs.getString('username') ?? '';

                // Calculate total days
                DateTime s = DateFormat('dd MMM yyyy').parse(selectedDate!);
                DateTime e = DateFormat('dd MMM yyyy').parse(selectedEndDate!);
                int totalDays = e.difference(s).inDays + 1;

                LeaveRequest leaveRequest = LeaveRequest(
                  name: username,
                  type: selectedLeaveType!,
                  duration: selectedDurationType!,
                  startDate: s,
                  endDate: e,
                  description: desController.text,
                  id: '',
                  status: 'Pending',
                  total: totalDays.toString(),
                );

                log(leaveRequest.toMap().toString());

                // Add to Firestore
                DocumentReference docRef = await FirebaseFirestore.instance
                    .collection("leave_request")
                    .add(leaveRequest.toMap());

                await docRef.update({'id': docRef.id});

                FirebaseFirestore.instance
                    .collection("user_data")
                    .doc(email)
                    .update({"requestid": docRef.id});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Leave request submitted successfully! ID: ${docRef.id}"),
                  ),
                );
              },

              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 130, vertical: 14),
              ),

              child: const Text(
                "Submit Request",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
