import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlNumberDetails extends StatefulWidget {
  final String controlNumber;

  const ControlNumberDetails({super.key, required this.controlNumber});

  @override
  State<ControlNumberDetails> createState() => _ControlNumberDetailsState();
}

class _ControlNumberDetailsState extends State<ControlNumberDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009999),
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Payment Details',
            style:
                TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(
              height: 12,
            ),
            Center(
              child: Text(
                'Control Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                '${widget.controlNumber}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'How to Pay:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Using Mobile Money Operator:\n'
              '   - M-Pesa: Dial *150*00#, Select "Pay by M-Pesa" and enter the control number.\n'
              '   - Tigo Pesa: Dial *150*01#, Select "Pay Bill" and enter the control number.\n'
              '   - Airtel Money: Dial *150*60#, Select "Pay Bill" and enter the control number.\n',
              style: TextStyle(fontSize: 11),
            ),
            SizedBox(height: 10),
            Text(
              '2. Through Bank:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '   - Visit your bank and provide the control number for payment.',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
