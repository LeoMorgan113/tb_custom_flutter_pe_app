import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thingsboard_app/modules/qr_states/states/scan_finised.dart';
import 'package:thingsboard_app/modules/qr_states/states/scan_item.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';
import '../../core/context/tb_context.dart';
import '../../widgets/tb_progress_indicator.dart';
import 'states/scan_order.dart';
import 'states/scan_user.dart';
import 'package:http/http.dart' as http;

enum Types { USER, ORDER, ITEM }


class ScanStepper extends StatefulWidget {
  final ThingsboardClient tbClient;
  final TbContext tbContext;

  ScanStepper({required this.tbClient, required this.tbContext});

  @override
  State<ScanStepper> createState() => _ScanStepperState();
}

class _ScanStepperState extends State<ScanStepper> {
  // zebra scan
  static const MethodChannel methodChannel =
  MethodChannel('org.thingsboard.pe.app/command');
  static const EventChannel scanChannel =
  EventChannel('org.thingsboard.pe.app/scan');

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

  late Types _currentType;
  String _barcodeString = "";

  @override
  void initState(){
    super.initState();
    // _currentType = Types.USER;
    Stream<dynamic> user = scanChannel.receiveBroadcastStream();
    user.listen(_onEvent, onError: _onError);
    _createProfile("ThingsBoardPEApp");
  }

  void _onEvent(event) {
    print("inside onEvent 0 $_currentType");
    setState(() {
      // _EVENT = event;
      // _counter++;
      print("inside onEvent 1 $event");
      // try {

      Map barcodeScan = jsonDecode(event);
      _barcodeString = barcodeScan['scanData'];
      setQrCode(_barcodeString, _currentType);
      // } catch (e) {
      //   print('_onEvent Error: $e');
      //   _barcodeString = "someError";
      // }
    });
  }

  void _onError(Object error) {
    setState(() {
      _barcodeString = "Error";
    });
  }

  void startScan(Types type) {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
      _currentType = type;
      print('Type in start scan: $type');
    });
    print("startScan 0");
    // _onEvent("{\"scanData\": \"bfc2fbf0-86b6-11ed-a5ef-ff73adaaed5c\"}");
    // _onEvent({'scanData': 222});
  }

  void stopScan() {
    setState((){
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    });
    //
  }


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
                          Expanded(
                            child: TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text(
                                  "Back",
                                )),
                          ),
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
                      ));
                },
                steps: <Step>[
                  Step(
                    title: Text(''),
                    // content: _buildScanUser(),
                    content: ScanUser(
                      userQrCode: _barcodeString,
                      // scanQrCodeCallback: setQrCode,
                      startScan: startScan,
                      stopScan: stopScan,
                      userValid: isUserValid,
                    ),
                    isActive: _currentStep == 0,
                    state:
                    _currentStep > 0 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: Text(''),
                    content: ScanOrder(
                      orderQrCode: getOrderQrCode,
                      startScan: startScan,
                      stopScan: stopScan,
                      continueStep: continued,
                      commentCallback: setComment,),
                    isActive: _currentStep == 1,
                    state:
                    _currentStep > 1 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: Text(''),
                    content: ScanItem(
                        itemQrCode: getItemQrCode,
                        startScan: startScan,
                        stopScan: stopScan,
                        itemCountCallback: setItemQuantity),
                    isActive: _currentStep == 2,
                    state:
                    _currentStep >= 2 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: Text('Send'),
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


  void scanQRCode(String qrCode, Types type) async {
    try {
      // final qrCode = await FlutterBarcodeScanner.scanBarcode(
      //     '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      print('scanQRCode $qrCode');
      // await setQrCode(qrCode, type);

    } on PlatformException {
      getResult = 'Failed to scan QR Code.';
    }
  }

  void setQrCode(code, type) async {
    // print('scanQRCode $code');
    if (type == Types.USER){
      getUserQrCode = code;
      userId = await checkUser(getUserQrCode);
    }
    setState(() {
      if (type == Types.USER) {
        getUserQrCode = code;

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
    // var id = 'bfc2fbf0-86b6-11ed-a5ef-ff73adaaed5c';
    var id = userId;
    // print('iddddd: $id');
    try{
      var response = await widget.tbClient.get("/api/wedel/user?azureId=${id.toString()}");

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
    // print('getUserQrCode:  $getUserQrCode, getItemQrCode $getItemQrCode,'
    //     '\ngetOrderQrCode $getOrderQrCode');

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

        print('request body: $body');
        takeItemRequest(body);
        lastField = true;
      } else {
        lastField = false;
      }
    }) : null;
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

    try{
      var response = await widget.tbClient.post('/api/wedel/take',
        data: body,
      );

      if(response.statusCode == 200){
        setRequestStatus(true);
      }else{
        // print(response.statusMessage.me);
        setRequestStatus(false);
      }
    } catch(e){
      print(e);
    }
  }
}
