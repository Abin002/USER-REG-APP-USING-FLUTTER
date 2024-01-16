// registration_form.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'customtextfeild.dart';
import 'image_compression.dart'; // Import the new file

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
  late String _selectedImagePath = '';
  final _imagePicker = ImagePicker();

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

  bool _isImageProcessing = false;
  Future<void> _pickImage() async {
    try {
      final imagePickerResult =
          await _imagePicker.pickImage(source: ImageSource.camera);

      if (imagePickerResult != null) {
        // Set the variable to true to indicate that image compression is in progress
        setState(() {
          _isImageProcessing = true;
        });

        // Perform image compression in a separate isolate
        final compressedImage =
            await compute(compressImage, imagePickerResult.path ?? '');

        // Set the variable to false to indicate that image compression is complete
        setState(() {
          _isImageProcessing = false;
        });

        setState(() {
          _selectedImagePath = compressedImage ?? '';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveDataToFirestore() async {
    // Use compute to run the operation in a background isolate
    await compute(_backgroundSaveDataToFirestore, {
      'fullName': _fullNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'purpose': _purposeController.text,
      'selectedImagePath': _selectedImagePath,
      'context': context,
    });
  }

  Future<void> _backgroundSaveDataToFirestore(Map<String, dynamic> data) async {
    try {
      final phoneNumber = data['phoneNumber'];

      // Check if a document with the same phone number already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('visitors')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show a Snackbar indicating that the phone number already exists
        ScaffoldMessenger.of(data['context']).showSnackBar(
          const SnackBar(
            content: Text('Phone number already exists!'),
            duration: Duration(seconds: 2),
          ),
        );
        return; // Exit the method without saving to Firestore
      }

      // Upload the image to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('visitor_photos')
          .child(DateTime.now().toString());
      final uploadTask = storageRef.putFile(File(data['selectedImagePath']));

      // Show a loading indicator while uploading
      showDialog(
        context: data['context'],
        barrierDismissible: false, // User cannot dismiss the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Flexible(
                  child: Text(
                    "REGISTRATION ON PROGRESS",
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          );
        },
      );

      try {
        // Wait for the upload to complete
        await uploadTask.whenComplete(() => null);

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        // Continue saving to Firestore if the phone number is unique
        await FirebaseFirestore.instance.collection('visitors').add({
          'full name': data['fullName'],
          'phone': phoneNumber,
          'email': data['email'],
          'address': data['address'],
          'purpose': data['purpose'],
          'time': FieldValue.serverTimestamp(),
          'photo_url': imageUrl,
        });

        // Clear text fields
        _fullNameController.clear();
        _phoneNumberController.clear();
        _emailController.clear();
        _addressController.clear();
        _purposeController.clear();

        // Clear the selected photo path
        ScaffoldMessenger.of(data['context']).hideCurrentSnackBar();
        setState(() {
          _selectedImagePath = '';
        });

        FocusScope.of(data['context']).unfocus();

        // Show a Snackbar for successful submission
        ScaffoldMessenger.of(data['context']).showSnackBar(
          const SnackBar(
            content: Text('Successfully submitted!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Print the values if needed
        print('Data saved to Firestore successfully!');
      } finally {
        // Hide the loading indicator
        Navigator.of(data['context']).pop();
      }
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
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isImageProcessing
                    ? null
                    : _pickImage, // Disable button during processing
                style: ElevatedButton.styleFrom(
                  primary: _selectedImagePath.isEmpty
                      ? Colors.blue // Blue for initial state
                      : _selectedImagePath.isNotEmpty && !_isImageProcessing
                          ? Colors
                              .green // Green if photo is selected and not processing
                          : Colors.red, // Red if there's an error or processing
                  onPrimary: Colors.white,
                  textStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: _isImageProcessing
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text('Take Photo'),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: _selectedImagePath.isEmpty
                  ? null // Disable the button if no photo is taken
                  : () {
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
