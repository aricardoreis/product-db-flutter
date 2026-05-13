import 'package:intl/intl.dart';

final _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatBrl(num value) => _formatter.format(value);
