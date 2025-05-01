// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../screens/MainUiLogic.dart'; // 실제 홈 화면 UI
import 'screens/print_history_page.dart';
import 'models/print_record.dart';
import 'core/record_store.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// ✅ 전역에서 접근 가능한 인쇄 기록 리스트
List<PrintRecord> printRecords = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 반드시 가장 먼저
  await loadPrintRecords();                  // ✅ DB에서 기록 먼저 불러오기
  runApp(const MyApp());                     // ✅ 그다음 앱 실행
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '프린터 앱',
      locale: const Locale('ko', 'KR'), // 🇰🇷 로케일 설정
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(), // 메인 페이지는 MainUiLogic.dart에서 정의한 HomePage
    );
  }
}
