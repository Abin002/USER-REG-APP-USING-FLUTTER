// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_smartech/views/utility_files/logo_picker.dart';
import 'package:ui_smartech/views/widgets/printservices.dart';
import 'package:ui_smartech/views/widgets/registration_form.dart';
import 'package:ui_smartech/views/widgets/usb_printer.dart';

import 'utility_files/visitorloginalert.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

RegistrationFormState reg = RegistrationFormState();

class _ScreenHomeState extends State<ScreenHome> {
  late String _selectedLogoPath = '';
  late LogoPicker _logoPicker; // Declare the logo picker
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSelectedLogoPath();
    _logoPicker = LogoPicker(
      context: context,
      onLogoSelected: _handleLogoSelected,
    );
  }

  void _handleLogoSelected(String selectedLogoPath) {
    setState(() {
      _selectedLogoPath = selectedLogoPath;
    });
  }

  Future<void> _pickLogo() async {
    _logoPicker.pickLogo();
  }

  Future<void> _loadSelectedLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    final logoPath = prefs.getString('selectedLogoPath') ?? '';

    setState(() {
      _selectedLogoPath = logoPath;
    });
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsbPrinterScreen(),
                      ),
                    );
                  },
                  child: const Text('USB PRINTER'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrintServices(),
                      ),
                    );
                  },
                  child: const Text('BLUETOOTH PRINTER'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeLogo() async {
    _pickLogo(); // Call the function to pick a new logo
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard when tapping outside
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Center(
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onDoubleTap: _showAlertDialog,
                        onLongPress:
                            _changeLogo, // Call the function to change the logo
                        child: ClipOval(
                          child: Container(
                            color: Colors.transparent,
                            width: 95,
                            height: 95,
                            child: _selectedLogoPath.isNotEmpty
                                ? ClipOval(
                                    child: Image.file(
                                      File(_selectedLogoPath),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/edit.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onDoubleTap: () {
                          reg.connectToUsbPrinter(context);
                        },
                        onLongPress: () {
                          print('Visitor Information Clicked!');
                          LoginFunctions.showLoginAlertBox(
                              context, _auth); // Call login function
                        },
                        child: const Text(
                          'VISITOR INFORMATION',
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9489F5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const SingleChildScrollView(
                        child: RegistrationForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
