import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:
            AppBar(title: const Text('Custom Rounding Step Slider Example')),
        body: const Center(
          child: MathematicalStepSlider(
            min: 85, // Original minimum value
            max: 49999, // Original maximum value
          ),
        ),
      ),
    );
  }
}

class MathematicalStepSlider extends StatefulWidget {
  const MathematicalStepSlider({
    super.key,
    required this.min,
    required this.max,
  });

  final double min;
  final double max;

  @override
  State<MathematicalStepSlider> createState() => _MathematicalStepSliderState();
}

class _MathematicalStepSliderState extends State<MathematicalStepSlider> {
  late double ceilMin = customCeil(widget.min);
  late double ceilMax = customCeil(widget.max);
  late double _currentValue = ceilMin;

  @override
  Widget build(BuildContext context) {
    // Identify the range
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _currentValue,
          min: ceilMin,
          max: ceilMax,
          divisions: 5,
          label: _currentValue.toString(),
          onChanged: (double value) {
            setState(() {
              _currentValue = value;
            });
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Selected Value: ${_currentValue.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  double customCeil(double value) {
    if (value <= 50) return 50;
    if (value > 50 && value <= 100) return 100;

    // Split the string at the decimal point
    List<String> parts = value.toString().split('.');

    // Get the integer and decimal parts
    String intValueStr = parts[0];
    String decimalValueStr = parts.length > 1 ? parts[1] : '0';

    // Extract the first digit safely
    int? firstDigit =
        intValueStr.isNotEmpty ? int.tryParse(intValueStr[0]) : null;
    if (firstDigit == null) return value;

    // Extract the second digit safely
    int? secondDigit =
        intValueStr.length > 1 ? int.tryParse(intValueStr[1]) : null;
    if (secondDigit == null) return value;

    String otherDigitsStr =
        intValueStr.length > 2 ? intValueStr.substring(2) : '';
    final otherDigitsStrLength = otherDigitsStr.length;

    // Handle the rounding logic based on the second digit
    if (secondDigit >= 1 && secondDigit <= 4) {
      // Add 5 to the first digit and adjust the rest to zero
      int addition =
          (5 * pow(10, otherDigitsStrLength)).toInt(); // Fix the magnitude here
      return (firstDigit * pow(10, otherDigitsStrLength + 1) + addition)
          .toDouble();
    }

    if (secondDigit > 5 && secondDigit <= 9) {
      // Increment the first digit by 1 and adjust the rest to zero
      firstDigit += 1;
      return (firstDigit * pow(10, otherDigitsStrLength + 1)).toDouble();
    }

    if (otherDigitsStrLength <= 0) {
      return value;
    }

    double? otherDigitsNum = double.tryParse([
          otherDigitsStr,
          if (decimalValueStr.isNotEmpty) decimalValueStr
        ].join('.')) ??
        0;

    if (otherDigitsNum <= 0) {
      return value;
    }

    if (secondDigit == 0) {
      int addition = (5 * pow(10, otherDigitsStrLength)).toInt();
      return (firstDigit * pow(10, otherDigitsStrLength + 1) + addition)
          .toDouble();
    }

    if (secondDigit == 5) {
      firstDigit += 1;
      return (firstDigit * pow(10, otherDigitsStrLength + 1)).toDouble();
    }

    return value;
  }
}
