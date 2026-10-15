import 'package:flutter/services.dart';

/// Whether a form field applies to a document type, and whether it must be
/// filled. Mirrors `libs/domain/src/documents/number.ts`; the server checks too.
enum FieldRule { required, optional, hidden }

typedef DocFields = ({
  FieldRule number,
  FieldRule validFrom,
  FieldRule expiresOn,
});

const _withDates = FieldRule.optional;

/// Which details each document type has. Aadhaar, PAN and the photo never
/// expire; a police verification may or may not carry a date.
const Map<String, DocFields> docFields = {
  'rc': (
    number: FieldRule.required,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'insurance': (
    number: FieldRule.optional,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'permit': (
    number: FieldRule.optional,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'puc': (
    number: FieldRule.optional,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'driving_licence': (
    number: FieldRule.required,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'aadhaar': (
    number: FieldRule.required,
    validFrom: FieldRule.hidden,
    expiresOn: FieldRule.hidden,
  ),
  'pan': (
    number: FieldRule.required,
    validFrom: FieldRule.hidden,
    expiresOn: FieldRule.hidden,
  ),
  'police_verification': (
    number: FieldRule.optional,
    validFrom: _withDates,
    expiresOn: FieldRule.optional,
  ),
  'badge': (
    number: FieldRule.optional,
    validFrom: _withDates,
    expiresOn: FieldRule.required,
  ),
  'photo': (
    number: FieldRule.hidden,
    validFrom: FieldRule.hidden,
    expiresOn: FieldRule.hidden,
  ),
};

/// A type's fields; an unknown (newer) type gets every field, all optional.
DocFields fieldsOf(String docType) =>
    docFields[docType] ??
    (
      number: FieldRule.optional,
      validFrom: FieldRule.optional,
      expiresOn: FieldRule.optional,
    );

final _formats = <String, RegExp>{
  'rc': RegExp(r'^[A-Z0-9]{6,11}$'),
  'insurance': RegExp(r'^[A-Z0-9/-]{5,30}$'),
  'permit': RegExp(r'^[A-Z0-9/-]{4,30}$'),
  'puc': RegExp(r'^[A-Z0-9/-]{4,30}$'),
  'driving_licence': RegExp(r'^[A-Z]{2}\d{13}$'),
  'aadhaar': RegExp(r'^[2-9]\d{11}$'),
  'pan': RegExp(r'^[A-Z]{5}\d{4}[A-Z]$'),
  'police_verification': RegExp(r'^[A-Z0-9/-]{3,30}$'),
  'badge': RegExp(r'^[A-Z0-9]{3,20}$'),
};

/// How each type's number looks, shown as a hint and in the error.
const docNumberExamples = {
  'rc': 'MH12AB1234',
  'insurance': 'OG-25-1234-5678',
  'permit': 'MH12/TP/1234',
  'puc': 'MH0120250012345',
  'driving_licence': 'MH12 20110012345',
  'aadhaar': '1234 5678 9012',
  'pan': 'ABCDE1234F',
  'police_verification': 'PV/2025/123',
  'badge': 'B12345',
};

const _dashFree = {'rc', 'driving_licence', 'aadhaar', 'pan', 'badge'};

/// The number as stored: uppercase, without spaces; identity and licence
/// numbers also lose their dashes.
String normaliseDocNumber(String docType, String raw) {
  final upper = raw.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  return _dashFree.contains(docType) ? upper.replaceAll('-', '') : upper;
}

enum DocNumberProblem { missing, notAllowed, format, checksum }

/// What is wrong with a normalised number for this type, or null.
DocNumberProblem? checkDocNumber(String docType, String number) {
  final rule = fieldsOf(docType).number;
  if (number.isEmpty) {
    return rule == FieldRule.required ? DocNumberProblem.missing : null;
  }
  if (rule == FieldRule.hidden) return DocNumberProblem.notAllowed;
  final format = _formats[docType];
  if (format != null && !format.hasMatch(number)) {
    return DocNumberProblem.format;
  }
  if (docType == 'aadhaar' && !verhoeffValid(number)) {
    return DocNumberProblem.checksum;
  }
  return null;
}

const _d = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];
const _p = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

/// Whether digits end in a valid Verhoeff check digit (UIDAI's Aadhaar check).
bool verhoeffValid(String digits) {
  var c = 0;
  final n = digits.length;
  for (var i = 0; i < n; i++) {
    final digit = digits.codeUnitAt(n - 1 - i) - 48;
    if (digit < 0 || digit > 9) return false;
    c = _d[c][_p[i % 8][digit]];
  }
  return c == 0;
}

/// Typing an Aadhaar number: digits only, at most 12, shown as
/// "1234 5678 9012".
class AadhaarInputFormatter extends TextInputFormatter {
  const AadhaarInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final kept = digits.length > 12 ? digits.substring(0, 12) : digits;
    final grouped = StringBuffer();
    for (var i = 0; i < kept.length; i++) {
      if (i > 0 && i % 4 == 0) grouped.write(' ');
      grouped.write(kept[i]);
    }
    final text = grouped.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Upper-cases what is typed, keeping the cursor where it was.
class UpperCaseInputFormatter extends TextInputFormatter {
  const UpperCaseInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
