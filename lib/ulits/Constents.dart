import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import 'ColorsR.dart';

final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
showErrorDialog(String mgs, String type) {
  Get.snackbar(
    type,
    mgs,
    colorText: Colors.white,
    backgroundColor: ColorsR.appColor,
    snackPosition: SnackPosition.BOTTOM,
  );
}



class Constant {








  static String apiEndpoint = "https://admin.sara777.app/api/v1/";

}
