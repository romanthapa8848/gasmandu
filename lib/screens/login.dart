import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gasmandu/screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'phone_number_enter_page.dart'; // Import PhoneNumberEnterPage

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // After sign-in, request location and notifications
        _requestPermissions();
        // Redirect to PhoneNumberEnterPage after login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PhoneNumberEnterPage()),
        );
      }
    });
  }

  Future<void> _googleSignIn() async {
    try {
      const webClientId =
          '965380428362-b62crmh8tnomru3c0ahvkcb4aj771lhv.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        dev.log('Google sign-in canceled by user.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Authentication error');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error) {
      dev.log('Google Login failed: $error');
    }
  }

  Future<void> _facebookSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
    } catch (error) {
      dev.log('Facebook Login failed: $error');
    }
  }

  // New function to request location and notification permissions
  Future<void> _requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Request notification permission
    var notificationStatus = await Permission.notification.request();
    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      dev.log("Notification permission denied.");
    }

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      dev.log("Location services are disabled.");
      return;
    }

    // Check if location permission is granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        dev.log("Location permission is permanently denied.");
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    dev.log("User's location: ${position.latitude}, ${position.longitude}");
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 140),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Gasmandu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _googleSignIn,
                    icon: Image.asset(
                      'assets/google.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _facebookSignIn,
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'Continue with Facebook',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _skipLogin,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
