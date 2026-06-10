import 'package:flutter/services.dart';

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If text was cleared or user is deleting
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    var text = newValue.text.replaceAll('/', ''); 
    // Filter out non-digits just in case
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    var newText = '';
    for (int i = 0; i < text.length; i++) {
      var char = text[i];
      // Day first digit
      if (i == 0) {
        if (int.parse(char) > 3) {
          newText += '0$char/';
          continue;
        }
      }
      // Day second digit
      if (i == 1) {
        var day = int.parse('${text[0]}$char');
        if (day > 31 || day == 0) {
          return oldValue;
        }
        newText += '$char/';
        continue;
      }
      // Month first digit
      if (i == 2) {
        if (int.parse(char) > 1) {
          newText += '0$char/';
          continue;
        }
      }
      // Month second digit
      if (i == 3) {
        var month = int.parse('${text[2]}$char');
        if (month > 12 || month == 0) {
          return oldValue;
        }
        newText += '$char/';
        continue;
      }
      
      newText += char;
    }

    if (newText.endsWith('/') && text.length == 8) {
      newText = newText.substring(0, newText.length - 1);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
