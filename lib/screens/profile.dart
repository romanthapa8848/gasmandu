import 'package:flutter/material.dart';
import 'package:gasmandu/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Sign-out function
  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    // Ensure the widget is still mounted before navigating
    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userImage =
        user?.userMetadata?['avatar_url'] ?? "assets/profile_placeholder.png";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userImage),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.userMetadata?['full_name'] ?? 'User Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order History
            const Text(
              "Order History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual order count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text("Order #${index + 1}"),
                    subtitle: const Text("Delivered on 12th Feb 2025"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {}, // Navigate to order details
                  );
                },
              ),
            ),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () => _signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
