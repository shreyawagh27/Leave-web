import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/leave_request_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitRequest extends StatefulWidget {
  const SubmitRequest({super.key});

  @override
  State<SubmitRequest> createState() => _SubmitRequestState();
}

class _SubmitRequestState extends State<SubmitRequest> {
  String? selectedLeaveType;
  String? selectedDate;
  String? selectedEndDate;
  String? selectedDurationType;
  TextEditingController desController = TextEditingController();

  double? dayCount; // ✅ FIX: ADDED THIS

  List<Map<String, dynamic>> leaveTypes = [];
  List<String> leaveType = [
    'Sick',
    'Planned',
    'Unplanned/UnPaid',
    'Emergency',
    
  ];

  final List<String> durationType = ['Half Day', 'Full Day'];

  String defaultValue = "";

  void fetchData() async {
    final doc = await FirebaseFirestore.instance
        .collection("admins")
        .doc("admin@gmail.com")
        .get();

    final leaveTypesData = List<Map<String, dynamic>>.from(
      doc.data()?["yearlyLeaves"] ?? [],
    );

    leaveType = leaveTypesData.map((element) {
      return element['name'].toString();
    }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void calculateDayCount() {
    if (selectedDate == null || selectedEndDate == null) return;

    DateTime start = DateFormat('dd MMM yyyy').parse(selectedDate!);
    DateTime end = DateFormat('dd MMM yyyy').parse(selectedEndDate!);

    setState(() {
      dayCount = end.difference(start).inDays + 1;
    });
  }

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// LEAVE TYPE
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              alignment: Alignment.center,
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

            /// START DATE
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              alignment: Alignment.center,
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
                    calculateDayCount();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate ?? 'Start Date',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// END DATE
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  DateTime start = selectedDate != null
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
                    calculateDayCount();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      selectedEndDate ?? 'End Date',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// SHOW DAY COUNT (FIXED — cannot return NULL)
            if (dayCount != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.black54),
                ),
                child: Text(
                  "Total Days: $dayCount",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            /// DURATION TYPE
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              alignment: Alignment.center,
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

            /// DESCRIPTION
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: desController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe your reason...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// SUBMIT BUTTON
            FilledButton(
              child: const Text("Submit"),
              onPressed: () async {
                if (selectedLeaveType == null ||
                    selectedDurationType == null ||
                    selectedDate == null ||
                    selectedEndDate == null ||
                    desController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all fields properly')),
                  );
                  return;
                }

                DateTime start =
                    DateFormat('dd MMM yyyy').parse(selectedDate!);
                DateTime end =
                    DateFormat('dd MMM yyyy').parse(selectedEndDate!);

                double finalDayCount = dayCount ?? 1;
                if (selectedDurationType == "Half Day") {
                  finalDayCount = 0.5;
                }

                final prefs = await SharedPreferences.getInstance();
                String email = prefs.getString('email') ?? '';
                String username = prefs.getString('username') ?? '';

                LeaveRequest leaveRequest = LeaveRequest(
                  name: username,
                  type: selectedLeaveType!,
                  email: email,
                  duration: selectedDurationType!,
                  startDate: start,
                  endDate: end,
                  description: desController.text,
                  id: '',
                  status: 'Pending',
                  dayCount: finalDayCount,
                );

                DocumentReference docRef = await FirebaseFirestore.instance
                    .collection("leave_request")
                    .add(leaveRequest.toMap());

                await docRef.update({'id': docRef.id});

                await FirebaseFirestore.instance
                    .collection("user_data")
                    .doc(email)
                    .update({"requestid": docRef.id});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Leave request submitted! ID: ${docRef.id}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
