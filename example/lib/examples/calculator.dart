import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String equation = '';
  String submittedEquation = '';
  bool isCalculated = false;
  String get result {
    if (equation.isEmpty || !isCalculated) {
      return 'return f:Text(text: "0");';
    }

    return 'return f:Text(text: toString(($submittedEquation)));';
  }

  void updateEquation(String value) {
    setState(() {
      isCalculated = false;
      equation += value;
    });
  }

  void backSpace() {
    setState(() {
      isCalculated = false;
      equation = equation.substring(0, equation.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blueGrey[800],
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    equation,
                    style: const TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TartStatefulWidget(
                    source: result,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.blueGrey[900],
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 2.25,
                padding: const EdgeInsets.all(4),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildButton(
                      'C',
                      Colors.red[400]!,
                      () => setState(() {
                            equation = '';
                            isCalculated = false;
                          })),
                  _buildButton(
                      '(', Colors.blueGrey[700]!, () => updateEquation('(')),
                  _buildButton(
                      ')', Colors.blueGrey[700]!, () => updateEquation(')')),
                  _buildButton('⌫', Colors.blueGrey[600]!, backSpace),
                  _buildButton(
                      '7', Colors.blueGrey[300]!, () => updateEquation('7')),
                  _buildButton(
                      '8', Colors.blueGrey[300]!, () => updateEquation('8')),
                  _buildButton(
                      '9', Colors.blueGrey[300]!, () => updateEquation('9')),
                  _buildButton(
                      '÷', Colors.orange[700]!, () => updateEquation('/')),
                  _buildButton(
                      '4', Colors.blueGrey[300]!, () => updateEquation('4')),
                  _buildButton(
                      '5', Colors.blueGrey[300]!, () => updateEquation('5')),
                  _buildButton(
                      '6', Colors.blueGrey[300]!, () => updateEquation('6')),
                  _buildButton(
                      '×', Colors.orange[700]!, () => updateEquation('*')),
                  _buildButton(
                      '1', Colors.blueGrey[300]!, () => updateEquation('1')),
                  _buildButton(
                      '2', Colors.blueGrey[300]!, () => updateEquation('2')),
                  _buildButton(
                      '3', Colors.blueGrey[300]!, () => updateEquation('3')),
                  _buildButton(
                      '-', Colors.orange[700]!, () => updateEquation('-')),
                  _buildButton(
                      '0', Colors.blueGrey[300]!, () => updateEquation('0')),
                  _buildButton(
                      '.', Colors.blueGrey[300]!, () => updateEquation('.')),
                  _buildButton('=', Colors.orange[700]!, () {
                    setState(() {
                      submittedEquation = equation;
                      isCalculated = true;
                    });
                  }),
                  _buildButton(
                      '+', Colors.orange[700]!, () => updateEquation('+')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
