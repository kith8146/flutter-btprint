// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/MainUiLogic.dart';
import 'screens/print_history_page.dart';
import 'models/print_record.dart';
import 'core/record_store.dart';
import 'core/error_utils.dart'; // ✅ 예외 처리 유틸 추가

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

List<PrintRecord> printRecords = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await loadPrintRecords();
  } catch (e, stack) {
    logError('main.loadPrintRecords', e, stack);
    // 무시하고 앱 실행은 계속
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '프린터 앱',
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
