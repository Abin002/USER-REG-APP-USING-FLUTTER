// // image_compression.dart

// import 'dart:typed_data';
// import 'dart:io';
// import 'package:image/image.dart' as img;

// String? compressImage(String imagePath) {
//   try {
//     final file = File(imagePath);
//     final originalImage = img.decodeImage(file.readAsBytesSync());

//     // Your compression logic here
//     final compressedImage = img.copyResize(originalImage!, width: 800);

//     // Convert image to Uint8List with lower quality (e.g., quality: 30)
//     final Uint8List compressedBytes =
//         Uint8List.fromList(img.encodeJpg(compressedImage, quality: 30));

//     // Write compressedBytes to file
//     final compressedFile = File(imagePath + '_compressed.jpg')
//       ..writeAsBytesSync(compressedBytes);

//     return compressedFile.path; // Return the path of the compressed image
//   } catch (e) {
//     print('Error compressing image: $e');
//     return null;
//   }
// }
