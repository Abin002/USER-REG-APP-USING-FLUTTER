import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'utility_files/camera_utilities.dart';
import 'utility_files/validation_functions.dart';
import 'widgets/custom_sizedbox.dart';
import 'widgets/customtextfeild.dart';
import 'widgets/styled_dropdown.dart';

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
  late List<String> _idTypes;
  late String _selectedIdType;
  late TextEditingController _idNumberController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _purposeController = TextEditingController();
    _idNumberController = TextEditingController();
    _idTypes = ['Aadhar', 'Driver\'s License'];
    _selectedIdType = _idTypes[0]; // Initialize with the first ID type
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = await CameraUtilities.initializeCamera();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    _cameraController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    return ValidationFunctions.validateEmail(value);
  }

  String? validatePhone(String? value) {
    return ValidationFunctions.validatePhone(value);
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
        _selectedImagePath = capturedImage.path;
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _saveDataToFirestore() async {
    try {
      final phoneNumber = _phoneNumberController.text;
      final idNumber = _idNumberController.text;

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
      // Check if the ID number already exists for Aadhar or License
      final idQuerySnapshot = await FirebaseFirestore.instance
          .collection('visitors')
          .where('id_type', isEqualTo: _selectedIdType)
          .where('id_number', isEqualTo: idNumber)
          .get();

      if (idQuerySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID number already exists!'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final storageRef = _firebaseStorage
          .ref()
          .child('visitor_photos')
          .child(DateTime.now().toString() + '.jpg');

      final uploadTask = storageRef.putFile(File(_selectedImagePath));

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
        'id_type': _selectedIdType, // Add the ID type
        'id_number': _idNumberController.text, // Add the ID number
      });

      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _purposeController.clear();
      _idNumberController.clear();

      setState(() {
        _selectedImagePath = '';
        _selectedIdType = _idTypes[0];
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

  Widget _buildIdTypeDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomDropdown(
          items: _idTypes,
          selectedItem: _selectedIdType,
          onChanged: (String? newValue) {
            // Updated to accept nullable String
            setState(() {
              _selectedIdType = newValue!;
            });
          },
        ),
      ],
    );
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            controller: _phoneNumberController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: validatePhone,
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter your address',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            controller: _purposeController,
            labelText: 'Purpose of Visit',
            hintText: 'Enter the purpose of your visit',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the purpose of your visit';
              }
              return null;
            },
          ),
          const CustomSizedBox(heightFactor: 0.009),
          _buildIdTypeDropdown(),
          const CustomSizedBox(heightFactor: 0.009),
          if (_selectedIdType.isNotEmpty)
            CustomTextField(
              controller: _idNumberController,
              labelText: '${_selectedIdType} Number',
              hintText: 'Enter your ${_selectedIdType} number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your ${_selectedIdType} number';
                }

                // Dynamically choose the validation function based on the selected ID type
                String? Function(String?)? idValidator;
                switch (_selectedIdType) {
                  case 'Aadhar':
                    idValidator = ValidationFunctions.validateAadhar;
                    break;
                  case 'Driver\'s License':
                    idValidator = ValidationFunctions.validateLicense;
                    break;
                  // Add more cases for other ID types if needed

                  default:
                    idValidator = null;
                    break;
                }

                // If a validation function is found, apply it
                if (idValidator != null) {
                  return idValidator(value);
                }

                // Return null for other cases (no validation needed)
                return null;
              },
            ),
          const CustomSizedBox(heightFactor: 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isImageProcessing ? null : _captureImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _selectedImagePath.isEmpty
                      ? Colors.blue
                      : _selectedImagePath.isNotEmpty && !_isImageProcessing
                          ? Colors.green
                          : Colors.red,
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: _isImageProcessing
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Take Photo'),
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
