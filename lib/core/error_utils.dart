import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void showUserFriendlyError(dynamic error) {
  debugPrint("[ERROR]: $error");

  final errorText = error.toString().toLowerCase();
  String userMessage = "알 수 없는 오류가 발생했습니다.";

  if (errorText.contains('missingpluginexception')) {
    userMessage = "⚠️ 인쇄 기능을 사용할 수 없습니다.\n앱을 다시 시작해 주세요.";
  } else if (errorText.contains('bluetooth is not available')) {
    userMessage = "블루투스가 꺼져 있습니다.\n설정에서 Bluetooth를 켜 주세요.";
  } else if (errorText.contains('not connected') || errorText.contains('disconnected')) {
    userMessage = "프린터 연결이 끊어졌습니다.\n다시 연결해 주세요.";
  } else if (errorText.contains('image') || errorText.contains('cannot decode image')) {
    userMessage = "이미지를 인쇄하는 중 문제가 발생했습니다.";
  } else if (errorText.contains('unsupportedoperation')) {
    userMessage = "이 기기에서는 인쇄 기능을 지원하지 않습니다.";
  } else if (errorText.contains('paper') || errorText.contains('no paper')) {
    userMessage = "프린터에 용지가 없을 수 있습니다.\n확인해 주세요.";
  }

  Fluttertoast.showToast(
    msg: userMessage,
    toastLength: Toast.LENGTH_LONG,
    //timeInSecForIosWeb: 5,
    backgroundColor: Colors.redAccent,
    textColor: Colors.white,
  );
}
