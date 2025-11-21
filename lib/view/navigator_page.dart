import 'package:flutter/material.dart';
import 'show_all_req.dart';
import 'leave_request.dart';
import 'submit_request.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  
  final List<Widget> _pages = const [
    DashboardPage(),
    MyWidget(),
    LeaveRequestPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4285F4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: 'Apply Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Requests',
          ),
        ],
      ),
    );
  }

}

