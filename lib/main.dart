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

    assert(value > 10, 'Value only single digit');

    // Split the string at the decimal point
    final List<String> parts = value.toString().split('.');

    // Get the integer and decimal parts
    final String integerValue = parts[0];
    final int lengthExcludeFirstTwo = integerValue.length - 2;

    // Extract the second digit
    final secondDigit = int.parse(integerValue[1]);
    final isZeroOrFive = secondDigit == 0 || secondDigit == 5;

    // Check if the value already rounded to the nearest 5
    final isRoundedToNearestFive =
        isZeroOrFive && _noRemainder(value, lengthExcludeFirstTwo * 10);
    if (isRoundedToNearestFive) {
      return value;
    }

    //markup by 1 if the second digit is 0 or 5
    final twoDigitsUpfront =
        int.parse(integerValue.substring(0, 2)) + (isZeroOrFive ? 1 : 0);
    final roundedValue = _roundedValueToNearestFive(twoDigitsUpfront);
    final zeroString = '0' * lengthExcludeFirstTwo;
    return double.tryParse(('$roundedValue$zeroString')) ?? 0;
  }

  bool _noRemainder(double value, double divisor) {
    return value % divisor == 0;
  }

  int _roundedValueToNearestFive(int value) {
    return (value * 0.2).ceil() ~/ 0.2;
  }
}
