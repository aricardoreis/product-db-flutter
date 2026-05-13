import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

String formatDate(DateTime date) => _dateFormat.format(date);
