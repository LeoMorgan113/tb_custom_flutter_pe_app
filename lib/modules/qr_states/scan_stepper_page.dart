import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/qr_states/scan_stepper.dart';
import '../../core/context/tb_context_widget.dart';
import '../../widgets/tb_app_bar.dart';

class ScanStepperPage extends TbPageWidget {
  ScanStepperPage(TbContext tbContext) : super(tbContext);


  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends TbPageState<ScanStepperPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        // appBar: TbAppBar(tbContext, title: Text('QR Scanning')),
        body: ScanStepper(tbClient: tbClient, tbContext: tbContext));
  }


  @override
  void dispose() {
    super.dispose();
  }
}
