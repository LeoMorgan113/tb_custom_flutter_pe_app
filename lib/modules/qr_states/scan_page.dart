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
                  child: Text('Please press button\nto start scanning process',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22)),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ScanStepperPage(tbContext))
                      );
                    },
                    child: const Text("Start scanning",
                      style: TextStyle(fontSize: 18),),
                  )
              )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
