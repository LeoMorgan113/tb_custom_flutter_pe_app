import 'package:flutter/material.dart';
import '../scan_stepper.dart';

class ScanUser extends StatefulWidget {
  final String userQrCode;
  final Function(Types) scanQrCodeCallback;
  final bool userValid;

  ScanUser({required this.userQrCode, required this.scanQrCodeCallback,
    required this.userValid});

  @override
  State<ScanUser> createState() => _ScanUserState();
}

class _ScanUserState extends State<ScanUser> {
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
                            onTap: () {
                              widget.scanQrCodeCallback(Types.USER);
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
                        "Scan User QR code",
                        style: TextStyle(
                            color: Color(0xFF424242),
                            fontSize: 24,
                            fontWeight: FontWeight.normal,
                            height: 1.33),
                      ),
                    )),
                if(!widget.userValid && widget.userQrCode.isNotEmpty)
                  Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Text(
                          "User's QR is not valid",
                          style: TextStyle(
                              color: Color(0xFFD21616),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              height: 1.33),
                        ),
                      )),
              ]),
        ),
      );
  }
}
