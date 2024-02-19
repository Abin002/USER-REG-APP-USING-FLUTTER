// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_smartech/views/visitorslist.dart';

class LoginFunctions {
  static void showLoginAlertBox(BuildContext context, FirebaseAuth auth) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: IntrinsicHeight(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your Email',
                    hintStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFF101213),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
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
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
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
                        color: Colors.grey,
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform login logic
                try {
                  UserCredential userCredential =
                      await auth.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  // Add logging to check the value of userCredential.user
                  print('User credential: ${userCredential.user}');

                  if (userCredential.user != null) {
                    Get.to(() => VisitorsList());
                  }
                } catch (e) {
                  print("Authentication Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentication failed. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }
}
