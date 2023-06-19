import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:purrify/components/text_field.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:purrify/utilities/routes.dart';
import 'package:url_launcher/url_launcher.dart';

const String clientId = '6479d965a2d2426abcb83dbed9bff155';
const String redirectUri = 'https://github.com/Jam-Burger/Purrify';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email, _password;
  static const List<String> scopes = [
    'user-read-private',
    'playlist-read-private'
  ];

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _email.text;
    final String password = _password.text;
    await authenticateWithSpotify();
  }

  Future<void> authenticateWithSpotify() async {
    final authorizationUrl = Uri.https(
      'accounts.spotify.com',
      '/authorize',
      <String, String>{
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': "https://homo.xxx/",
        'scope': scopes.join(' '),
      },
    );
    log(authorizationUrl.toString());
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
      if (mounted) {
        Navigator.pushNamed(context, homeRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/icon/logo-round.png',
                height: 100,
              ),
              Text(
                'Purrify',
                textAlign: TextAlign.center,
                style: GoogleFonts.shantellSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 50),
              TextFieldTemplate(
                hintText: 'email or username',
                controller: _email,
              ),
              TextFieldTemplate(
                hintText: 'password',
                controller: _password,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _login();
                  // Navigator.of(context).pushNamed(homeRoute);
                },
                child: const Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RedirectPage extends StatefulWidget {
  final Uri redirectUri;

  const RedirectPage({super.key, required this.redirectUri});

  @override
  State<RedirectPage> createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  @override
  void initState() {
    super.initState();
    handleAuthorization();
  }

  Future<String> requestAccessToken(String authorizationCode) async {
    final tokenUrl = Uri.https('accounts.spotify.com', '/api/token');

    final response = await http.post(
      tokenUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': authorizationCode,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'client_secret': 'a6a7b6ab7e6446c4a4a2da53ca5d8db6',
      },
    );

    if (response.statusCode == 200) {
      final accessToken = jsonDecode(response.body)['access_token'];
      return accessToken;
    } else {
      throw 'Failed to obtain access token.';
    }
  }

  Future<void> handleAuthorization() async {
    final authorizationCode = widget.redirectUri.queryParameters['code'];

    if (authorizationCode != null) {
      try {
        final accessToken = await requestAccessToken(authorizationCode);
        // Use the access token for further API requests
        print('Access Token: $accessToken');
      } catch (e) {
        print('Authorization Error: $e');
      }
    } else {
      print('Authorization code is missing.');
    }

    // Close the redirect page
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redirecting...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
