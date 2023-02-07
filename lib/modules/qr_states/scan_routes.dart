import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/qr_states/scan_page.dart';


class ScanRoutes extends TbRoutes {

  late var scanPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return ScanPage(tbContext);
      });

  ScanRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/scan", handler: scanPageHandler);
  }
}
