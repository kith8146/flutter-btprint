# Flutter Bluetooth Printer App (flutter-btprint)

이 앱은 Flutter로 개발된 블루투스 프린터 앱입니다.  
기록 간격 선택, 온도 입력, 상차/하차 시간 설정 후 프린터로 출력할 수 있습니다.

## 📱 주요 기능

- 차량번호 설정 및 저장
- 기록 간격(5분 ~ 60분) 선택 또는 직접 시간 입력
- A, B 채널별 온도 설정 및 수정 가능
- 상차 시간 / 하차 시간 설정
- 블루투스 프린터 연결 및 자동 재연결
- 출력 미리보기 및 인쇄
- 한글 및 특수문자 깨짐 방지 (출력 시 텍스트 → 이미지 변환)
- 사용자가 선택한 옵션에 따라 출력 포맷 자동 생성

## 🔧 개발 환경

- **Flutter SDK**: 최신 버전
- **언어**: Dart
- **프린터 모델**: PT-210 (ESC/POS 명령 지원)
- **IDE**: Android Studio 또는 VS Code

## 📂 프로젝트 구조 (리팩토링 완료 버전)

lib/
├── main.dart
├── MainUiLogic.dart
├── channel_section.dart
├── time_input_section.dart
├── vehicle_number_section.dart
├── print_utils.dart
├── print_controller.dart
├── bluetooth_printer_service.dart
└── record_generator.dart


## 💾 로컬 저장 기능

- 차량번호 및 최근 설정값 SharedPreferences로 저장

## 🔌 블루투스 기능

- Flutter Blue Plus 패키지 사용
- 최근 연결된 프린터 자동 재연결
- 연결 해제 및 상태 토글 버튼 제공

## 📝 향후 추가 예정

- 출력 기록 관리 기능


