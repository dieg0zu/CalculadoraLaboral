import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

void main() {
  final formatter = CurrencyTextInputFormatter.currency(locale: 'es', symbol: '');
  print(formatter.format('1000.50'));
  print(formatter.format('100050'));
}
