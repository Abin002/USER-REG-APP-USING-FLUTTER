import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userregistrationapp/views/loginalert.dart';

import 'package:userregistrationapp/views/visitorslist.dart';
import 'customtextfeild.dart'; // Import your custom text field widget

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  late String _selectedImagePath = '';
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSelectedImagePath();
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginAlert(
          onImageSelected: (selectedImagePath) async {
            // Handle the selected image path
            await _saveSelectedImagePath(selectedImagePath);
          },
        );
      },
    );
  }

  Future<void> _saveSelectedImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedImagePath', imagePath);

    setState(() {
      _selectedImagePath = imagePath;
    });
  }

  Future<void> _loadSelectedImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('selectedImagePath') ?? '';

    setState(() {
      _selectedImagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          onLongPress: _pickImage,
                          child: _selectedImagePath.isNotEmpty
                              ? ClipOval(
                                  child: Image.file(File(_selectedImagePath),
                                      fit: BoxFit.cover),
                                )
                              : Image.asset('assets/edit.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(
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

// Rest of your code remains unchanged...

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _purposeController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Simple email validation
    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Simple phone number validation
    if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _saveDataToFirestore() async {
    try {
      final phoneNumber = _phoneNumberController.text;

      // Check if a document with the same phone number already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('visitors')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show a Snackbar indicating that the phone number already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number already exists!'),
            duration: Duration(seconds: 2),
          ),
        );
        return; // Exit the method without saving to Firestore
      }

      // Continue saving to Firestore if the phone number is unique
      await FirebaseFirestore.instance.collection('visitors').add({
        'full name': _fullNameController.text,
        'phone': phoneNumber,
        'email': _emailController.text,
        'adress': _addressController.text,
        'purpose': _purposeController.text,
        'time': FieldValue.serverTimestamp(),
      });

      // Clear text fields
      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _purposeController.clear();

      FocusScope.of(context).unfocus();

      // Show a Snackbar for successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully submitted!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Print the values if needed
      print('Data saved to Firestore successfully!');
    } catch (e) {
      print('Error saving data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomTextField(
            controller: _fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: Color(0xFF101213),
            hintStyleFontSize: 16,
            hintStyleFontWeight: FontWeight.normal,
            enabledBorderWidth: 2,
            focusedBorderWidth: 2,
            errorBorderWidth: 2,
            focusedErrorBorderWidth: 2,
            contentPaddingStart: 20,
            contentPaddingTop: 24,
            contentPaddingEnd: 20,
            keyboardType: TextInputType.name,
            contentPaddingBottom: 24,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _phoneNumberController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: Color(0xFF101213),
            hintStyleFontSize: 16,
            hintStyleFontWeight: FontWeight.normal,
            enabledBorderWidth: 2,
            focusedBorderWidth: 2,
            errorBorderWidth: 2,
            focusedErrorBorderWidth: 2,
            keyboardType: TextInputType.phone,
            contentPaddingStart: 20,
            contentPaddingTop: 24,
            contentPaddingEnd: 20,
            contentPaddingBottom: 24,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            validator: validatePhone,
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: Color(0xFF101213),
            hintStyleFontSize: 16,
            hintStyleFontWeight: FontWeight.normal,
            enabledBorderWidth: 2,
            focusedBorderWidth: 2,
            errorBorderWidth: 2,
            focusedErrorBorderWidth: 2,
            contentPaddingStart: 20,
            contentPaddingTop: 24,
            contentPaddingEnd: 20,
            contentPaddingBottom: 24,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter your address',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: Color(0xFF101213),
            hintStyleFontSize: 16,
            hintStyleFontWeight: FontWeight.normal,
            enabledBorderWidth: 2,
            focusedBorderWidth: 2,
            errorBorderWidth: 2,
            focusedErrorBorderWidth: 2,
            contentPaddingStart: 20,
            contentPaddingTop: 24,
            contentPaddingEnd: 20,
            contentPaddingBottom: 24,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _purposeController,
            labelText: 'Purpose of Visit',
            hintText: 'Enter the purpose of your visit',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: Color(0xFF101213),
            hintStyleFontSize: 16,
            hintStyleFontWeight: FontWeight.normal,
            enabledBorderWidth: 2,
            focusedBorderWidth: 2,
            errorBorderWidth: 2,
            focusedErrorBorderWidth: 2,
            contentPaddingStart: 20,
            contentPaddingTop: 24,
            contentPaddingEnd: 20,
            contentPaddingBottom: 24,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the purpose of your visit';
              }
              return null;
            },
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Form is valid, save data to Firestore
                  _saveDataToFirestore();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF9489F5),
                onPrimary: Colors.white,
                textStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 17, top: 17),
                child: const Center(
                    child: Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
