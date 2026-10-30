/// RainPoint / HomGar smart garden devices and the values they report.
///
/// The cloud has no public API: its format was worked out by the community.
/// Decoding follows the MIT-licensed Home Assistant integration
/// github.com/brettmeyerowitz/homeassistant-homgar and the homgarapi library.
library;

enum RainPointKind { soilSensor, valve, hub, other }

/// A device of a RainPoint hub: a sensor or a water timer.
class RainPointDevice {
  // Identifies the device: the hub mid and its address
  final String key;
  final String model;
  final String name;
  final RainPointReading? reading;

  const RainPointDevice({
    required this.key,
    required this.model,
    required this.name,
    this.reading,
  });

  RainPointKind get kind => kindOfModel(model);

  static RainPointKind kindOfModel(String model) {
    String m = model.toUpperCase();
    if (m.startsWith('HCS')) return RainPointKind.soilSensor;
    if (m.startsWith('HTV') || m.startsWith('HTP')) return RainPointKind.valve;
    if (m.startsWith('HWG') || m.startsWith('HWS')) return RainPointKind.hub;
    return RainPointKind.other;
  }
}

/// What a device reported. Every value may be missing.
class RainPointReading {
  final double? soilMoisture;
  final double? temperature;
  final double? illuminance;
  final int? battery;
  final int? rssi;
  final bool? watering;
  // Liters of the last (or current) watering session
  final double? lastWaterLiters;
  final int? durationSeconds;
  // When the last event of the device happened, such as a watering
  final DateTime? eventTime;

  const RainPointReading({
    this.soilMoisture,
    this.temperature,
    this.illuminance,
    this.battery,
    this.rssi,
    this.watering,
    this.lastWaterLiters,
    this.durationSeconds,
    this.eventTime,
  });

  bool get isEmpty =>
      soilMoisture == null &&
      temperature == null &&
      illuminance == null &&
      watering == null &&
      lastWaterLiters == null;
}

// Value types of the type-length-value frames
const int _tem = 9;
const int _rh = 10;
const int _lastUsage = 15;
const int _duration = 19;
const int _eventTime = 21;
const int _illuminance = 25;
const int _workState = 30;
const int _battery = 31;
const int _rssi = 32;

class _Entry {
  final int typeCode;
  final int length;
  // The header byte, then the value bytes
  final List<int> bytes;

  const _Entry(this.typeCode, this.length, this.bytes);

  /// The value as a little-endian unsigned integer.
  int get unsigned {
    int v = 0;
    for (int i = length; i >= 1; i--) {
      if (i < bytes.length) v = (v << 8) | bytes[i];
    }
    return v;
  }
}

/// Decodes the status a device reports, in either of its two formats: the
/// type-length-value frames of newer devices ("10#E1B300...") and the
/// comma-separated values of older ones ("1,-62,1;766,52,G=31351").
RainPointReading? decodeRainPoint(String model, String status) {
  String s = status.trim();
  if (s.isEmpty) return null;
  try {
    bool tlv = s.length >= 3 &&
        _isDigit(s.codeUnitAt(0)) &&
        _isDigit(s.codeUnitAt(1)) &&
        s[2] == '#';
    return tlv
        ? _decodeTlv(model, s)
        : _decodeLegacy(RainPointDevice.kindOfModel(model), s);
  } catch (_) {
    return null;
  }
}

bool _isDigit(int c) => c >= 48 && c <= 57;

List<_Entry> _parseTlv(List<int> data, bool withDpIds) {
  List<_Entry> entries = [];
  int i = 0;
  while (i < data.length) {
    if (withDpIds) i++;
    if (i >= data.length) break;
    int h = data[i];
    if ((h >> 7) & 1 == 0) {
      entries.add(_Entry((h >> 4) & 7, 1, [h]));
      i++;
      continue;
    }
    int code = (h >> 2) & 31;
    int length = (h & 3) + 1;
    int copy = length + 1;
    if (code <= 30) {
      entries.add(_Entry(code + 8, length,
          data.sublist(i, i + copy > data.length ? data.length : i + copy)));
      i += copy;
    } else {
      i++;
      if (i >= data.length) break;
      int extended = data[i] + 39;
      entries.add(_Entry(extended, length,
          data.sublist(i, i + copy > data.length ? data.length : i + copy)));
      i += copy;
    }
  }
  return entries;
}

RainPointReading _decodeTlv(String model, String s) {
  bool withDpIds = s[1] == '1';
  String hex = s.substring(3);
  int comma = hex.indexOf(',');
  if (comma >= 0) hex = hex.substring(0, comma);
  List<int> data = [
    for (int i = 0; i + 1 < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16)
  ];
  List<_Entry> entries = _parseTlv(data, withDpIds);
  _Entry? find(int code) =>
      entries.where((e) => e.typeCode == code).firstOrNull;

  int? rssi;
  _Entry? r = find(_rssi);
  if (r != null && r.bytes.length >= 2) {
    int raw = r.bytes[1];
    int value = raw > 127 ? raw - 256 : raw;
    rssi = value < 0 ? value : null;
  }

  int? battery;
  _Entry? b = find(_battery);
  if (b != null && b.bytes.length >= 2) {
    battery = b.bytes[1] <= 1 ? 100 : 10;
  }

  double? temperature;
  _Entry? t = find(_tem);
  if (t != null && t.bytes.length >= 3) {
    int raw = t.bytes[1] | (t.bytes[2] << 8);
    if (raw > 32767) raw -= 65536;
    if (raw != 32767 && raw != -32768 && raw != 50000) {
      temperature = _fahrenheitTenthsToCelsius(raw);
    }
  }

  double? moisture;
  _Entry? h = find(_rh);
  if (h != null && h.bytes.length >= 2 && h.bytes[1] != 255) {
    moisture = h.bytes[1].toDouble();
  }

  double? illuminance;
  _Entry? light = find(_illuminance);
  if (light != null) {
    int raw = light.unsigned;
    if (raw != 16777215) illuminance = (raw ~/ 10).toDouble();
  }

  bool? watering;
  _Entry? w = find(_workState);
  if (w != null && w.bytes.length >= 2) {
    watering = (w.bytes[1] & 0x0F) != 0;
  }

  int? duration = find(_duration)?.unsigned;
  _Entry? usage = find(_lastUsage);
  double? liters = usage == null ? null : usage.unsigned / 10;

  DateTime? eventTime;
  _Entry? e = find(_eventTime);
  if (e != null && e.bytes.length >= 5) {
    eventTime = _packedTime(e.bytes.sublist(1, 5));
  }

  bool isSoil = RainPointDevice.kindOfModel(model) == RainPointKind.soilSensor;
  return RainPointReading(
    soilMoisture: isSoil ? moisture : null,
    temperature: temperature,
    illuminance: illuminance,
    battery: battery,
    rssi: rssi,
    watering: watering,
    lastWaterLiters: liters,
    durationSeconds: duration,
    eventTime: eventTime,
  );
}

double _fahrenheitTenthsToCelsius(int raw) =>
    ((raw / 10 - 32) * 5 / 9 * 10).round() / 10;

/// A date packed in 32 bits: seconds, minutes, hours, day, month and years
/// since 2020, in UTC.
DateTime? _packedTime(List<int> bytes) {
  int raw = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24);
  int second = raw & 0x3F;
  int minute = (raw >> 6) & 0x3F;
  int hour = (raw >> 12) & 0x1F;
  int day = (raw >> 17) & 0x1F;
  int month = (raw >> 22) & 0x0F;
  int year = ((raw >> 26) & 0x3F) + 2020;
  if (month < 1 ||
      month > 12 ||
      day < 1 ||
      hour > 23 ||
      minute > 59 ||
      second > 59) {
    return null;
  }
  return DateTime.utc(year, month, day, hour, minute, second);
}

RainPointReading? _decodeLegacy(RainPointKind kind, String s) {
  List<String> parts = s.split(';');
  List<String> header = parts.first.split(',');
  String body = parts.length > 1 ? parts[1] : '';
  int? rssi = header.length > 1 ? int.tryParse(header[1].trim()) : null;
  if (rssi != null && rssi >= 0) rssi = null;

  if (kind == RainPointKind.valve) {
    // state, volume (0.1 l), reserved, end time, duration (s), reserved;
    // one section per zone, separated by "|"
    List<String> fields = body.split('|').first.split(',');
    int? field(int i) {
      if (i >= fields.length) return null;
      String v = fields[i].trim();
      int paren = v.indexOf('(');
      return int.tryParse(paren >= 0 ? v.substring(0, paren) : v);
    }

    int? state = field(0);
    bool? watering = state == null ? null : (state & 0x0F) != 0;
    int? volume = field(1);
    int? end = field(3);
    return RainPointReading(
      rssi: rssi,
      watering: watering,
      lastWaterLiters: volume == null ? null : volume / 10,
      durationSeconds: field(4),
      eventTime: end != null && end > 1000000000
          ? DateTime.fromMillisecondsSinceEpoch(end * 1000, isUtc: true)
          : null,
    );
  }

  // temperature (0.1 °F), moisture or humidity (%), G=light (0.1 lux)
  List<String> fields = body.split(',');
  int? number(int i) {
    if (i >= fields.length) return null;
    String v = fields[i].trim();
    int paren = v.indexOf('(');
    return int.tryParse(paren >= 0 ? v.substring(0, paren) : v);
  }

  int? temperature = number(0);
  int? moisture = number(1);
  String? light =
      fields.map((f) => f.trim()).where((f) => f.startsWith('G=')).firstOrNull;
  int? lux = light == null ? null : int.tryParse(light.substring(2));
  return RainPointReading(
    temperature: temperature == null ||
            temperature == 32767 ||
            temperature == 32766 ||
            temperature == 50000
        ? null
        : _fahrenheitTenthsToCelsius(temperature),
    soilMoisture:
        kind == RainPointKind.soilSensor && moisture != null && moisture != 255
            ? moisture.toDouble()
            : null,
    illuminance: lux == null || lux == 16777215 ? null : lux / 10,
    rssi: rssi,
  );
}
