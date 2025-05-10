// MainUiLogic.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/bluetooth_printer_service.dart';
import '../core/print_utils.dart';
import '../core/print_controller.dart';
import '../main.dart'; // navigatorKey 사용을 위해

import '../widgets/channel_section.dart';       // ✅ A/B 채널 UI
import '../widgets/time_input_section.dart';    // ✅ 상차/하차 시간 UI
import '../widgets/vehicle_number_section.dart';
import '../screens/print_history_page.dart';






class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final printerService = BluetoothPrinterService();

  final TextEditingController carNumberController = TextEditingController(text: "0000");
  final TextEditingController customIntervalController = TextEditingController();
  final TextEditingController loadDateController = TextEditingController();
  final TextEditingController loadTimeController = TextEditingController();
  final TextEditingController unloadDateController = TextEditingController();
  final TextEditingController unloadTimeController = TextEditingController();
  String printerStatusText = "프린터 미연결";


  final Map<String, TextEditingController> aControllers = {
    '1': TextEditingController(),
    '2': TextEditingController(),
  };
  final Map<String, TextEditingController> bControllers = {
    '1': TextEditingController(),
    '2': TextEditingController(),
  };

  String selectedInterval = "30분";
  String selectedAState = '';
  String selectedBState = '';
  String previousCarNumber = "8718";
  bool userChecked = true;
  bool oneDayChecked = false;
  bool repeatChecked = false;
  bool isEditingCarNumber = false;

  final temperaturePresets = {
    '냉동': ['-22.0', '-19.0'],
    '냉장': ['2.0', '8.0'],
    '상온': ['15.0', '25.0'],
    '없음': ['', ''],
  };

  @override
  void dispose() {
    carNumberController.dispose();
    customIntervalController.dispose();
    loadDateController.dispose();
    loadTimeController.dispose();
    unloadDateController.dispose();
    unloadTimeController.dispose();
    aControllers.values.forEach((c) => c.dispose());
    bControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void setTemperature(String channel, String state) {
    final temps = temperaturePresets[state] ?? ['', ''];
    if (channel == 'A') {
      aControllers['1']?.text = temps[0];
      aControllers['2']?.text = temps[1];
    } else {
      bControllers['1']?.text = temps[0];
      bControllers['2']?.text = temps[1];
    }
  }

  void updatePrinterStatus({required bool connected, String? name}) {
    setState(() {
      printerStatusText = connected
          ? "✅ 연결됨: ${name ?? '프린터'}"
          : "❌ 프린터 미연결";
    });
  }

  @override
  void initState() {
    super.initState();
    autoReconnectPrinter();
    loadVehicleNumber(); // 🔹 차량번호 불러오기
  }

  void loadVehicleNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('vehicleNumber');

    debugPrint("[LOAD] 차량번호 불러옴: $saved");

    if (saved != null && saved.isNotEmpty) {
      setState(() {
        carNumberController.text = saved;
        previousCarNumber = saved;
      });
    }
  }



  Future<void> autoReconnectPrinter() async {
    final lastMac = await printerService.getLastConnectedPrinter();

    if (lastMac != null) {
      final device = await printerService.connectToPrinter(lastMac); // ✅ 프린터 기기 받아오기

      if (device != null) {
        debugPrint('✅ 이전 프린터에 자동 연결됨: ${device.name}');
        updatePrinterStatus(connected: true, name: device.name); // ✅ 프린터 모델명 사용
      } else {
        debugPrint('❌ 자동 연결 실패');
        updatePrinterStatus(connected: false);
      }

    } else {
      debugPrint('ℹ️ 저장된 프린터 MAC 주소 없음');
      updatePrinterStatus(connected: false);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프린터 앱')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('홈'),
              onTap: () {
                Navigator.pop(context); // Drawer만 닫음
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('인쇄 기록'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrintHistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 연결 상태 표시
                  Row(
                    children: [
                      Icon(
                        printerStatusText.contains("연결됨")
                            ? Icons.check_circle
                            : Icons.error,
                        color: printerStatusText.contains("연결됨")
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        printerStatusText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  // 🔹 연결 또는 해제 버튼 (조건에 따라 토글)
                  printerStatusText.contains("연결됨")
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await printerService.disconnect();
                      updatePrinterStatus(connected: false);
                      Fluttertoast.showToast(
                        msg: "프린터 연결이 해제되었습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    child: const Text('해제'),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      final device = await printerService.connectToPrinterWithSelection(context);                      if (!context.mounted) return;

                      if (device != null) {
                        updatePrinterStatus(connected: true, name: device.name);
                      } else {
                        updatePrinterStatus(connected: false);
                        showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            title: Text('연결 오류'),
                            content: Text('프린터가 연결되지 않았습니다.'),
                          ),
                        );
                      }
                    },
                    child: const Text('연결'),
                  ),
                ],
              ),
            ),


            VehicleNumberSection(
              controller: carNumberController, // ✅ TextEditingController 직접 전달
              onVehicleNumberChanged: (newNum) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('vehicleNumber', newNum);
                debugPrint("[SAVE] 차량번호 저장함: $newNum");

                setState(() {
                  previousCarNumber = newNum;
                });
              },
            ),



            const Divider(),
            buildIntervalSelector(),
            const Divider(),
            buildChannelSection('A채널', selectedAState, (state) {
              setState(() {
                selectedAState = state;
                setTemperature('A', state);
              });
            }, aControllers),
            const Divider(),
            buildChannelSection('B채널', selectedBState, (state) {
              setState(() {
                selectedBState = state;
                setTemperature('B', state);
              });
            }, bControllers),
            const Divider(),
            TimeInputSection(title: '상차 시간', dateController: loadDateController, timeController: loadTimeController),
            const Divider(),
            TimeInputSection(title: '하차 시간', dateController: unloadDateController, timeController: unloadTimeController),
            const Divider(),
            buildOptions(),
            const SizedBox(height: 10),
            buildPrintButton(),
          ],
        ),
      ),
    );
  }

  Widget buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('기록간격:'),
            ...['10분', '20분', '30분'].map((label) => ChoiceChip(
              label: Text(label),
              selected: selectedInterval == label,
              onSelected: (_) => setState(() => selectedInterval = label),
            )),
            ChoiceChip(
              label: const Text('직접입력'),
              selected: !['10분', '20분', '30분'].contains(selectedInterval),
              onSelected: (_) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('기록간격 직접입력'),
                    content: TextField(
                      controller: customIntervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '분 단위 숫자 입력'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          final input = customIntervalController.text;
                          final minutes = int.tryParse(input);
                          if (minutes != null && minutes > 0) {
                            setState(() => selectedInterval = "$minutes분");
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "기록간격: $selectedInterval",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }


  Widget buildChannelSection(String title, String selectedState, void Function(String) onSelected, Map<String, TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['냉동', '냉장', '상온', '없음'].map((label) {
            final isSelected = label == selectedState;
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(label),
            );
          }).toList(),
        ),
        TextField(controller: controllers['1'], decoration: const InputDecoration(labelText: '온도1')),
        TextField(controller: controllers['2'], decoration: const InputDecoration(labelText: '온도2')),
      ],
    );
  }

  Widget buildOptions() => ExpansionTile(
    title: const Text('▼ 추가 옵션 보기'),
    children: [
      Wrap(
        spacing: 10,
        children: [
          FilterChip(
            label: const Text('USER'),
            selected: userChecked,
            onSelected: (val) => setState(() {
              userChecked = val;
              if (val) oneDayChecked = false;
            }),
          ),
          FilterChip(
            label: const Text('1일'),
            selected: oneDayChecked,
            onSelected: (val) => setState(() {
              oneDayChecked = val;
              if (val) userChecked = false;
            }),
          ),
          FilterChip(
            label: const Text('반복출력'),
            selected: repeatChecked,
            onSelected: (val) => setState(() => repeatChecked = val),
          ),
        ],
      )
    ],
  );

  Widget buildBluetoothButton() => ElevatedButton(
    onPressed: () async {
      final device = await printerService.connectToPrinter(); // ✅ BluetoothDevice? 받아옴
      if (!context.mounted) return;

      if (device != null) {
        updatePrinterStatus(connected: true, name: device.name); // ✅ 모델명 사용
      } else {
        updatePrinterStatus(connected: false);
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('연결 오류'),
            content: Text('프린터가 연결되지 않았습니다.'),
          ),
        );
      }
    },

    child: const Text('블루투스 연결'),
  );

  Widget buildDisconnectButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
    ),
    onPressed: () async {
      await printerService.disconnect();
      updatePrinterStatus(connected: false);
      Fluttertoast.showToast(
        msg: "프린터 연결이 해제되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    },
    child: const Text('연결 해제'),
  );


  Widget buildPrintButton() => ElevatedButton(
    onPressed: () {
    // 1) A/B 채널 선택 여부 검사
    if (selectedAState.isEmpty || selectedBState.isEmpty) {
    Fluttertoast.showToast(
    msg: "A채널과 B채널을 모두 선택해주세요.",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    );
    return; // 더 이상 진행하지 않음
    }
    // 2) 선택이 모두 되어 있으면 기존 로직 실행
      exampleGenerateAndPrintText(
        vehicleNumber: carNumberController.text,
        intervalText: selectedInterval,
        loadDate: loadDateController.text,
        loadTime: loadTimeController.text,
        unloadDate: unloadDateController.text,
        unloadTime: unloadTimeController.text,
        userChecked: userChecked,
        oneDayChecked: oneDayChecked,
        minA: double.tryParse(aControllers['1']!.text) ?? -20.0,
        maxA: double.tryParse(aControllers['2']!.text) ?? -18.0,
        minB: double.tryParse(bControllers['1']!.text) ?? 2.0,
        maxB: double.tryParse(bControllers['2']!.text) ?? 8.0,
      );
    },
    child: const Text('인쇄'),
  );
}
