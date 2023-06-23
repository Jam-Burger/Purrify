import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purrify/pages/experiments_page.dart';
import 'package:purrify/pages/fragments/home_fragment.dart';
import 'package:purrify/pages/fragments/library_fragment.dart';
import 'package:purrify/pages/fragments/search_fragment.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late Widget _currentFragment;
  final Set<Widget> _fragments = {
    const HomeFragment(),
    const SearchFragment(),
    const LibraryFragment(),
  };

  void _onNavItemTapped(index) {
    setState(() {
      _selectedIndex = index;
      _currentFragment = _fragments.elementAt(index);
    });
  }

  @override
  void initState() {
    _currentFragment = _fragments.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(
        'Purrify',
        style: GoogleFonts.shantellSans(
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ExperimentsPage()));
          },
          icon: const Icon(Icons.code_off),
        )
      ],
    );
    final BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.purpleAccent,
      unselectedItemColor: Colors.white38,
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: false,
      onTap: _onNavItemTapped,
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
      appBar: _selectedIndex == 0 ? appBar : null,
      body: SafeArea(child: _currentFragment),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
