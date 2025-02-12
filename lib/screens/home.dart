import 'package:flutter/material.dart';
import 'package:gasmandu/screens/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import 'brands.dart'; // Ensure this file defines BrandsPage
import 'rates.dart'; // Ensure this file defines RatesPage
import 'profile.dart'; // Ensure this file defines ProfilePage

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  String _locationText = 'Fetching location...';
  String? profileImageUrl;
  String fullName = 'User';

  // Removed the `const` keyword from the list
  final List<Widget> _pages = [
    HomePage(), // Ensure HomePage is defined here or imported.
    BrandsPage(),
    OrderScreen(),
    RatesPage(),
    ProfilePage(), // ProfilePage now contains the sign-out button.
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    final user = supabase.auth.currentUser;
    setState(() {
      profileImageUrl = user?.userMetadata?['avatar_url'];
      fullName = user?.userMetadata?['full_name'] ?? 'User';
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationText = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationText = 'Location permission denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _locationText = '${place.locality}, ${place.country}';
        });
      } else {
        setState(() {
          _locationText = 'Location not found';
        });
      }
    } catch (e) {
      setState(() {
        _locationText = 'Failed to fetch location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a lighter reddish color
    final Color gasCylinderLightRed = const Color(0xFFF44336);

    return Scaffold(
      appBar: AppBar(
        title: Text(_locationText),
      ),
      body: SafeArea(
        child: Center(
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: gasCylinderLightRed, // Use the lighter red
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Brands',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/logo.png',
                width: 30,
                height: 30,
                // Remove the color property to keep the original logo color
              ),
            ),
            label: 'Order',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Rates',
          ),
          BottomNavigationBarItem(
            icon: profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      profileImageUrl!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple welcome page with logo and tagline.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', height: 140),
        const SizedBox(height: 24),
        Text(
          'Welcome to Gasmandu!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your one-stop app for on-demand gas delivery!',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
