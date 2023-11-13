import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quantity_input/quantity_input.dart';

class ScanItem extends StatefulWidget {
  late String itemQrCode;
  final Function(int) itemCountCallback;
  final Function() startScan;
  final Function() stopScan;

  ScanItem({required this.itemQrCode, required this.startScan,
      required this.stopScan, required this.itemCountCallback});

  @override
  State<ScanItem> createState() => _ScanItemState();
}

class _ScanItemState extends State<ScanItem> {
  int simpleIntInput = 1;


  @override
  void initState(){
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
                  margin: const EdgeInsets.only(bottom:15.0),
                  child: Center(
                    child: Text(
                      "Kod QR części",
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
                      setState(() {
                        simpleIntInput = 1;
                      });
                    },
                    onTapUp: (_) async {
                      widget.stopScan();


                    },
                    child: ElevatedButton.icon(
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
              if(widget.itemQrCode != '-1' && widget.itemQrCode != '')
                Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Center(
                      child: Text(
                        "Zeskanowany kod: \n${widget.itemQrCode}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF03b6fc),
                            fontSize: 18,
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
