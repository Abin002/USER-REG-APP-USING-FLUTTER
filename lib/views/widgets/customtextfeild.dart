import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String hintStyleFontFamily;
  final Color hintStyleColor;
  final double hintStyleFontSize;
  final FontWeight hintStyleFontWeight;
  final double contentPaddingStart;
  final double contentPaddingTop;
  final double contentPaddingEnd;
  final double contentPaddingBottom;
  final TextStyle style;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType; // Added keyboardType parameter

  // Fixed properties with default values
  final double enabledBorderWidth;
  final double focusedBorderWidth;
  final double errorBorderWidth;
  final double focusedErrorBorderWidth;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.hintStyleFontFamily = 'Manrope',
    this.hintStyleColor = const Color(0xFF101213),
    this.hintStyleFontSize = 16,
    this.hintStyleFontWeight = FontWeight.normal,
    this.enabledBorderWidth = 2,
    this.focusedBorderWidth = 2,
    this.errorBorderWidth = 2,
    this.focusedErrorBorderWidth = 2,
    this.contentPaddingStart = 20,
    this.contentPaddingTop = 24,
    this.contentPaddingEnd = 20,
    this.contentPaddingBottom = 24,
    this.style = const TextStyle(
      fontFamily: 'Manrope',
      color: Color(0xFF101213),
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    required this.validator,
    this.keyboardType, // Updated: Added keyboardType parameter
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02),
      child: TextFormField(
        controller: controller,
        obscureText: false,
        keyboardType: keyboardType, // Updated: Set the keyboardType
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: hintStyleFontFamily,
            color: hintStyleColor,
            fontSize: hintStyleFontSize,
            fontWeight: hintStyleFontWeight,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Set to default dark grey color
              width: enabledBorderWidth,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: focusedBorderWidth,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: errorBorderWidth,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: focusedErrorBorderWidth,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            contentPaddingStart,
            contentPaddingTop,
            contentPaddingEnd,
            contentPaddingBottom,
          ),
        ),
        style: style,
        validator: validator,
      ),
    );
  }
}
