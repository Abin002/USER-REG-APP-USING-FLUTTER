// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'customtextfeild.dart';
import 'package:image/image.dart' as img;

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

  Future<void> _pickImage() async {
    try {
      final imagePickerResult =
          await _imagePicker.pickImage(source: ImageSource.camera);

      if (imagePickerResult != null) {
        // Compress the image before setting it
        final compressedImage =
            await compressImage(File(imagePickerResult.path));

        setState(() {
          _selectedImagePath = compressedImage?.path ?? '';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<File?> compressImage(File? file) async {
    if (file == null || file.path == null) {
      return null;
    }

    try {
      final originalImage = img.decodeImage(file.readAsBytesSync());
      final compressedImage = img.copyResize(originalImage!, width: 800);

      // Convert image to Uint8List with lower quality (e.g., quality: 30)
      final Uint8List compressedBytes =
          Uint8List.fromList(img.encodeJpg(compressedImage, quality: 30));

      // Write compressedBytes to file
      final compressedFile = File(file.path + '_compressed.jpg')
        ..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
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

      // Upload the image to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('visitor_photos')
          .child(DateTime.now().toString());
      final uploadTask = storageRef.putFile(File(_selectedImagePath));

      // Show a loading indicator while uploading
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
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

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Hide the loading indicator
      Navigator.of(context).pop();

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      // Continue saving to Firestore if the phone number is unique
      await FirebaseFirestore.instance.collection('visitors').add({
        'full name': _fullNameController.text,
        'phone': phoneNumber,
        'email': _emailController.text,
        'address': _addressController.text,
        'purpose': _purposeController.text,
        'time': FieldValue.serverTimestamp(),
        'photo_url':
            imageUrl, // Save the download URL instead of the local path
      });

      // Clear text fields
      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _purposeController.clear();

      // Clear the selected photo path
      setState(() {
        _selectedImagePath = '';
      });

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
            hintStyleColor: const Color(0xFF101213),
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
            style: const TextStyle(
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
          const SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _phoneNumberController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: const Color(0xFF101213),
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
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            validator: validatePhone,
          ),
          const SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: const Color(0xFF101213),
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
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter your address',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: const Color(0xFF101213),
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
            style: const TextStyle(
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
          const SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _purposeController,
            labelText: 'Purpose of Visit',
            hintText: 'Enter the purpose of your visit',
            hintStyleFontFamily: 'Manrope',
            hintStyleColor: const Color(0xFF101213),
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
            style: const TextStyle(
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
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _selectedImagePath.isEmpty
                      ? Colors.red // Red if no photo is selected
                      : _selectedImagePath.isNotEmpty
                          ? Colors.green // Green if photo is selected
                          : Colors.blue,
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text('Take Photo'),
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
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9489F5),
                textStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 17, top: 17),
                child: Center(
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
