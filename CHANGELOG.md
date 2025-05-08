# Change Log

## v1.1.0 (2025-05-08)
- Bluetooth 프린터 선택 연결 기능 추가 (connectToPrinterWithSelection)
- 기기 선택 다이얼로그(showDevicePicker): MAC 주소 숨기고 이름만 표시하도록 변경
- 에러 핸들링 개선: handleBluetoothError() 추가 및 기존 showUserFriendlyError와 연동
- MainUiLogic.dart 연결 버튼: 자동 연결 → 사용자가 기기 선택 가능하도록 수정
- 앱 시작 시 autoReconnectPrinter()로 이전 연결 기기 자동 연결 유지
- print_utils.dart: 변경 없음 (textToImageBytes 그대로 사용)

## v1.0.0
- 초기 버전: 자동 연결, 텍스트 및 이미지 출력 지원
