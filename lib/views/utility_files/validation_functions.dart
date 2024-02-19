class ValidationFunctions {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Aadhar number';
    }
    if (!RegExp(r"^\d{12}$").hasMatch(value)) {
      return 'Please enter a valid Aadhar number !';
    }
    return null;
  }

  static String? validateLicense(String? value) {
    value = value?.trim();

    if (value == null || value.isEmpty) {
      return 'Please enter your License number';
    }

    RegExp licensePattern = RegExp(r"^[A-Z]{2}\d{13}$");

    if (!licensePattern.hasMatch(value)) {
      return 'Please enter a valid License number!';
    }

    return null;
  }
}
