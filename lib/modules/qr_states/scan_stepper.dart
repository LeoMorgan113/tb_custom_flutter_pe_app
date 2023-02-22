import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:thingsboard_app/modules/qr_states/states/scan_finised.dart';
import 'package:thingsboard_app/modules/qr_states/states/scan_item.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

import '../../core/context/tb_context.dart';
import '../../widgets/tb_progress_indicator.dart';
import 'states/scan_order.dart';
import 'states/scan_user.dart';
import 'package:http/http.dart' as http;
import 'package:zebrascanner/zebrascanner.dart';

enum Types { USER, ORDER, ITEM }


class ScanStepper extends StatefulWidget {
  final ThingsboardClient tbClient;
  final TbContext tbContext;

  ScanStepper({required this.tbClient, required this.tbContext});

  @override
  State<ScanStepper> createState() => _ScanStepperState();
}

class _ScanStepperState extends State<ScanStepper> {
  var getResult = 'QR Code Result';
  var getUserQrCode = '', getOrderQrCode = '', getItemQrCode = '';
  int itemCount = 1;
  late http.Response response;
  int _currentStep = 0;
  bool lastField = false;
  late String comment = '';
  late Object body = {};
  late String userId = '';
  late bool isUserValid = false;
  late bool requestSuccess = false;
  late bool orderIdSet = false;
  late bool itemIdSet = false;
  bool _loading = true;

  // Zebra app
  String _platformVersion = 'Unknown';
  dynamic map;
  StreamSubscription? subscription;
  String? eventData = "";


  @override
  void initState(){
    super.initState();
    // to get device OS Version
    initPlatformState();
    // to get Barcode Events from Zebra Scanner
    initBarcodeReceiver();
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription!.cancel();
    }
  }


  initBarcodeReceiver() {
    subscription = Zebrascanner.getBarCodeEventStream.listen((barcodeData) {
      setState(() {
        map = barcodeData;
        var _list = map.values.toList();

        // print(map);
        // // Barcode
        // print(_list[0]);
        // // BarcodeType
        // print(_list[1]);
        // // ScannerId
        // print(_list[2]);

        eventData = _list[0] + "-" + _list[1] + "-" + _list[2];
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await Zebrascanner.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Stepper(
            type: StepperType.horizontal,
            physics: ScrollPhysics(),
            currentStep: _currentStep,
            onStepContinue: lastField ? null : continued,
            onStepCancel: _currentStep == 0 ? null : cancel,
            controlsBuilder: (context, details) {
              return Container(
                  margin: EdgeInsets.only(top: 10),
                  child: lastField
                      ? Row(
                          children: [
                            if(!_loading)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Close"),
                                ),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            if (_currentStep != 0)
                              Expanded(
                                child: TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text(
                                      "Back",
                                    )),
                              ),
                            const SizedBox(width: 12),
                            if (_currentStep == 0)
                              // User scan
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isUserValid ?
                                      details.onStepContinue
                                      : null ,
                                  child: Text("Next"),
                                ),
                              )
                            else if (_currentStep == 1)
                              // order scan
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: orderIdSet
                                      ? details.onStepContinue
                                      : null,
                                  child: Text("Next"),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: itemIdSet ?
                                      details.onStepContinue
                                      : null,
                                  child: const Text("Send request"),
                                ),
                              ),

                          ],
                        ),);
            },
            steps: <Step>[
              Step(
                title: Text('User'),
                // content: _buildScanUser(),
                content: Column(
                  children: [
                    ScanUser(
                        userQrCode: getUserQrCode,
                        scanQrCodeCallback: openBarcodeScreen,
                        userValid: isUserValid,
                    ),
                    Text('Scanned Barcode/Qrcode ' + eventData!,
                      style: TextStyle(color: Colors.green),)
                  ],
                ),
                isActive: _currentStep == 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: Text('Order'),
                content: ScanOrder(
                    orderQrCode: getOrderQrCode,
                    scanQrCodeCallback: openBarcodeScreen,
                    continueStep: continued,
                    commentCallback: setComment,),
                isActive: _currentStep == 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: Text('Item'),
                content: ScanItem(
                    itemQrCode: getItemQrCode,
                    scanQrCodeCallback: openBarcodeScreen,
                    itemCountCallback: setItemQuantity),
                isActive: _currentStep == 2,
                state:
                    _currentStep >= 2 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: Text('Finish'),
                content:
                _loading ?
                      SizedBox(
                        height: 500,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                TbProgressIndicator(widget.tbContext),
                                Padding(padding: EdgeInsets.only(top: 15)),
                                Text('Processing...',
                                style: TextStyle(
                                  fontSize: 18
                                ),)
                            ]),
                      )
                    : ScanFinished(status: requestSuccess),
                isActive: _currentStep == 3,
                state:
                    _currentStep >= 3 ? StepState.complete : StepState.disabled,
              ),
            ],
          )),
        ],
      ),
    );
  }

  setQrCode(code, type) {
    setState(() async {
      if (type == Types.USER) {
        getUserQrCode = code;
        userId = await checkUser(getUserQrCode);
        if(userId.isNotEmpty){
          setUserValidation(true);
        }else{
          setUserValidation(false);
        }
      } else if (type == Types.ORDER) {
        getOrderQrCode = code;
        if(getOrderQrCode!='-1' || getOrderQrCode!=''){
          setOrderId(true);
        }
      } else if (type == Types.ITEM) {
        getItemQrCode = code;
        setItemId(true);
      }
    });
  }


  Future<dynamic> checkUser(String userId,{RequestConfig? requestConfig}) async{
    // var id = '296adab0-852b-11ed-8927-6933c7590d09';
    var id = userId;
    try{
      var response = await widget.tbClient.
      get("/api/wedel/user?azureId=${id.toString()}");
      print(response);
      if(response.statusCode == 200){
        Map<String, dynamic> jsonMap  = jsonDecode(response.toString());
        var userId = jsonMap['userId']['id'];
        return userId;
      }
    }catch(e){
      setUserValidation(false);
      throw Exception('Failed to check user.');
    }
  }

  //SCANNER FOR ZEBRA DEVICE
  Future<void> openBarcodeScreen(Types type) async {
    String? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await Zebrascanner.barcodeScreen;

      setQrCode(result, type);
    } on PlatformException {
      result = 'Failed to open the screen';
    }
  }


  // SCANNER FOR SMARTPHONE
  void scanQRCode(Types type) async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      setQrCode(qrCode, type);
    //
    } on PlatformException {
      getResult = 'Failed to scan QR Code.';
    }
  }

  setItemId(val){
    setState(() {
      itemIdSet = val;
    });
  }

  setOrderId(val){
    setState(() {
      orderIdSet = val;
    });
  }

  setComment(value){
    setState(() {
      comment = value;
    });
  }

  setItemQuantity(num){
    setState(() {
      itemCount = num;
    });
  }

  setUserValidation(val){
    setState(() {
      isUserValid = val;
    });
  }

  setRequestStatus(val){
    setState(() {
      requestSuccess = val;
    });
  }

  continued() {

    _currentStep < 4
        ? setState(() {
            _currentStep += 1;
            if (_currentStep == 3) {
              body = {
                "itemType": getItemQrCode,
                // "itemType": "6cd0d1a0-8c20-11ed-a932-f5796fe3fac8",
                "orderId": getOrderQrCode.isNotEmpty ? getOrderQrCode : comment,
                "userId": userId,
                "itemCount": itemCount
              };
              takeItemRequest(body);
              lastField = true;
            } else {
              lastField = false;
            }
          })
        : null;
  }

  cancel() {
    _currentStep > 0
        ? setState(() {
      lastField = false;
      _currentStep -= 1;
    }) : null;
  }

  Future<void> takeItemRequest(Object body,{RequestConfig? requestConfig}) async{
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _loading = false;
      });
    });

    var response = await widget.tbClient.post('/api/wedel/take',
        data: body,
    );

    if(response.statusCode == 200){
      setRequestStatus(true);
    }else{
      setRequestStatus(false);
    }

  }
}
