import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'; // For flag and country code input
import 'select_brand_page.dart'; // Import SelectBrandPage

class PhoneNumberEnterPage extends StatefulWidget {
  const PhoneNumberEnterPage({super.key});

  @override
  PhoneNumberEnterPageState createState() => PhoneNumberEnterPageState();
}

class PhoneNumberEnterPageState extends State<PhoneNumberEnterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length != 10 || !RegExp(r'^[9][0-9]{9}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit Nepalese phone number starting with 9';
    }
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone Number: ${_phoneController.text}')),
      );
      // Navigate to SelectBrandPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SelectBrandPage()),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please enter your phone number',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  _phoneController.text = number.phoneNumber ?? '';
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIAL_CODE,
                  leadingPadding: 10,
                ),
                initialValue: PhoneNumber(isoCode: 'NP'),
                textFieldController: _phoneController,
                inputDecoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '9XXXXXXXXX',
                  border: const OutlineInputBorder(),
                  prefixText: '+977 ',
                ),
                validator: _validatePhoneNumber,
                maxLength: 10, // Limiting phone number to 10 digits
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
