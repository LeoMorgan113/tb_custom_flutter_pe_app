import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import '../../core/context/tb_context_widget.dart';
import 'scan_stepper_page.dart';

class ScanPage extends TbPageWidget {
  ScanPage(TbContext tbContext) : super(tbContext);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends TbPageState<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              child: Text('Please press button\nto start scanning process.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
              child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScanStepperPage(tbContext)));
              },
              child: const Text(
                "Start scanning",
                style: TextStyle(fontSize: 18),
              ),
            ),
          )),
          Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 15, left: 20, right: 20),
              padding: EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFcccccc),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                // crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.info_outline),
                  Container(
                      width: MediaQuery.of(context).size.width - 100,
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                          "The scanning process consists of 3 steps: scanning "
                          "the user's QR code(user ID), order QR, and item "
                          "QR(Material ID). If there is no order QR, "
                          "please leave a comment.")),
                ],
              )),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
