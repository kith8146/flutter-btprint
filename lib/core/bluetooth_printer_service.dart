import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/error_utils.dart';

class BluetoothPrinterService {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  static const _lastDeviceKey = 'last_connected_printer';

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

  /// 이미지 출력
  Future<void> printImage(Uint8List imageBytes) async {
    try {
      await printer.printImageBytes(imageBytes);
      await printer.printNewLine();
    } catch (e, stacktrace) {
      handleBluetoothError(e, stacktrace);
      logError('BluetoothPrinterService.printImage', e, stacktrace);
    }
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
