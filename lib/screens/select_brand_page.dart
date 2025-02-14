import 'package:flutter/material.dart';
import 'package:gasmandu/screens/home.dart'; // Ensure the HomeScreen is imported

class SelectBrandPage extends StatelessWidget {
  const SelectBrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Gas Brand'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please select your preferred gas brand',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Brand 1'),
                  onTap: () {
                    // Navigate to HomeScreen when Brand 1 is selected.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Brand 2'),
                  onTap: () {
                    // Navigate to HomeScreen when Brand 2 is selected.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Brand 3'),
                  onTap: () {
                    // Navigate to HomeScreen when Brand 3 is selected.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
