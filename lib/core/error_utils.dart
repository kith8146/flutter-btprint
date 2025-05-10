import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// 사용자에게 보여줄 에러 메시지를 분석하여 전달
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
  } else if (errorText.contains('formatexception') && errorText.contains('invalid date')) {
    userMessage = "상차 또는 하차 날짜/시간 입력이 누락되었거나 잘못되었습니다.";
  } else if (errorText.contains('rangeerror')) {
    userMessage = "입력값의 범위가 잘못되었습니다.\n온도나 시간 설정을 다시 확인해 주세요.";
  } else if (errorText.contains('null') && errorText.contains('lateinitializationerror')) {
    userMessage = "값이 제대로 초기화되지 않았습니다. 입력을 다시 확인해 주세요.";
  }

  Fluttertoast.showToast(
    msg: userMessage,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: Colors.redAccent,
    textColor: Colors.white,
  );
}

/// Bluetooth 관련 에러 핸들링
void handleBluetoothError(dynamic e, StackTrace stacktrace) {
  debugPrint("🟥 Bluetooth 연결 에러: $e");
  debugPrint("🟥 스택트레이스: $stacktrace");
  showUserFriendlyError(e);
}

/// 개발자 디버깅용 로그 출력
void logError(String origin, Object error, [StackTrace? stack]) {
  debugPrint("🧨 [$origin] 예외 발생: ${error.runtimeType} - $error");
  if (stack != null) {
    debugPrint("📄 StackTrace:\n$stack");
  }
}
