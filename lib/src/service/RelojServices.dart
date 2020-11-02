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

  setBrightness(int percentage, onResponse) async {
    final socket = await Socket.connect(_ip, _port);
    socket.listen((data) {
      onResponse();
    }, onDone: (){
      socket.destroy();
    });

    // Convertir porcentaje a rango de 10 bits (0 - 1023)
    //100           -  1023
    //porcentaje    -  x
    int newVal = 1023 - ((percentage * 1023) / 100).round();

    // Build request
    final req = {"key": "set_pwm", "value": newVal};
    print("Sending request $req");
    socket.write(req);
  }
}
