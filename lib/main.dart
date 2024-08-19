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
        appBar: AppBar(title: const Text('Dynamic Slider Example')),
        body: const _DemoView(),
      ),
    );
  }
}

class _DemoView extends StatefulWidget {
  const _DemoView();

  @override
  State<_DemoView> createState() => _DemoViewState();
}

class _DemoViewState extends State<_DemoView> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController inputMinCtrl = TextEditingController();
  final TextEditingController inputMaxCtrl = TextEditingController();

  double sliderMinValue = 0;
  double sliderMaxValue = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                      controller: inputMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Input Min'),
                      validator: (String? val) {
                        if (val == null || val.isEmpty) {
                          return 'Cannot empty';
                        }

                        return null;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: inputMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Input Max'),
                    validator: (String? val) {
                      if (val == null || val.isEmpty) {
                        return 'Cannot empty';
                      }

                      if ((num.tryParse(inputMinCtrl.text) ?? 0) >=
                          (num.tryParse(inputMaxCtrl.text) ?? 0)) {
                        return 'max should be > min';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() == true) {
                        setState(() {
                          sliderMinValue = double.tryParse(inputMinCtrl.text) ?? 0;
                          sliderMaxValue = double.tryParse(inputMaxCtrl.text) ?? 0;
                        });
                      }
                    },
                    child: const Text('Updated min & max'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          DynamicSlider(
            min: sliderMinValue, // Original minimum value
            max: sliderMaxValue, // Original maximum value
          ),
        ],
      ),
    );
  }
}

class DynamicSlider extends StatefulWidget {
  const DynamicSlider({
    super.key,
    required this.min,
    required this.max,
  });

  final double min;
  final double max;

  @override
  State<DynamicSlider> createState() => _DynamicSliderState();
}

class _DynamicSliderState extends State<DynamicSlider> {
  double ceilMin = 0;
  double ceilMax = 0;
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _updateSliderRange();
  }

  @override
  void didUpdateWidget(covariant DynamicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.min != oldWidget.min || widget.max != oldWidget.max) {
      _updateSliderRange();
    }
  }

  void _updateSliderRange() {
    setState(() {
      ceilMin = customCeil(widget.min);
      ceilMax = customCeil(widget.max);
      _currentValue = ceilMin;
    });
  }


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
          divisions: 4,
          label: _currentValue.toString(),
          onChanged: (double value) {
            setState(() {
              _currentValue = value;
            });
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Min Value: ${ceilMin.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        Text(
          'Max Value: ${ceilMax.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 24),
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
    final int otherDigitsStrLength = otherDigitsStr.length;

    final String otherDigitsZerosStr = '0' * otherDigitsStrLength;

    // Handle the rounding logic based on the second digit
    if (secondDigit >= 1 && secondDigit <= 4) {
      // Add 5 to the first digit and adjust the rest to zero
      return double.tryParse(('${firstDigit}5$otherDigitsZerosStr')) ?? 0;
    }

    if (secondDigit > 5 && secondDigit <= 9) {
      // Increment the first digit by 1 and adjust the rest to zero
      firstDigit += 1;
      return double.tryParse(('${firstDigit}0$otherDigitsZerosStr')) ?? 0;
    }

    //Return the value if there is no more digit after second digit
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
      return double.tryParse(('${firstDigit}5$otherDigitsZerosStr')) ?? 0;
    }

    if (secondDigit == 5) {
      firstDigit += 1;
      return double.tryParse(('${firstDigit}0$otherDigitsZerosStr')) ?? 0;
    }

    return value;
  }
}
