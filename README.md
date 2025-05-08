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
- **출력 기록 저장 및 관리**
- **출력 기록 스와이프 삭제**
- **출력 기록 상세보기 및 재인쇄**
- **채널 미선택 시 안내 메시지 출력**

## 🔧 개발 환경

- **Flutter SDK**: 최신 버전
- **언어**: Dart
- **프린터 모델**: PT-210 (ESC/POS 명령 지원)
- **IDE**: Android Studio 또는 VS Code

## 📂 프로젝트 구조 (리팩토링 완료 버전)

lib/
├── main.dart
├── core/
│ ├── bluetooth_printer_service.dart
│ ├── database_helper.dart
│ ├── error_utils.dart
│ ├── print_controller.dart
│ ├── print_utils.dart
│ ├── record_generator.dart
│ ├── record_store.dart
├── models/
│ └── print_record.dart
├── screens/
│ ├── MainUiLogic.dart
│ ├── print_history_page.dart
├── widgets/
│ ├── channel_section.dart
│ ├── time_input_section.dart
│ └── vehicle_number_section.dart


## 💾 데이터 저장

- **출력 기록**: SQLite (sqflite)
- **차량번호 및 설정값**: SharedPreferences

## 🔌 블루투스 기능

- **패키지**: blue_thermal_printer
- 최근 연결된 프린터 자동 재연결
- 연결 해제 및 상태 토글 버튼 제공

## 📝 향후 추가 예정

- 출력 기록 검색/필터 기능
- 기록 내보내기 (CSV/JSON)
- 설정 화면 추가 (테마, 기본값 관리 등)
- 반복출력(스케줄러) 기능
- 더미 데이터 추가 기능 (테스트용)
