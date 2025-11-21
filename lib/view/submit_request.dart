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
  int? totalDays; 

  final List<String> leaveType = [
    'NH/RH',
    'Sick',
    'Planned',
    'Unplanned',
    'Emergency',
    'Compensatory',
  ];

  final List<String> durationType = ['Half Day', 'Full Day'];

  void _calculateTotalDays() {
    if (selectedDate != null && selectedEndDate != null) {
      DateTime start = DateFormat('dd MMM yyyy').parse(selectedDate!);
      DateTime end = DateFormat('dd MMM yyyy').parse(selectedEndDate!);
      int days = end.difference(start).inDays + 1; 
      setState(() {
        totalDays = days;
      });
    }
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ===== Leave Type =====
            _buildShadowContainer(
              context,
              DropdownButton<String>(
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

            const SizedBox(height: 16),

            // ===== Start Date =====
            _buildShadowContainer(
              context,
              InkWell(
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
                    _calculateTotalDays();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.black54),
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

            const SizedBox(height: 16),

            // ===== End Date =====
            _buildShadowContainer(
              context,
              GestureDetector(
                onTap: () async {
                  DateTime? start = selectedDate != null
                      ? DateFormat('dd MMM yyyy').parse(selectedDate!)
                      : DateTime(1970);

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
                    _calculateTotalDays();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.black54),
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

            const SizedBox(height: 16),

            // ===== Total Days =====
            if (totalDays != null)
              _buildShadowContainer(
                context,
                Center(
                  child: Text(
                    'Total Days: $totalDays',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ===== Duration Type =====
            _buildShadowContainer(
              context,
              DropdownButton<String>(
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

            const SizedBox(height: 16),

            // ===== Description =====
            _buildShadowContainer(
              context,
              TextField(
                controller: desController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe your reason...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              height: 80,
            ),

            const SizedBox(height: 16),

            // ===== Submit Button =====
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (selectedLeaveType == null || selectedLeaveType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a leave type'),
                      ),
                    );
                    return;
                  }
                  if (selectedDurationType == null ||
                      selectedDurationType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a Duration')),
                    );
                    return;
                  }
                  if (desController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a description'),
                      ),
                    );
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  String email = prefs.getString('email') ?? '';
                  String username = prefs.getString('username') ?? '';

                  LeaveRequest leaveRequest = LeaveRequest(
                    name: username,
                    type: selectedLeaveType!,
                    duration: selectedDurationType!,
                    startDate: DateFormat('dd MMM yyyy').parse(selectedDate!),
                    endDate: DateFormat('dd MMM yyyy').parse(selectedEndDate!),
                    description: desController.text,
                    id: '',
                    status: 'Pending',
                    total: '$totalDays',
                  );

                  log(leaveRequest.toMap().toString());

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
                      content: Text(
                        'Leave request submitted successfully! (ID: ${docRef.id})',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowContainer(
    BuildContext context,
    Widget child, {
    double height = 50,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
