import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purrify/components/text_field.dart';
import 'package:purrify/config.dart';
import 'package:purrify/pages/home_page.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email, _password;
  late final WebViewController _controller;
  static const List<String> scopes = [
    'user-read-private',
    'playlist-read-private'
  ];

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (UrlChange change) {
            String authorizationCode =
                Uri.parse(change.url ?? '').queryParameters['code'] ?? '';
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage(authorizationCode: authorizationCode)),
              (route) => false,
            );
          },
        ),
      );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // await SpotifySdk.connectToSpotifyRemote(
    //     clientId: clientId, redirectUrl: redirectUrl);
    await authenticateAndRedirect();
  }

  Future<void> authenticateAndRedirect() async {
    final authorizationUrl = Uri.https(
      'accounts.spotify.com',
      '/authorize',
      <String, String>{
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUrl,
        'scope': scopes.join(' '),
      },
    );

    log(authorizationUrl.toString());
    await _controller.clearCache();
    await _controller.loadRequest(authorizationUrl);

    Dialog dialog = Dialog(
      surfaceTintColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Loading"),
          ],
        ),
      ),
    );
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return dialog;
        },
      );
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
