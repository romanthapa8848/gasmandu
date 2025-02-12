import 'package:flutter/material.dart';
import 'package:gasmandu/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://blvednbvnirmyumxqnqm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsdmVkbmJ2bmlybXl1bXhxbnFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkzNDMwNTUsImV4cCI6MjA1NDkxOTA1NX0.cXy1EvrEHd4LhbBL8MHHasguYw44gTMfU8BHPEEHlk8',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gasmandu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
