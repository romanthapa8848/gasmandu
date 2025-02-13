import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:flutter/services.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Dropdown for Gas Brands
  final List<String> _gasBrands = [
    'Brand A',
    'Brand B',
    'Brand C',
  ];
  String? _selectedGasBrand;

  // Floor selection list
  final List<String> _floors = [
    'Ground',
    '1st Floor',
    '2nd Floor',
    '3rd Floor',
    '4th Floor',
    '5th Floor',
    '6th Floor',
    '7th Floor',
    '8th Floor',
    '9th Floor',
    '10th Floor'
  ];
  String _selectedFloor = 'Ground';

  // Delivery Date
  DateTime? _selectedDate;

  // Payment method selection (default to Cash on Delivery)
  String _paymentMethod = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    _fetchDeliveryAddress();
  }

  Future<void> _fetchDeliveryAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _addressController.text = 'Location services disabled';
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _addressController.text = 'Location permission denied';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        setState(() {
          _addressController.text = '${place.locality}, ${place.country}';
        });
      } else {
        _addressController.text = 'Location not found';
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Failed to fetch location';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    // Show Date Picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now, // Use selected date or current date
      firstDate: now,
      lastDate:
          now.add(const Duration(days: 365)), // Set max date to 1 year from now
    );

    // If a date is selected, format it and update the controller
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Process the order (here, we simply show a confirmation dialog)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Order Placed'),
            content: Text(
              'Order Details:\n'
              'Gas Brand: $_selectedGasBrand\n'
              'Delivery Address: ${_addressController.text}\n'
              'Phone: ${_phoneController.text}\n'
              'Floor: $_selectedFloor\n'
              'Delivery Date: ${_dateController.text}\n'
              'Payment: $_paymentMethod',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed so there's no top "Place Order" section
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gas Brand Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Gas Brand',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  items: _gasBrands
                      .map((brand) => DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGasBrand = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a gas brand' : null,
                ),
                const SizedBox(height: 20),
                // Delivery Address (read-only)
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 20),
                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                        10), // Limit input to 10 characters
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter phone number';
                    } else if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Floor Selection Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Floor',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  value: _selectedFloor,
                  items: _floors
                      .map((floor) => DropdownMenuItem<String>(
                            value: floor,
                            child: Text(floor),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFloor = value!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a floor' : null,
                ),
                const SizedBox(height: 20),
                // Delivery Date Selection (Date Picker)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Date',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Select a delivery date'
                      : null,
                ),
                const SizedBox(height: 20),
                // Payment Method (Radio Buttons)
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Esewa'),
                      value: 'Esewa',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Khalti'),
                      value: 'Khalti',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'Cash on Delivery',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
// Submit Order Button (bottom of the body)
                Center(
                  child: ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFFF6F61), // Gas cylinderish reddish light
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // More curvy button
                      ),
                      elevation: 5, // Slight shadow for depth
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Ensures good contrast
                      ),
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
