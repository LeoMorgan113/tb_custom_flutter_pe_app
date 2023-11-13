import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../scan_stepper.dart';

class ScanUser extends StatefulWidget {
  late String userQrCode;
  final bool userValid;
  final Function() startScan;
  final Function() stopScan;

  ScanUser(
      {required this.userQrCode,
      required this.startScan,
      required this.stopScan,
      required this.userValid});

  @override
  State<ScanUser> createState() => _ScanUserState();
}

class _ScanUserState extends State<ScanUser> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Text(
                      "Kod QR użytkownika",
                      style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.33),
                    ),
                  )),
              Center(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: GestureDetector(
                    onTapDown: (_) {
                      widget.startScan();
                    },
                    onTapUp: (_) async {
                      widget.stopScan();
                    },
                    child: ElevatedButton.icon(
                      // padding: EdgeInsets.zero,
                      // style: ButtonStyle(
                      //     backgroundColor:
                      //         MaterialStateProperty.all(Colors.amber)),
                      onPressed: () => {},
                      label: Text(
                        'Skanuj',
                        style: TextStyle(fontSize: 20),
                      ),
                      icon: Icon(Icons.qr_code_2, size: 28),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Center(
                    child: Text(
                      "Dotknij lub naciśnij przycisk",
                      style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 19,
                          fontWeight: FontWeight.normal,
                          height: 1.2),
                    ),
                  )),
              if (widget.userQrCode.isNotEmpty)
                Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        "Zeskanowany kod: \n${widget.userQrCode}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF03b6fc),
                            fontSize: 19,
                            fontWeight: FontWeight.normal,
                            height: 1.33),
                      ),
                    )),
              if (!widget.userValid && widget.userQrCode.isNotEmpty)
                Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        "Kod QR użytkownika jest niepoprawny. \nProszę spróbować ponownie.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFD21616),
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            height: 1.2),
                      ),
                    ))
            ]),
      ),
    );
  }
}
