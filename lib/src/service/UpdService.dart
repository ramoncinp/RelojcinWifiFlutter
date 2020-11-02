import 'dart:convert';
import 'dart:io';

import 'package:relojcin_binario/src/constantes.dart';
import 'package:relojcin_binario/src/models/RelojDevice.dart';

class UdpService {
  static searchDevice() async {
    final _DESTINATION = InternetAddress("255.255.255.255");
    final List<RelojDevice> devices = List();

    final RawDatagramSocket udpSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 2400);
    udpSocket.broadcastEnabled = true;
    udpSocket.listen((RawSocketEvent e) {
      RelojDevice device;

      Datagram datagram = udpSocket.receive();
      if (datagram != null) {
        print("Datagram IP ${datagram.address.address}");

        String dataString = String.fromCharCodes(datagram.data);
        print("Data String $dataString");
        final dataMap = json.decode(dataString);
        print("Data Map $dataMap");

        device = RelojDevice(datagram.address.address, dataMap['device']);
      }

      devices.add(device);
      print("device added!");

      if (device.device == Constants.DEVICE_NAME) {
        print('Destroying updSocket');
        udpSocket.close();
      }
    });

    List<int> data = utf8.encode('Everything is Copacetic');
    udpSocket.send(data, _DESTINATION, 2400);

    print("delay!");
    await Future.delayed(Duration(seconds: 5));
    print("delay completed!");

    return devices;
  }
}
