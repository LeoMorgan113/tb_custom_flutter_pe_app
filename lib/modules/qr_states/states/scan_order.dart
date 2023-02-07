import 'package:flutter/material.dart';
import '../scan_stepper.dart';

class ScanOrder extends StatefulWidget {
  final String orderQrCode;
  final Function(Types) scanQrCodeCallback;
  final Function continueStep;
  final Function(String) commentCallback;

  ScanOrder({required this.orderQrCode, required this.scanQrCodeCallback,
    required this.continueStep, required this.commentCallback});

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
                            widget.scanQrCodeCallback(Types.ORDER);
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
                      "Scan Order QR code",
                      style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          height: 1.33),
                    ),
                  )),
              // Text((widget.orderQrCode != '-1').toString()),
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
