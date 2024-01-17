import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'customtextfeild.dart';
import 'image_compression.dart';

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
  late CameraController _cameraController;
  final _firebaseStorage = firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _purposeController = TextEditingController();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
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
    if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  bool _isImageProcessing = false;
  Future<void> _captureImage() async {
    try {
      setState(() {
        _isImageProcessing = true;
      });

      final XFile capturedImage = await _cameraController.takePicture();

      setState(() {
        _isImageProcessing = false;
        _selectedImagePath = capturedImage.path ?? '';
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _saveDataToFirestore() async {
    try {
      final phoneNumber = _phoneNumberController.text;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('visitors')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number already exists!'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final storageRef = _firebaseStorage
          .ref()
          .child('visitor_photos')
          .child(DateTime.now().toString());
      final uploadTask = storageRef.putFile(File(_selectedImagePath));

      showDialog(
        context: context,
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

      await uploadTask.whenComplete(() => null);

      Navigator.of(context).pop();

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('visitors').add({
        'full name': _fullNameController.text,
        'phone': phoneNumber,
        'email': _emailController.text,
        'address': _addressController.text,
        'purpose': _purposeController.text,
        'time': FieldValue.serverTimestamp(),
        'photo_url': imageUrl,
      });

      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _purposeController.clear();

      setState(() {
        _selectedImagePath = '';
      });

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully submitted!'),
          duration: Duration(seconds: 2),
        ),
      );

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
                onPressed: _isImageProcessing ? null : _captureImage,
                style: ElevatedButton.styleFrom(
                  primary: _selectedImagePath.isEmpty
                      ? Colors.blue
                      : _selectedImagePath.isNotEmpty && !_isImageProcessing
                          ? Colors.green
                          : Colors.red,
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
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
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
