import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../scan_stepper.dart';
import 'package:quantity_input/quantity_input.dart';

class ScanItem extends StatefulWidget {
  late String itemQrCode;
  final Function(String, Types) scanQrCodeCallback;
   final Function(int) itemCountCallback;

  ScanItem({required this.itemQrCode, required this.scanQrCodeCallback,
     required this.itemCountCallback});

  @override
  State<ScanItem> createState() => _ScanItemState();
}

class _ScanItemState extends State<ScanItem> {
  int simpleIntInput = 1;
  String _barcodeString = "";
  // zebra scan
  static const MethodChannel methodChannel =
  MethodChannel('org.thingsboard.pe.app/command');
  static const EventChannel scanChannel =
  EventChannel('org.thingsboard.pe.app/scan');


  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson =
      jsonEncode({"command": command, "parameter": parameter});

      await methodChannel.invokeMethod(
          'sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      throw Exception('Failed to send command.');
    }
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      throw Exception('Failed to create profile.');
    }
  }

  @override
  void initState(){
    super.initState();
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    // _createProfile("ThingsBoardPEApp");
  }

  void _onEvent(event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);
      _barcodeString = barcodeScan['scanData'];
    });
  }

  void _onError(Object error) {
    setState(() {
      _barcodeString = "Error";
    });
  }

  void startScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
    });
  }

  void stopScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    });
  }


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
                          // onTap: () async {
                          //   await widget.scanQrCodeCallback(Types.ITEM);
                          //   setState(() {
                          //     widget.itemCountCallback(simpleIntInput);
                          //   });
                          // },
                          child: GestureDetector(
                            onTapDown: (tapDownDetails) {
                              startScan();
                            },
                            onTapUp: (tapUpDetails)  {
                              stopScan();
                              setState(() {
                                widget.itemQrCode = _barcodeString;
                                widget.itemCountCallback(simpleIntInput);
                              });
                              widget.scanQrCodeCallback(_barcodeString, Types.ITEM);
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
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      "Scan Item's QR code",
                      style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          height: 1.33),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Center(
                    child: Text(
                      "Tap to scan",
                      style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          height: 1.2),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Text(
                      "Scanned code: \n"+_barcodeString,
                      style: TextStyle(
                          color: Color(0xFF03b6fc),
                          fontSize: 20,
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
