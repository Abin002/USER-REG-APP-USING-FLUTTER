import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loginalert.dart';

class LogoPicker {
  final BuildContext context;
  final Function(String) onLogoSelected;

  LogoPicker({required this.context, required this.onLogoSelected});

  Future<void> pickLogo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginAlert(
          onImageSelected: (selectedImagePath) async {
            // Handle the selected logo path
            await _saveSelectedLogoPath(selectedImagePath);
          },
        );
      },
    );
  }

  Future<void> _saveSelectedLogoPath(String logoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLogoPath', logoPath);

    onLogoSelected(logoPath);
  }
}
