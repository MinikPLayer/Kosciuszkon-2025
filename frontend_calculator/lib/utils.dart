import 'package:flutter/material.dart';

class Utils {
  static Widget buildNumberInput({
    required String label,
    required double value,
    required void Function(double) onChanged,
    bool isInt = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: isInt ? value.toInt().toString() : value.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wprowadź wartość';
          final numValue = isInt ? int.tryParse(value) : double.tryParse(value);
          if (numValue == null) return 'Nieprawidłowa wartość';
          if (numValue < 0) return 'Wartość musi być dodatnia';
          return null;
        },
        onChanged: (value) {
          final numValue = isInt ? int.tryParse(value) : double.tryParse(value);
          if (numValue != null && numValue >= 0) {
            onChanged(numValue.toDouble());
          }
        },
      ),
    );
  }
}
