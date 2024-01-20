import 'package:flutter/material.dart';

class CustomSizedBox extends StatelessWidget {
  final double heightFactor;

  const CustomSizedBox({Key? key, required this.heightFactor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * heightFactor,
    );
  }
}
