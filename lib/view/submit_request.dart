import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String defaultValue = "";

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
            // Leave Type Dropdown
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
                      selectedDate = DateFormat(
                        'dd MMM yyyy',
                      ).format(datePicked);
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate ?? 'Start Date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

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
                      selectedEndDate = DateFormat(
                        'dd MMM yyyy',
                      ).format(datePicked);
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedEndDate ?? 'End Date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

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

            Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: desController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Briefly describe your reason...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 10),

            FilledButton(
              onPressed: () async {
                if (selectedLeaveType == null || selectedLeaveType!.isEmpty) {
                  print('Please select a leave type');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a leave type')),
                  );
                  return;
                }
                if (selectedDurationType == null || selectedDurationType!.isEmpty){
                  print('Please select a duration');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a Duration')),
                  );
                  return;
                }
                if (desController.text.trim().isEmpty){
                  print('Please enter a description');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a description')),

                  );
                  return;
                }

                Map<String, dynamic> data = {
                  'name': 'shreya',
                  'start': selectedDate,
                  'end': selectedEndDate,
                  'type': selectedLeaveType,
                  'duration': selectedDurationType,
                  'description': desController.text,
                   
                };
                await FirebaseFirestore.instance
                    .collection("leave_request")
                    .add(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave request submitted successfully!')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 125,
                  vertical: 14,
                ),
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
          ],
        ),
      ),
    );
  }
}