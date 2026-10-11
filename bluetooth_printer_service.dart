import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../core/error_utils.dart';

class BluetoothPrinterService {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  static const _lastDeviceKey = 'last_connected_printer';

  /// blue_thermal_printer 1.2.3 은 이미지 높이가 255px 를 넘으면
  /// 프린터에 보내는 헤더(GS v 0)의 높이 값을 잘못 만든다.
  /// 그러면 프린터가 "아직 이미지 데이터가 남아 있다"고 착각해서
  /// 다음 인쇄가 오른쪽으로 밀려 나온다. 그래서 이미지를 이 높이 이하로 잘라서 보낸다.
  static const int _maxStripHeight = 200;
  static const Duration _stripDelay = Duration(milliseconds: 100);

  /// 프린터 연결 함수 (MAC 주소가 있으면 해당 기기로 시도)
  Future<BluetoothDevice?> connectToPrinter([String? macAddress]) async {
    try {
      bool alreadyConnected = await printer.isConnected ?? false;
      if (alreadyConnected) {
        Fluttertoast.showToast(msg: "이미 프린터에 연결되어 있습니다.");
        List<BluetoothDevice> devices = await printer.getBondedDevices();
        BluetoothDevice? connectedDevice = devices.firstWhere(
              (d) => d.name?.contains("PT") ?? false,
          orElse: () => devices.first,
        );
        return connectedDevice;
      }

      List<BluetoothDevice> devices = await printer.getBondedDevices();
      if (devices.isEmpty) return null;

      BluetoothDevice selected = macAddress != null
          ? devices.firstWhere((d) => d.address == macAddress,
          orElse: () => devices.first)
          : devices.firstWhere((d) => d.name?.contains("PT") ?? false,
          orElse: () => devices.first);

      await printer.connect(selected);
      await saveLastConnectedPrinter(selected.address ?? "");

      Fluttertoast.showToast(msg: "블루투스 프린터 연결됨: ${selected.name}");
      return selected;
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.connectToPrinter', e, stacktrace);
      return null;
    }
  }

  /// ✅ 페어링된 기기 목록에서 선택 연결
  Future<BluetoothDevice?> connectToPrinterWithSelection(BuildContext context) async {
    try {
      List<BluetoothDevice> devices = await printer.getBondedDevices();
      if (devices.isEmpty) {
        Fluttertoast.showToast(msg: "페어링된 블루투스 프린터가 없습니다.");
        return null;
      }

      BluetoothDevice? selectedDevice = await showDevicePicker(context, devices);
      if (selectedDevice == null) return null;

      bool alreadyConnected = await printer.isConnected ?? false;
      if (!alreadyConnected) {
        await printer.connect(selectedDevice);
      }

      Fluttertoast.showToast(msg: "연결됨: ${selectedDevice.name}");
      await saveLastConnectedPrinter(selectedDevice.address ?? "");
      return selectedDevice;
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.connectToPrinterWithSelection', e, stacktrace);
      return null;
    }
  }

  /// 기기 선택 다이얼로그
  Future<BluetoothDevice?> showDevicePicker(BuildContext context, List<BluetoothDevice> devices) async {
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('프린터 선택'),
          children: devices.map((device) {
            return SimpleDialogOption(
              child: Text('${device.name ?? "이름 없음"} (${device.address})'),
              onPressed: () {
                Navigator.pop(context, device);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// 텍스트 출력
  Future<void> printText(String text) async {
    try {
      await printer.printNewLine();
      await printer.printCustom(text, 0, 0);
      await printer.printNewLine();
      await printer.paperCut();

      Fluttertoast.showToast(msg: "프린트 완료");
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.printText', e, stacktrace);
    }
  }

  /// 이미지 출력 (긴 이미지는 조각으로 나눠서 순서대로 전송)
  Future<void> printImage(Uint8List imageBytes) async {
    try {
      if (imageBytes.isEmpty) return;

      final strips = await _splitIntoStrips(imageBytes);
      for (var i = 0; i < strips.length; i++) {
        await printer.printImageBytes(strips[i]);
        if (i < strips.length - 1) {
          await Future.delayed(_stripDelay); // 프린터 버퍼가 따라올 시간
        }
      }
      await printer.printNewLine();
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.printImage', e, stacktrace);
    }
  }

  /// PNG 이미지를 세로로 _maxStripHeight 픽셀씩 잘라 PNG 목록으로 반환
  Future<List<Uint8List>> _splitIntoStrips(Uint8List pngBytes) async {
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;
    final width = src.width;
    final height = src.height;

    // 짧은 이미지는 그대로 전송
    if (height <= _maxStripHeight) {
      src.dispose();
      codec.dispose();
      return [pngBytes];
    }

    final strips = <Uint8List>[];
    for (var top = 0; top < height; top += _maxStripHeight) {
      final stripHeight =
          (top + _maxStripHeight <= height) ? _maxStripHeight : height - top;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final area =
          ui.Rect.fromLTWH(0, 0, width.toDouble(), stripHeight.toDouble());

      // 흰 배경 위에 원본의 해당 구간만 그대로 복사
      canvas.drawRect(area, ui.Paint()..color = const ui.Color(0xFFFFFFFF));
      canvas.drawImageRect(
        src,
        ui.Rect.fromLTWH(0, top.toDouble(), width.toDouble(), stripHeight.toDouble()),
        area,
        ui.Paint(),
      );

      final picture = recorder.endRecording();
      final stripImage = await picture.toImage(width, stripHeight);
      final byteData =
          await stripImage.toByteData(format: ui.ImageByteFormat.png);
      stripImage.dispose();
      picture.dispose();

      if (byteData == null) {
        throw Exception('이미지 분할 실패 (top=$top)');
      }
      strips.add(byteData.buffer.asUint8List());
    }

    src.dispose();
    codec.dispose();
    return strips;
  }

  /// 연결 해제
  Future<void> disconnect() async {
    try {
      await printer.disconnect();
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.disconnect', e, stacktrace);
    }
  }

  /// 연결 상태 확인
  Future<bool> isConnected() async {
    try {
      return await printer.isConnected ?? false;
    } catch (e, stacktrace) {
      logError('BluetoothPrinterService.isConnected', e, stacktrace);
      return false;
    }
  }

  /// 마지막 연결된 프린터 MAC 주소 저장
  Future<void> saveLastConnectedPrinter(String macAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDeviceKey, macAddress);
    } catch (e, stacktrace) {
      logError('BluetoothPrinterService.saveLastConnectedPrinter', e, stacktrace);
    }
  }

  /// 마지막으로 저장된 프린터 MAC 주소 가져오기
  Future<String?> getLastConnectedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastDeviceKey);
    } catch (e, stacktrace) {
      logError('BluetoothPrinterService.getLastConnectedPrinter', e, stacktrace);
      return null;
    }
  }
}
