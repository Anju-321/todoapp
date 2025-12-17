

String? validateRequiredField(String? value, {required String fieldName}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}
String? validateMobileNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mobile Number is required';
  }

  // Check if the number contains only digits
  if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'Enter a valid mobile number';
  }

  // Check if all digits are the same
  if (RegExp(r'^(\d)\1+$').hasMatch(value)) {
    return 'Mobile Number cannot contain all the same digits';
  }

  return null;
}

String? validateDiscountField(String? value, String? maxAmount, {required String fieldName}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }

  // Try converting value and maxAmount to numbers
  final numValue = num.tryParse(value);
  final numMaxAmount = num.tryParse(maxAmount ?? '');

  if (numValue == null) {
    return 'Invalid $fieldName';
  }

  if (numMaxAmount == null) {
    return 'Invalid maximum amount';
  }

  // Check if the value exceeds maxAmount
  if (numValue > numMaxAmount) {
    return '$fieldName should not be greater than $maxAmount';
  }

  return null;
}
