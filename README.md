# btprint (flutter-btprint)

냉동탑차 온도기록지를 블루투스 프린터로 출력하는 Flutter 앱입니다.
차량번호, 기록 간격, A/B 채널 온도 범위, 상차/하차 시간을 입력하면 기록지 텍스트를 자동 생성해 인쇄합니다.

## 주요 기능

- 차량번호 설정 및 저장
- 기록 간격 선택(10분 / 20분 / 30분) 또는 직접 입력
- A, B 채널별 상태 선택(냉동 / 냉장 / 상온 / 없음) 및 온도 범위 수정
  - 냉동 -22.0 ~ -19.0, 냉장 2.0 ~ 8.0, 상온 15.0 ~ 25.0 이 기본 프리셋
  - **'없음'을 선택한 채널은 출력에서 온도값이 표시되지 않음**
- 상차 / 하차 날짜·시간 설정
- 블루투스 프린터 선택 연결, 앱 시작 시 마지막 프린터 자동 재연결
- 한글·특수문자 깨짐 방지 (텍스트 → 이미지 변환 후 출력)
- 출력 기록 저장, 상세 보기, 재인쇄, 스와이프 삭제, 날짜 필터

## 개발 환경

| 항목 | 내용 |
|---|---|
| Flutter | 3.44.7 (stable) |
| Dart SDK | ^3.7.2 |
| 앱 ID | com.taehwan.btprint |
| 프린터 | PT-210 (ESC/POS) |
| 블루투스 패키지 | blue_thermal_printer |
| 저장소 | SQLite(sqflite) - 출력 기록 / SharedPreferences - 차량번호·설정 |

## 프로젝트 구조

```
.github/workflows/
└── build-apk.yml              # GitHub Actions: 디버그 APK 자동 빌드
lib/
├── main.dart
├── core/
│   ├── bluetooth_printer_service.dart   # 프린터 검색/연결/해제, 마지막 기기 저장
│   ├── database_helper.dart             # SQLite 초기화 및 CRUD
│   ├── error_utils.dart                 # 에러 처리, 사용자 안내 메시지
│   ├── print_controller.dart            # 입력값 → 기록 생성 → 출력 흐름 제어
│   ├── print_utils.dart                 # 출력 텍스트 생성, 텍스트 → 이미지 변환
│   ├── record_generator.dart            # 간격별 온도 기록 생성
│   └── record_store.dart                # 출력 기록 저장소
├── models/
│   └── print_record.dart
├── screens/
│   ├── MainUiLogic.dart                 # 메인 화면
│   └── print_history_page.dart          # 출력 기록 화면
└── widgets/
    ├── channel_section.dart
    ├── time_input_section.dart
    └── vehicle_number_section.dart
```

## 실행 / 빌드

```bash
flutter pub get
flutter run -d <기기 ID>      # flutter devices 로 ID 확인
```

블루투스 프린터 연결은 에뮬레이터에서 테스트할 수 없으므로 실제 Android 기기가 필요합니다.

### APK 받기 (GitHub Actions)

`main` 브랜치에 push하면 GitHub Actions(`build-apk.yml`)가 디버그 APK를 자동으로 빌드합니다.

1. 저장소의 **Actions** 탭에서 최신 실행(초록 체크)을 엽니다.
2. 페이지 맨 아래 **Artifacts**의 `app-debug-apk`를 내려받습니다. (zip)
3. 압축을 풀면 나오는 `app-debug.apk`를 폰에 설치합니다. ("출처를 알 수 없는 앱" 허용 필요)

디버그 서명 빌드이므로, 이전에 설치한 앱 위에 덮어 설치되지 않으면 삭제 후 재설치해야 할 수 있습니다. 이 경우 앱에 저장된 출력 기록과 차량번호가 함께 지워집니다.

## 변경 이력

### 2026-10-11 - 최신 Flutter(3.44.7) 빌드 대응 및 CI 정비

| 파일 | 변경 |
|---|---|
| `pubspec.yaml`, `pubspec.lock` | `intl`을 `0.19.0`에서 `0.20.2`로 고정. Flutter 3.44.7의 `flutter_localizations`가 `intl 0.20.2`를 요구해 의존성 충돌이 나던 문제 해결. 이에 맞춰 lock 파일 갱신 |
| `.github/workflows/build-apk.yml` | `blue_thermal_printer 1.2.3`의 `android/build.gradle`에 `namespace`가 없어 빌드가 실패하던 문제를 해결하는 단계(`Patch blue_thermal_printer namespace`) 추가. 플러그인의 `AndroidManifest.xml`에 있는 `package` 값을 읽어 `namespace`로 넣음 |
| `README.md` | 프로젝트 구조, 변경 이력, APK 받는 방법, 빌드 참고사항 정리 |

관련 커밋: `b8d7650`, `e552ebd`, `44565d6`, `c71fefd`

### 2026-07-23 - A채널 '없음' 선택 시에도 온도가 출력되던 문제 수정

**증상**: A채널(또는 B채널)을 '없음'으로 선택해도 기록지에 온도가 그대로 인쇄됨.

**원인**: 출력 텍스트를 만드는 `generateSamplePrintText`는 채널 상태가 `"없음"`이면 온도를 생략하도록 이미 작성되어 있었음. 그런데 이 함수를 호출하는 `exampleGenerateAndPrintText`가 화면에서 선택한 채널 상태를 받지 않고 항상 빈 문자열(`''`)을 넘기고 있어서, `"없음"` 조건이 한 번도 동작하지 않았음.

**수정 내용**

| 파일 | 변경 |
|---|---|
| `lib/core/print_controller.dart` | `exampleGenerateAndPrintText`에 `channelAState`, `channelBState` 필수 파라미터 추가. `generateSamplePrintText` 호출 시 `''` 대신 이 값을 전달 |
| `lib/screens/MainUiLogic.dart` | 인쇄 버튼에서 `selectedAState`, `selectedBState`를 함께 전달 |

**CI 추가**

| 파일 | 변경 |
|---|---|
| `.github/workflows/build-apk.yml` | 디버그 APK 자동 빌드 워크플로우 신규 추가. Flutter 3.44.7 사용 (프로젝트의 Dart ^3.7.2 요구 때문에 3.24.0에서 상향) |

관련 커밋: `da7c171`, `056256f`, `451b076`, `8858219`

### 이전 버전

- **v1.1.0** (2025-05-08): 프린터 선택 연결, 에러 처리 개선, MAC 주소 숨김, 출력 기록 화면 리팩토링 및 날짜 필터
- **v1.0.0**: 초기 버전 - 자동 연결, 텍스트·이미지 출력, 출력 기록 관리

## 빌드 참고사항

최신 Flutter(3.44.7) / Android Gradle Plugin(AGP 8) 환경에서 빌드할 때 알아둘 점입니다.

**1. intl 버전**

`pubspec.yaml`에 `intl: 0.20.2`로 고정되어 있습니다. `flutter_localizations`가 이 버전을 요구하므로, Flutter SDK를 올릴 때는 SDK가 요구하는 `intl` 버전과 맞는지 확인하세요. 맞지 않으면 `flutter pub get`에서 아래와 같은 충돌이 납니다.

```
Because btprint depends on flutter_localizations from sdk which depends on intl 0.20.2, intl 0.20.2 is required.
```

**2. blue_thermal_printer namespace 누락**

`blue_thermal_printer 1.2.3`의 `android/build.gradle`에 `namespace`가 없어 AGP 8 이상에서 아래 오류가 납니다.

```
Namespace not specified. Specify a namespace in the module's build file: ...blue_thermal_printer-1.2.3\android\build.gradle
```

**GitHub Actions 빌드**에서는 워크플로우가 이 문제를 자동으로 패치하므로 따로 할 일이 없습니다.

**내 PC에서 직접 빌드(`flutter run`)할 때**는 아래처럼 pub 캐시에 있는 플러그인 폴더(Windows 기준 `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\blue_thermal_printer-1.2.3\android\`)를 한 번 직접 고쳐야 합니다.

1. `src/main/AndroidManifest.xml`의 `package="..."` 값을 확인
2. 같은 폴더 `build.gradle`의 `android {` 바로 아래에 `namespace '확인한 package 값'` 추가

이 수정은 캐시 파일을 직접 고치는 방식이라 `flutter pub cache` 정리나 다른 PC에서는 다시 해야 합니다.

## 향후 추가 예정

- 설정 화면 (테마, 기본값 관리 등)
- 기록 내보내기 (CSV/JSON)
- 반복출력(스케줄러) 기능
- 더미 데이터 추가 기능 (테스트용)
