import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/logo_picker.dart';
import 'registration_form.dart';
import 'visitorslist.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  late String _selectedLogoPath = '';
  late LogoPicker _logoPicker; // Declare the logo picker

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        color: Colors.transparent,
                        width: 95,
                        height: 95,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onLongPress: _pickLogo,
                          child: _selectedLogoPath.isNotEmpty
                              ? ClipOval(
                                  child: Image.file(File(_selectedLogoPath),
                                      fit: BoxFit.cover),
                                )
                              : Image.asset('assets/edit.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onLongPress: () {
                        print('Visitor Information Clicked!');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const VisitorsList()));
                      },
                      child: const Text(
                        'Visitor Information',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9489F5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SingleChildScrollView(
                      child: RegistrationForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
