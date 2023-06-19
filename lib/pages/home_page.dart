import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomNavigationBar = BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.purpleAccent,
      unselectedItemColor: Colors.white38,
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: false,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_rounded),
          label: 'Library',
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Purrify',
          style: GoogleFonts.shantellSans(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.add_circle,
              color: Colors.purpleAccent,
            ),
          )
        ],
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Divider(
            color: Colors.grey,
            thickness: .1,
          ),
          Text("hey"),
          Text("hey 712979127949"),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
