import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../scan_stepper.dart';

class ScanUser extends StatefulWidget {
  late String userQrCode;
  final Function(String, Types) scanQrCodeCallback;
  final bool userValid;

  ScanUser({required this.userQrCode, required this.scanQrCodeCallback,
    required this.userValid});

  @override
  State<ScanUser> createState() => _ScanUserState();
}

class _ScanUserState extends State<ScanUser> {
  String _barcodeString = "null11";
  int _counter = 0;
  String _EVENT = 'event';
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
    setState(() {
      _counter = 0;
    });
    super.initState();
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _createProfile("ThingsBoardPEApp");
  }

  void _onEvent(event) {
    print("inside onEvent 0 $event");
    setState(() {
      _EVENT = event;
      _counter++;
      print("inside onEvent 1 $event");
      try {
        Map barcodeScan = jsonDecode(event);
        _barcodeString = barcodeScan['scanData'];
      } catch (e) {
        print('_onEvent Error: $e');
        _barcodeString = "someError";
      }
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
    print("startScan 0");
    _onEvent("{\"scanData\": \"bfc2fbf0-86b6-11ed-a5ef-ff73adaaed5c\"}");
    // _onEvent({'scanData': 222});
  }

  void stopScan() {
    setState((){
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    });
    //
  }


  @override
  Widget build(BuildContext context) {
    return
        Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                GestureDetector(
                  onTapDown: (TapDownDetails) {
                    print('onTapDown');
                    startScan();
                  },
                  onTapUp: (TapUpDetails) async {
                    print('onTapUp');
                    stopScan();
                    widget.userQrCode = _barcodeString;
                    print('onTapUp after $_barcodeString');
                    // await widget.scanQrCodeCallback(widget.userQrCode , Types.USER);
                    setState(() {});
                  },
                  // The custom button
                  child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF599FEE),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          "SCAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),

                // Center(
                //   child: SizedBox.fromSize(
                //     size: Size(240, 240),
                //
                //     child: Container(
                //       decoration: BoxDecoration(
                //         boxShadow: [
                //           BoxShadow(
                //             color: Color(0x27000000),
                //             spreadRadius: 4,
                //             blurRadius: 10,
                //           ),
                //         ],
                //       ),
                //       child: ClipRect(
                //         child: Material(
                //           color: Color(0xFFFFFFFF),
                //           child: InkWell(
                //             splashColor: Color(0xFFDCDCDC),
                //             child: GestureDetector(
                //               onTapDown: (tapDownDetails) {
                //                 startScan();
                //               },
                //               onTapUp: (tapUpDetails) {
                //                 stopScan();
                //                 setState(() {
                //                   widget.userQrCode = _barcodeString;
                //                 });
                //                 widget.scanQrCodeCallback(_barcodeString , Types.USER);
                //               },
                //
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: <Widget>[
                //                   Icon(Icons.qr_code_2, size: 180), // <-- Icon
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text(
                        "Scan User's QR code",
                        style: TextStyle(
                            color: Color(0xFF424242),
                            fontSize: 20,
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
                        "Scanned code: \n${widget.userQrCode}\n$_EVENT",
                        style: TextStyle(
                            color: Color(0xFF03b6fc),
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            height: 1.33),
                      ),
                    )),

                Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        "Counter: \n${_counter}",
                        style: TextStyle(
                            color: Color(0xff2f7a0a),
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            height: 1.33),
                      ),
                    )),
                if(!widget.userValid && widget.userQrCode.isNotEmpty)
                  Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Text(
                          "User's QR is not valid. Please try again",
                          style: TextStyle(
                              color: Color(0xFFD21616),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              height: 1.33),
                        ),
                      ))
                // else
                //   Container(
                //       margin: const EdgeInsets.only(top: 10.0),
                //       child: Center(
                //         child: Text(
                //           "Scanned code: \n"+widget.userQrCode,
                //           style: TextStyle(
                //               color: Color(0xFF03b6fc),
                //               fontSize: 20,
                //               fontWeight: FontWeight.normal,
                //               height: 1.33),
                //         ),
                //       ))
              ]),
        ),
      );
  }
}
