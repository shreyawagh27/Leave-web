import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> myWeeklyOff = [4];

  List<DateTime> myApprovedLeaves = [
    DateTime(2025, 12, 31),
    DateTime(2025, 12, 15),
    DateTime(2026, 1, 4),
  ];

  List<Map<String, dynamic>> nationalHolidays = [
    {"date": DateTime(2025, 1, 26), "name": "Republic Day"},
    {
      "date": DateTime(2025, 2, 19),
      "name": "Chhatrapati Shivaji Maharaj Jayanti",
    },
    {"date": DateTime(2025, 2, 26), "name": "Maha Shivaratri"},
    {"date": DateTime(2025, 3, 14), "name": "Holi (Second Day)"},
    {"date": DateTime(2025, 3, 30), "name": "Gudi Padwa"},
    {"date": DateTime(2025, 3, 31), "name": "Id ul Fitr"},
    {"date": DateTime(2025, 4, 6), "name": "Ram Navami"},
    {"date": DateTime(2025, 4, 10), "name": "Mahavir Jayanti"},
    {"date": DateTime(2025, 4, 14), "name": "Dr Babasaheb Ambedkar Jayanti"},
    {"date": DateTime(2025, 4, 18), "name": "Good Friday"},
    {"date": DateTime(2025, 5, 1), "name": "Maharashtra Day"},
    {"date": DateTime(2025, 5, 12), "name": "Buddha Purnima"},
    {"date": DateTime(2025, 6, 7), "name": "Bakrid / Eid al Adha"},
    {"date": DateTime(2025, 7, 6), "name": "Muharram"},
    {"date": DateTime(2025, 8, 15), "name": "Independence Day"},
    {"date": DateTime(2025, 8, 15), "name": "Parsi New Year"},
    {"date": DateTime(2025, 8, 27), "name": "Ganesh Chaturthi"},
    {"date": DateTime(2025, 9, 5), "name": "Eid e Milad"},
    {"date": DateTime(2025, 10, 2), "name": "Gandhi Jayanti"},
    {"date": DateTime(2025, 10, 21), "name": "Diwali Amavasya"},
    {"date": DateTime(2025, 10, 22), "name": "Diwali Padwa"},
    {"date": DateTime(2025, 11, 5), "name": "Guru Nanak Jayanti"},
    {"date": DateTime(2025, 12, 25), "name": "Christmas"},
  ];

  late int _selectedYear;
  late int _selectedMonth;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = _focusedDay.year;
    _selectedMonth = _focusedDay.month;
  }

  void _updateCalendar() {
    setState(() {
      _focusedDay = DateTime(_selectedYear, _selectedMonth, 1);
    });
  }

  List<Map<String, dynamic>> getMonthlyHolidays() {
    return nationalHolidays.where((holiday) {
      return holiday['date'].year == _selectedYear &&
          holiday['date'].month == _selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(months[index]),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedMonth = value;
                      _updateCalendar();
                    }
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(30, (index) {
                    int year = DateTime.now().year - 10 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedYear = value;
                      _updateCalendar();
                    }
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          Expanded(
            child: TableCalendar(
              onPageChanged: (focusedDay) {
                setState(() {
                  _selectedMonth = focusedDay.month;
                  _selectedYear = focusedDay.year;
                });
              },
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              headerVisible: true,
              daysOfWeekVisible: true,

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color.fromARGB(179, 64, 63, 63),
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Color.fromARGB(179, 60, 60, 60),
                  fontWeight: FontWeight.bold,
                ),
              ),

              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // WEEKLY OFF
                  if (myWeeklyOff.contains(day.weekday)) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  // APPROVED LEAVES
                  if (myApprovedLeaves.any((date) => isSameDay(date, day))) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  // NATIONAL HOLIDAYS
                  if (nationalHolidays.any(
                    (holiday) => isSameDay(holiday["date"], day),
                  )) {
                    final holiday = nationalHolidays.firstWhere(
                      (holiday) => isSameDay(holiday["date"], day),
                    );

                    return Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: holiday["name"],
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            holiday["name"],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // DEFAULT DAY
                  return Center(
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),

              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
