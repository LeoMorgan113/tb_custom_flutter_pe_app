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
        body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                child: Text(
                    'Aby rozpocząć pobranie \nproszę nacisnąć przycisk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)),
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
                  "Rozpocznij skanowanie",
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
                            "Proces pobrania składa się z 3 etapów: "
                            "\n1)Skanowanie kodu QR użytkownika"
                            "\n2)Skanowanie numeru zlecenia lub podanie komentarza "
                            "\n3)Skanowanie części",
                            style: TextStyle(fontSize: 18, height: 1.5))),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                )),
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
