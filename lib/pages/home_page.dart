import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:purrify/config.dart';
import 'package:purrify/utilities/functions.dart';

class HomePage extends StatefulWidget {
  final String authorizationCode;

  const HomePage({super.key, required this.authorizationCode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final String _authorizationCode;
  String _accessToken = 'access token';
  String _bodyText = 'profile data';

  void _onNavItemTapped(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _authorizationCode = widget.authorizationCode;
  }

  Future<String> requestAccessToken(String authorizationCode) async {
    final tokenRequestUrl = Uri.https(nodeServerUrl, '/token-request');
    final response = await http.post(
      tokenRequestUrl,
      body: {'code': authorizationCode},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw response.body;
    }
  }

  Future<String> getProfile(accessToken) async {
    log('access token : $accessToken');
    final response = await http.get(
      Uri.https('api.spotify.com', '/v1/me'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw response.body;
    }
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
      appBar: AppBar(
        title: Text(
          'Purrify',
          style: GoogleFonts.shantellSans(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: Colors.grey,
            thickness: .1,
          ),
          TextButton(
            onPressed: () => {
              requestAccessToken(_authorizationCode).then((value) {
                setState(() {
                  _accessToken = value;
                });
              }).catchError((onError) {
                log(onError.toString());
              })
            },
            child: const Text('request access token'),
          ),
          Text(_accessToken),
          TextButton(
            onPressed: () => {
              getProfile(_accessToken).then((value) {
                setState(() {
                  _bodyText = value;
                });
              }).catchError((onError) {
                log(onError.toString());
              })
            },
            child: const Text('get profile'),
          ),
          Text(_bodyText),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
