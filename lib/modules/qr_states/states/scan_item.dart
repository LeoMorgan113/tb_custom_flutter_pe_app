import 'package:flutter/material.dart';
import '../scan_stepper.dart';
import 'package:quantity_input/quantity_input.dart';

class ScanItem extends StatefulWidget {
  final String itemQrCode;
  final Function(Types) scanQrCodeCallback;
   final Function(int) itemCountCallback;

  ScanItem({required this.itemQrCode, required this.scanQrCodeCallback,
     required this.itemCountCallback});

  @override
  State<ScanItem> createState() => _ScanItemState();
}

class _ScanItemState extends State<ScanItem> {
  int simpleIntInput = 1;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Center(
                child: SizedBox.fromSize(
                  size: Size(240, 240),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x27000000),
                          spreadRadius: 4,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: Material(
                        color: Color(0xFFFFFFFF),
                        child: InkWell(
                          splashColor: Color(0xFFDCDCDC),
                          onTap: () async {
                            await widget.scanQrCodeCallback(Types.ITEM);
                            setState(() {
                              widget.itemCountCallback(simpleIntInput);
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.qr_code_2, size: 180), // <-- Icon
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      "Scan Item QR code",
                      style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          height: 1.33),
                    ),
                  )),
              if(widget.itemQrCode != '-1' && widget.itemQrCode != '')
                QuantityInput(
                    value: simpleIntInput,
                    onChanged: (value) =>
                        setState(() {
                      simpleIntInput = int.parse(value.replaceAll(',', ''));
                      widget.itemCountCallback(simpleIntInput);
                    })
                ),
            ]),
      ),
    );
  }
}
