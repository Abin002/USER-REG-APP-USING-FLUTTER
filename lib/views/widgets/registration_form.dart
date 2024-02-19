// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_pos_printer_platform_image_3/discovery.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

import 'package:ui_smartech/views/widgets/printservices.dart';
import '../utility_files/camera_utilities.dart';
import '../utility_files/device_info_helper.dart';
import '../utility_files/validation_functions.dart';
import 'custom_sizedbox.dart';
import 'customtextfeild.dart';
import 'styled_dropdown.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _purposeController;
  late String selectedImagePath = '';
  late CameraController _cameraController;
  final _firebaseStorage = firebase_storage.FirebaseStorage.instance;
  late List<String> _idTypes;
  late String _selectedIdType;
  late TextEditingController _idNumberController;
  late DeviceInfoHelper _deviceInfoHelper;
  PrintServicesState printServices = PrintServicesState();

  bool connected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    connectToUsbPrinter(context);
    _deviceInfoHelper = DeviceInfoHelper();

    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _purposeController = TextEditingController();
    _idNumberController = TextEditingController();
    _idTypes = ['Aadhar', 'Driver\'s License'];
    _selectedIdType = _idTypes[0]; // Initialize with the first ID type
  }

  Future<void> _initializeCamera() async {
    _cameraController = await CameraUtilities.initializeCamera();
  }

  Future<void> connectToUsbPrinter(BuildContext context) async {
    print('trying to connect......');
    // Fetch list of available USB devices initially
    final List<PrinterDiscovered<UsbPrinterInfo>> result =
        await UsbPrinterConnector.discoverPrinters();
    if (result.isNotEmpty) {
      print(result);
      // Connect to the first available USB device
      final device = result.first.detail;
      print(device);
      await connectToDevice(device);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer connected!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No usb printers found'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> connectToDevice(UsbPrinterInfo device) async {
    try {
      await UsbPrinterConnector.instance.connect(UsbPrinterInput(
        name: device.name,
        vendorId: device.vendorId,
        productId: device.productId,
      ));
      if (mounted) {
        print('connecting to ${device.name}');
        setState(() {
          connected = true;
        });
        print('connecting to ${device.name}');
      }
    } catch (e) {
      print("Error connecting to USB device: $e");
    }
  }

  Future<void> printTicket({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? address,
    String? purpose,
    String? idType,
    String? idNumber,
  }) async {
    try {
      if (connected) {
        // USB printer is connected, print the ticket
        await _printTicket();
      } else {
        // USB printer is not connected, attempt to connect and print
        final result = await UsbPrinterConnector.discoverPrinters();
        if (result.isNotEmpty) {
          // Connect to the first available USB device
          final device = result.first.detail;
          await connectToDevice(device);
          if (connected) {
            // Successfully connected, print the ticket
            await _printTicket();
          } else {
            // Failed to connect
            print("failed to connect ");
          }
        } else {
          print('no printers found');
        }
      }
    } catch (e) {
      // Handle exceptions
      print("Error printing ticket: $e");
    }
  }

  Future<void> _printTicket() async {
    final ticketContent = await generateTicketContent(
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      email: _emailController.text,
      address: _addressController.text,
      purpose: _purposeController.text,
      idType: _selectedIdType,
      idNumber: _idNumberController.text,
    );

    // Print the ticket
    await PrinterManager.instance.send(
      type: PrinterType.usb,
      bytes: ticketContent.codeUnits,
    );
  }

  Future<String> generateTicketContent({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String address,
    required String purpose,
    required String idType,
    required String idNumber,
  }) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Add a heading
    bytes += generator.text("User Details",
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    // Adding user details to the ticket
    bytes += generator.text("Full Name: $fullName",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("Phone: $phoneNumber",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("Email: $email",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("Address: $address",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("Purpose: $purpose",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("ID Type: $idType",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    bytes += generator.text("ID Number: $idNumber",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    // Add margin lines
    bytes += generator.text(" " * 32,
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    // Add a closing message
    bytes += generator.text("Thanks for Visiting!",
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1);

    // Additional formatting as needed
    bytes += generator.cut();

    String ticketContent = String.fromCharCodes(bytes);

    return ticketContent;
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
        selectedImagePath = capturedImage.path;
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
          .child('${DateTime.now()}.jpg');

      final uploadTask = storageRef.putFile(File(selectedImagePath));

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

      // await printTicket();

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('visitors').add({
        'full name': _fullNameController.text,
        'phone': phoneNumber,
        'email': _emailController.text,
        'address': _addressController.text,
        'purpose': _purposeController.text,
        'time': FieldValue.serverTimestamp(),
        'photo_url': imageUrl,
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text,
        'device name': await _deviceInfoHelper.getAndroidDeviceInfo(),
      });

      printServices.printTicket(
          fullName: _fullNameController.text,
          phoneNumber: _phoneNumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          purpose: _purposeController.text,
          idType: _selectedIdType,
          idNumber: _idNumberController.text,
          urlimage: imageUrl);

      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _purposeController.clear();
      _idNumberController.clear();

      setState(() {
        selectedImagePath = '';
        _selectedIdType = _idTypes[0];
      });

      Navigator.of(context).pop();

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully submitted!'),
          duration: Duration(seconds: 2),
        ),
      );

      print('Data saved to Firestore and printed successfully!');
    } catch (e) {
      print('Error saving data to Firestore or printing: $e');
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
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
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
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            controller: _phoneNumberController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: validatePhone,
            maxLength: 10,
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const CustomSizedBox(heightFactor: 0.02),
          CustomTextField(
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
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
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
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
              onEditingComplete: () => FocusScope.of(context).unfocus(),
              controller: _idNumberController,
              labelText: '$_selectedIdType Number',
              hintText: 'Enter your $_selectedIdType number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $_selectedIdType number';
                }

                String? Function(String?)? idValidator;
                switch (_selectedIdType) {
                  case 'Aadhar':
                    idValidator = ValidationFunctions.validateAadhar;
                    break;
                  case 'Driver\'s License':
                    idValidator = ValidationFunctions.validateLicense;
                    break;
                  default:
                    idValidator = null;
                    break;
                }

                if (idValidator != null) {
                  return idValidator(value);
                }

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
                  backgroundColor: selectedImagePath.isEmpty
                      ? Colors.blue
                      : selectedImagePath.isNotEmpty && !_isImageProcessing
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
              onPressed: selectedImagePath.isEmpty
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        printTicket();
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
