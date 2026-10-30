import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/domain/models/rainpoint.dart';

// Payloads reported by real devices, from the test corpus of the Home
// Assistant integration github.com/brettmeyerowitz/homeassistant-homgar
void main() {
  test('decodes a soil sensor frame', () {
    RainPointReading r = decodeRainPoint(
        'HCS021FRF', '10#E1B300DC01859602881CC6C91800FF0F628B1619')!;
    expect(r.rssi, -77);
    expect(r.battery, 100);
    expect(r.temperature, 19.0);
    expect(r.soilMoisture, 28);
    expect(r.illuminance, 634);
    expect(r.watering, isNull);
  });

  test('decodes the time of an event', () {
    RainPointReading r = decodeRainPoint(
        'HCS044FRF', '10#DC01E1C40011B737B51A1920FF0FDA251C19')!;
    expect(r.eventTime, DateTime.utc(2026, 4, 13, 11, 20, 55));
  });

  test('decodes a water timer frame', () {
    RainPointReading idle = decodeRainPoint('HTV113FRF',
        '10#E1AD00DC01D80020B700000000AD00009F00000000FF0F4D371719')!;
    expect(idle.watering, isFalse);
    expect(idle.lastWaterLiters, 0);
    expect(idle.durationSeconds, 0);
    expect(idle.soilMoisture, isNull);
    RainPointReading timed = decodeRainPoint('HTV113FRF',
        '10#E1AE00DC01D82020B700000000AD58029F00000000FF0F47371719')!;
    expect(timed.durationSeconds, 600);
  });

  test('decodes the comma separated format of older devices', () {
    RainPointReading soil =
        decodeRainPoint('HCS021FRF', '1,-62,1;766,52,G=31351')!;
    expect(soil.rssi, -62);
    expect(soil.temperature, 24.8);
    expect(soil.soilMoisture, 52);
    expect(soil.illuminance, closeTo(3135.1, 0.01));

    RainPointReading valve = decodeRainPoint(
        'HTV213FRF', '1,-75,1;33,15,0,1775856207,600,0|0,14,0,0,0,0')!;
    expect(valve.watering, isTrue);
    expect(valve.lastWaterLiters, 1.5);
    expect(valve.durationSeconds, 600);
    expect(valve.eventTime,
        DateTime.fromMillisecondsSinceEpoch(1775856207000, isUtc: true));
  });

  test('ignores what it cannot read', () {
    expect(decodeRainPoint('HCS026FRF', ''), isNull);
    expect(decodeRainPoint('HCS026FRF', '10#ZZ'), isNull);
    expect(RainPointDevice.kindOfModel('HTV145FRF'), RainPointKind.valve);
    expect(RainPointDevice.kindOfModel('HWG023WBRF'), RainPointKind.hub);
  });
}
