import 'dart:ui';
import 'package:flutter/material.dart';

class ScanFinished extends StatefulWidget {
  final bool status;
  final String itemName;
  final int itemCount;

  const ScanFinished({required this.status, required this.itemName,
    required this.itemCount});

  @override
  State<ScanFinished> createState() => _ScanFinishedState();
}

class _ScanFinishedState extends State<ScanFinished>{

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              if (widget.status)
                Column(
                  children: [
                    Center(
                      child: SizedBox.fromSize(
                        size: Size(140, 140),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.verified_outlined,
                              size: 120,
                              color: Color(0xFF15B041),
                            ), // <-- Icon
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Center(
                          child: Text(
                            "Dodano część o numerze ${widget.itemName} \n(${widget.itemCount} szt.).",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                height: 1.33),
                          ),
                        ))
                  ],
                )
              else
                Column(
                  children: [
                    Center(
                      child: SizedBox.fromSize(
                        size: Size(140, 140),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.error_outlined,
                              size: 120,
                              color: Color(0xFFD21616),
                            ), // <-- Icon
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Center(
                          child: Text(
                            "Pobranie części odrzucone. \nBłędny numer ID części.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                                height: 1.33),
                          ),
                        ))
                  ],
                )

          ])),
    );
  }
}
