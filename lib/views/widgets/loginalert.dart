import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'custom_sizedbox.dart';

class LoginAlert extends StatelessWidget {
  final Function(String)? onImageSelected;

  const LoginAlert({Key? key, this.onImageSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Login',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: LoginContent(onImageSelected: onImageSelected),
    );
  }
}

class LoginContent extends StatefulWidget {
  final Function(String)? onImageSelected;

  const LoginContent({Key? key, this.onImageSelected}) : super(key: key);

  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      // height: double.infinity,
      child: Column(
        children: [
          // Your login form fields go here
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF101213),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey, // Set to default dark grey color
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
            ),
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const CustomSizedBox(heightFactor: 0.02),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF101213),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey, // Set to default dark grey color
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
            ),
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            obscureText: true,
          ),
          const CustomSizedBox(heightFactor: 0.02),
          ElevatedButton(
            onPressed: () async {
              // Validate credentials
              if (_usernameController.text == 'admin' &&
                  _passwordController.text == 'admin123') {
                // If credentials are valid, show image picker
                final pickedFile =
                    await _imagePicker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  // Update UI with the selected image
                  widget.onImageSelected?.call(pickedFile.path);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No image selected'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(context); // Close the alert dialog
              } else {
                // If credentials are invalid, show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid credentials. Please try again.'),
                    duration: Duration(seconds: 2),
                  ),
                );
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
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}