import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../scan_stepper.dart';

class ScanOrder extends StatefulWidget {
  late String orderQrCode;
  final Function continueStep;
  final Function(String) commentCallback;
  final Function(Types) startScan;
  final Function() stopScan;

  ScanOrder({required this.orderQrCode, required this.startScan,
    required this.stopScan, required this.continueStep,
    required this.commentCallback});

  @override
  State<ScanOrder> createState() => _ScanOrderState();
}

class _ScanOrderState extends State<ScanOrder> {
  final TextEditingController myController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonDisabled = true;

  @override
  void initState(){
    super.initState();
    myController.addListener(_commentPrinted);
  }


  void _commentPrinted(){
    if(myController.text.isNotEmpty){
      widget.commentCallback(myController.text);
      _isButtonDisabled = false;
    }else{
      widget.commentCallback('');
      _isButtonDisabled = true;
    }
  }

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
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
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: Center(
                    child: Text(
                      "Order's QR code",
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
                      print('onTapDown');
                      widget.startScan(Types.ORDER);
                    },
                    onTapUp: (_) async {
                      print('onTapUp');
                      widget.stopScan();
                    },
                    child: ElevatedButton.icon(
                      // padding: EdgeInsets.zero,
                      // style: ButtonStyle(
                      //     backgroundColor:
                      //         MaterialStateProperty.all(Colors.amber)),
                      onPressed: () => {},
                      label: Text(
                        'Scan',
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
                      "Tap to scan",
                      style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          height: 1.2),
                    ),
                  )),
              if (widget.orderQrCode.isNotEmpty)
                Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        "Scanned code: \n${widget.orderQrCode}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF03b6fc),
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            height: 1.33),
                      ),
                    )),
              Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: widget.orderQrCode == '-1' || widget.orderQrCode != ''
                      || widget.orderQrCode.isNotEmpty
                          ? null :
                          () {
                        widget.commentCallback(myController.text);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text('Comment'),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          controller: myController,
                                          validator: (value){
                                            if(value == null || value.isEmpty){
                                              return 'Please enter comment';
                                            }
                                            widget.commentCallback(value);
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText:
                                            'Please, write the reason of skipping this step',
                                            contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 10),
                                          ),
                                          maxLines: 10,
                                          minLines: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      child: Text("Continue"),
                                      onPressed: (){
                                        if(_formKey.currentState!.validate()){
                                          Navigator.pop(context);
                                          widget.continueStep();
                                        }
                                      })
                                ],
                              );
                            });
                      },
                      child: Text('Skip step'),
                    ),
                  )),
            ]),
      ),
    );;
  }
}
