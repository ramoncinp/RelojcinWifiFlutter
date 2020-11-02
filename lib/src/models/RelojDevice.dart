class RelojDevice {
  String _ipAdress;
  String _device;
  String name;

  String ssid;
  String pass;
  bool alarm;
  int hzone;
  int alarmHour;
  int alarmMinute;

  Map<String, dynamic> data;

  RelojDevice(this._ipAdress, this._device, {this.name});

  String get ipAdress {
    return _ipAdress;
  }

  String get device {
    return _device;
  }

  setData(data) {
    ssid = data['ssid'];
    pass = data['pass'];
    hzone = data['hzone'];
    alarm = data['alarm'];
    alarmHour = data['alarm_hour'];
    alarmMinute = data['alarm_minute'];
  }

  dataToMap() {
    return {
      "ssid": ssid,
      "pass": pass,
      "hzone": hzone,
      "alarm": alarm,
      "alarm_hour": alarmHour,
      "alarm_minute": alarmMinute
    };
  }
}
