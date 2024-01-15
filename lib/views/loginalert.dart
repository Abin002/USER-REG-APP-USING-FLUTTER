import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LoginAlert extends StatelessWidget {
  final Function(String)? onImageSelected;

  const LoginAlert({Key? key, this.onImageSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          // Your login form fields go here
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF101213),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
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
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
            ),
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF101213),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
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
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
            ),
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF101213),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            obscureText: true,
          ),
          SizedBox(
            height: 10,
          ),
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
                    SnackBar(
                      content: Text('No image selected'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(context); // Close the alert dialog
              } else {
                // If credentials are invalid, show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invalid credentials. Please try again.'),
                    duration: Duration(seconds: 2),
                  ),
                );
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
