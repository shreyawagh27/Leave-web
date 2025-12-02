import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'show_all_req_admin_side.dart';
import 'admin_dashboard_page.dart';
import 'leave_request_admin.dart';
import 'show_all_req_user_side.dart';
import 'submit_request.dart';
import 'user_homepage_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String usertype = "User";

  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];

  final List<Widget> userPages = [
    UserHomePage(),
    HistoryPage(), 
    SubmitRequest(), 
  ];

  final List<BottomNavigationBarItem> userNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
    BottomNavigationBarItem(
      icon: Icon(Icons.edit_calendar),
      label: "Apply Leave",
    ),
  ];

  final List<Widget> adminPages = [
    AdminHomePage(),
    LeaveRequestPage(), 
    HistoryPage(), 
  ];

  final List<BottomNavigationBarItem> adminNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_rounded),
      label: "Requests",
    ),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
  ];

  @override
  void initState() {
    super.initState();
    getdata();
  }


  void getdata() async {
    final pref = await SharedPreferences.getInstance();
    usertype = pref.getString("usertype") ?? "User";

    setState(() {
      if (usertype == "Admin") {
        _pages = adminPages;
        _navItems = adminNavItems;
      } else {
        _pages = userPages;
        _navItems = userNavItems;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (_pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4285F4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
  
  // static HistoryPage() {}
}