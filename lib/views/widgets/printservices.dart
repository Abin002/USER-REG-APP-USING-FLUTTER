import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';

class PrintServices extends StatefulWidget {
  const PrintServices({Key? key}) : super(key: key);

  @override
  State<PrintServices> createState() => PrintServicesState();
}

class PrintServicesState extends State<PrintServices> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
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
    String? capturedImagePath,
    String? urlimage,
  }) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket(
        fullName: fullName ?? "Placeholder",
        phoneNumber: phoneNumber ?? "Placeholder",
        email: email ?? "Placeholder",
        address: address ?? "Placeholder",
        purpose: purpose ?? "Placeholder",
        idType: idType ?? "Placeholder",
        idNumber: idNumber ?? "Placeholder",
        urlimage: urlimage ?? "https://picsum.photos/id/237/200/300",
      );

      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      print('printer not connected');
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getTicket({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String address,
    required String purpose,
    required String idType,
    required String idNumber,
    required String urlimage,
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

    final ByteData data =
        await NetworkAssetBundle(Uri.parse(urlimage)).load('');
    final Uint8List buf = data.buffer.asUint8List();
    final image = decodeImage(buf)!;

    bytes += generator.image(image);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: connected ? printTicket : null,
          child: const Text("CONNECT", style: TextStyle(fontSize: 21)),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Paired Bluetooth"),
            TextButton(
              onPressed: () {
                getBluetooth();
              },
              child: const Text("Search"),
            ),
            Expanded(
              child: SizedBox(
                child: ListView.builder(
                  itemCount: availableBluetoothDevices.isNotEmpty
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        String select = availableBluetoothDevices[index];
                        List list = select.split("#");
                        // String name = list[0];
                        String mac = list[1];
                        setConnect(mac);
                      },
                      title: Text('${availableBluetoothDevices[index]}'),
                      subtitle: const Text("Click to connect"),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
