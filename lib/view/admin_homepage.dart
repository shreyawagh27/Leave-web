import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalUsers = 24;
  int pendingLeaves = 5;
  int approvedLeaves = 18;
  int yearlyHolidays = 12;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> yearlyHolidayList = [
    'Planned Leave',
    'Unplanned Leave',
    'Sick Leave',
    'Emergency Leave',
    'NH/RH Leave',
    'Compensatory Leave',
  ];

  List<String> selectedDays = ["Saturday", "Sunday"];

  bool showDays = false;

  List<String> selectedHolidays = [];
  bool showHolidays = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_alt_outlined,
                              size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            totalUsers.toString(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Total Employees",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pending_actions_outlined,
                              size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            pendingLeaves.toString(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Pending Leave Requests",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_outlined,
                              size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            approvedLeaves.toString(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Approved Leaves",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.purple.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.holiday_village_outlined,
                              size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            yearlyHolidays.toString(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Yearly Holidays",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showYearlyHolidays(context);
                            },
                            child: const Icon(Icons.add,
                                size: 30, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

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
                            setState(() {
                              showDays = !showDays;
                            });
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
          ],
        ),
      ),
    );
  }

  void _showYearlyHolidays(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Yearly Holidays",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: yearlyHolidayList.length,
                      itemBuilder: (context, index) {
                        final String holiday = yearlyHolidayList[index];

                        return ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(holiday),
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
}
