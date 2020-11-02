import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relojcin_binario/src/constantes.dart';
import 'package:relojcin_binario/src/models/RelojDevice.dart';
import 'package:relojcin_binario/src/service/RelojServices.dart';
import 'package:relojcin_binario/src/service/UpdService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  double _brightnessVal = 50;
  String _loadingMessage = "Buscando dispositivo...";

  final formKey = GlobalKey<FormState>();
  RelojDevice _device;

  @override
  void initState() {
    super.initState();
    _searchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            child: _showDeviceContent(),
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }

  _searchDevices() async {
    List<RelojDevice> devices = await UdpService.searchDevice();
    devices.forEach((element) {
      print("Device ${element.device} with IP: ${element.ipAdress}");
      if (element.device == Constants.DEVICE_NAME) {
        setState(() {
          _device = element;
          getDeviceData();
        });
      }
    });
  }

  _showDeviceContent() {
    if (_device == null || _loading == true) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(backgroundColor: Colors.white),
              SizedBox(height: 24.0),
              Text(_loadingMessage,
                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
            ]),
      );
    } else {
      return Column(
        children: <Widget>[
          Text("Dispositivo encontrado",
              style: TextStyle(color: Colors.white, fontSize: 20.0)),
          Text("${_device.ipAdress}",
              style: TextStyle(color: Colors.white, fontSize: 12.0)),
          _showDeviceCards(),
          _crearBotones(),
          _showBrightnessCard()
        ],
      );
    }
  }

  _showDeviceCards() {
    if (_device.data == null) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            child: Card(
              color: Colors.indigo,
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.perm_device_information, color: Colors.white,),
                              SizedBox(width: 8.0),
                              Text("Datos de dispositivo",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )),
                      _crearSsid(),
                      _crearPassword(),
                      _crearZonaHoraria(),
                      _crearSwitchAlarma(),
                      _crearDatosAlarma()
                    ],
                  ),
                ),
              ),
            ),
          ));
    }
  }

  _showBrightnessCard() {
    if (_device == null){
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Card(
          color: Colors.indigo,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.brightness_medium, color: Colors.white,),
                    SizedBox(width: 8.0),
                    Text("Brillo",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        value: _brightnessVal,
                        min: 0,
                        max: 100,
                        label: _brightnessVal.round().toString(),
                        onChanged: (double value){
                          setState(() {
                            _brightnessVal = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60.0,
                      height: 40.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        color: Colors.green,
                        onPressed: _onSetBrightness,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _crearSsid() {
    return TextFormField(
      initialValue: _device.ssid,
      decoration: InputDecoration(
          labelText: 'SSID',
          hintText: 'SSID',
          labelStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.wifi)),
      onSaved: (newSsid) => _device.ssid = newSsid,
      validator: (value) {
        if (value.isEmpty) {
          return 'Campo obligatorio';
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
    );
  }

  _crearPassword() {
    return TextFormField(
      initialValue: _device.pass,
      obscureText: true,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.white38),
          labelText: 'Password',
          hintText: 'Password',
          prefixIcon: Icon(Icons.lock)),
      onSaved: (newPass) => _device.pass = newPass,
      validator: (value) {
        if (value.isEmpty) {
          return 'Campo obligatorio';
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
    );
  }

  _crearZonaHoraria() {
    return TextFormField(
      initialValue: _device.hzone.toString(),
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.white38),
          labelText: 'Zona horaria',
          hintText: 'Zona horaria',
          prefixIcon: Icon(Icons.location_on)),
      onSaved: (newHzone) => _device.hzone = int.parse(newHzone),
      validator: (value) {
        if (value.isEmpty) {
          return 'Campo obligatorio';
        } else {
          if (num.tryParse(value) == null) {
            return 'Valor no válido';
          } else {
            return null;
          }
        }
      },
      style: TextStyle(color: Colors.white),
    );
  }

  _crearSwitchAlarma() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SwitchListTile(
          value: _device.alarm,
          secondary: const Icon(Icons.alarm),
          title: Text('Alarma', style: TextStyle(color: Colors.white)),
          onChanged: (val) {
            setState(() {
              _device.alarm = val;
            });
          }),
    );
  }

  _crearDatosAlarma() {
    if (_device.alarm == null || _device.alarm == false) {
      return Container();
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: TextFormField(
              initialValue: _device.alarmHour.toString(),
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white38),
                  labelText: 'Hora',
                  hintText: 'Hora',
                  prefixIcon: Icon(Icons.access_time)),
              onSaved: (newHour) => _device.alarmHour = int.parse(newHour),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Campo obligatorio';
                } else {
                  if (num.tryParse(value) == null) {
                    return 'Valor no válido';
                  } else {
                    return null;
                  }
                }
              },
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 24.0),
          Expanded(
            child: TextFormField(
              initialValue: _device.alarmMinute.toString(),
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white38),
                  labelText: 'Minuto',
                  hintText: 'Minuto'),
              onSaved: (newMinute) =>
                  _device.alarmMinute = int.parse(newMinute),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Campo obligatorio';
                } else {
                  if (num.tryParse(value) == null) {
                    return 'Valor no válido';
                  } else {
                    return null;
                  }
                }
              },
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      );
    }
  }

  _crearBotones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              color: Colors.green,
              onPressed: () {
                _onSyncHour();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('SYNC', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              color: Colors.black,
              onPressed: _onSaveData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('GUARDAR', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  getDeviceData() async {
    final relojServices = RelojServices();
    relojServices.setAddress(_device.ipAdress, 2000);
    relojServices.getData((data) {
      print("Data response = $data");
      setState(() {
        final deviceData = json.decode(data)["message"];
        _device.data = json.decode(deviceData);
        _device.setData(_device.data);
        _loading = false;
      });
    });
  }

  _onSyncHour() async {
    setState(() {
      _loading = true;
      _loadingMessage = "Sincronizando hora";
    });

    final RelojServices relojServices = RelojServices();
    await relojServices.syncHour(() {
      setState(() {
        _loading = false;
      });
    });
  }

  _onSetBrightness() async {
    final RelojServices relojServices = RelojServices();
    await relojServices.setBrightness(_brightnessVal.round(), () {
      setState(() {
        print("Brillo modificado!");
      });
    });
  }

  _onSaveData() async {
    // Validar campos
    if (!formKey.currentState.validate()) {
      return;
    }

    // Guardar cambios
    formKey.currentState.save();

    setState(() {
      _loadingMessage = "Actualizando datos";
      _loading = true;
    });

    final RelojServices relojServices = RelojServices();
    await relojServices.setData(_device, () {
      getDeviceData();
      setState(() {
        _loadingMessage = "Obteniendo datos";
      });
    });
  }
}
