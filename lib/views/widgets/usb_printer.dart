// ignore_for_file: avoid_print, use_key_in_widget_constructors

import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/discovery.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class UsbPrinterScreen extends StatefulWidget {
  @override
  UsbPrinterScreenState createState() => UsbPrinterScreenState();
}

class UsbPrinterScreenState extends State<UsbPrinterScreen> {
  bool connected = false;
  List<UsbPrinterInfo> availableUsbDevices = [];

  @override
  void initState() {
    super.initState();
    // Fetch list of available USB devices initially
    getUsbDevices();
  }

  Future<void> getUsbDevices() async {
    try {
      final List<PrinterDiscovered<UsbPrinterInfo>> result =
          await UsbPrinterConnector.discoverPrinters();
      setState(() {
        availableUsbDevices = result
            .map((printerDiscovered) => printerDiscovered.detail)
            .toList();
      });

      // Print the list of available USB devices
      print("Available USB Devices:$availableUsbDevices");
      for (var device in availableUsbDevices) {
        print(
            "Name: ${device.name}, Vendor: ${device.vendorId}, Product: ${device.productId}");
      }
    } catch (e) {
      print("Error fetching USB devices: $e");
    }
  }

  Future<void> connectToDevice(UsbPrinterInfo device) async {
    try {
      final bool connected =
          await UsbPrinterConnector.instance.connect(UsbPrinterInput(
        name: device.name,
        vendorId: device.vendorId,
        productId: device.productId,
      ));
      setState(() {
        this.connected = connected;
      });
    } catch (e) {
      print("Error connecting to USB device: $e");
    }
  }

  Future<bool> checkConnection() async {
    try {
      PrinterManager.instance.stateUSB.listen((status) {
        print(' ----------------- status bt $status ------------------ ');
      });

      return connected;
    } catch (e) {
      print("Error checking USB connection: $e");
      return false; // Return false in case of any error
    }
  }

  Future<void> _printTicket() async {
    final ticketContent = await generateTicketContent(
      fullName: "placeholder",
      phoneNumber: "placeholder",
      email: "placeholder",
      address: "placeholder",
      purpose: "placeholder",
      idType: "placeholder",
      idNumber: "placeholder",
    );

    // Print the ticket
    await PrinterManager.instance.send(
      type: PrinterType.usb,
      bytes: ticketContent,
    );
  }

  Future<List<int>> generateTicketContent({
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

    // Load image from asset
    // final ByteData data = await rootBundle.load('assets/abin.jpg');
    // final Uint8List buf = data.buffer.asUint8List();
    // final img.Image? image = img.decodeImage(buf);

    // if (image != null) {
    //   // Convert image to ESC/POS format
    //   final List<int> imageBytes = generator.imageRaster(image);

    //   // Add image to ticket
    //   bytes += imageBytes;
    // }

    // Add margin lines
    bytes += generator.text(" " * 32,
        styles: const PosStyles(align: PosAlign.left), linesAfter: 1);

    // Add a closing message
    bytes += generator.text("Thanks for Visiting!",
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1);

    // Additional formatting as needed
    bytes += generator.cut();

    return bytes;
  }

  // Function to refresh the list of USB devices
  Future<void> refreshDevices() async {
    setState(() {
      // Clear the list of available USB devices
      availableUsbDevices.clear();
    });
    // Fetch the list of available USB devices again
    await getUsbDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Printer'),
        actions: [
          // Add a refresh button to the app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Call the function to refresh USB devices
              refreshDevices();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _printTicket(); // Call the print function
              },
              child: const Text('Print Ticket'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available USB Devices:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: availableUsbDevices.length,
                itemBuilder: (context, index) {
                  final device = availableUsbDevices[index];
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(
                        'Vendor: ${device.vendorId}, Product: ${device.productId}'),
                    onTap: () {
                      connectToDevice(device);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
