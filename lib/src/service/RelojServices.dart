import 'dart:io';

import 'package:relojcin_binario/src/models/RelojDevice.dart';

class RelojServices {
  static final RelojServices _relojServices = RelojServices._internal();
  String _ip;
  int _port;

  factory RelojServices() {
    return _relojServices;
  }

  RelojServices._internal();

  setAddress(ipAddress, port) {
    _ip = ipAddress;
    _port = port;
  }

  getData(onResponse) async {
    final socket = await Socket.connect(_ip, _port);
    socket.listen((data) {
      onResponse(String.fromCharCodes(data).trim());
    }, onDone: () {
      socket.destroy();
    });

    // Build request
    final req = {"key": "get_data"};
    socket.write(req);
  }

  setData(RelojDevice device, onResponse) async {
    final socket = await Socket.connect(_ip, _port);
    socket.listen((data) {
      onResponse();
    }, onDone: () {
      socket.destroy();
    });

    // Build request
    final req = {"key": "set_data", "data": device.dataToMap()};
    socket.write(req);
  }

  syncHour(onResponse) async {
    DateTime now = DateTime.now();
    int currentHour = now.hour;

    final socket = await Socket.connect(_ip, _port);
    socket.listen((data) {
      onResponse();
    }, onDone: () {
      socket.destroy();
    });

    // Build request
    final req = {"key": "sync_hour", "hour": currentHour};
    socket.write(req);
  }
}
