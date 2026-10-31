import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/sensors/sensor_phone_service.dart';
import 'package:plant_it/data/service/sensors/sensor_station.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/light.dart';

void main() {
  test('lightIntegral joins samples and skips gaps', () {
    DateTime t = DateTime(2026, 10, 31, 12);
    // 10 000 lux for one hour: 10000 × 0.0185 × 3600 / 1e6
    double hour = lightIntegral([
      LightSample(t, 10000),
      LightSample(t.add(const Duration(minutes: 30)), 10000),
      LightSample(t.add(const Duration(minutes: 60)), 10000),
    ]);
    expect(hour, closeTo(0.666, 0.001));
    // Readings two hours apart are not joined
    expect(
        lightIntegral([
          LightSample(t, 10000),
          LightSample(t.add(const Duration(hours: 2)), 10000),
        ]),
        0);
    Map<DateTime, double> daily = dailyLightIntegrals([
      LightSample(t, 1000),
      LightSample(t.add(const Duration(minutes: 5)), 1000),
    ]);
    expect(daily.keys.single, DateTime(2026, 10, 31));
  });

  test('estimatedDli joins the hours measured on different days', () {
    expect(estimatedDli([]), isNull);
    // 10 000 lux measured at noon on one day and at 13:00 on another
    double dli = estimatedDli([
      LightSample(DateTime(2026, 10, 30, 12, 10), 10000),
      LightSample(DateTime(2026, 10, 31, 13, 40), 10000),
    ])!;
    // A ramp from 5:00 to 12:00, two hours at 10 000, a ramp to 21:00:
    // 7 hours x 5 000 avg-ish + 2 x 10 000 + 8 x 5 000, about 6.5 mol
    expect(dli, greaterThan(5));
    expect(dli, lessThan(8));
    expect(
        hoursCovered([
          LightSample(DateTime(2026, 10, 30, 12, 10), 1),
          LightSample(DateTime(2026, 10, 31, 12, 40), 1),
          LightSample(DateTime(2026, 10, 31, 15), 1),
        ]),
        2);
  });

  test('dliRange comes from the lux of the care or the light level', () {
    expect(dliRange(light: 9), (22.0, 40.0));
    expect(dliRange(light: 4), (4.0, 8.0));
    (double, double) range = dliRange(luxMin: 10000, luxMax: 20000, light: 2)!;
    expect(range.$1, closeTo(7.99, 0.01));
    expect(range.$2, closeTo(15.98, 0.01));
    expect(dliRange(), isNull);
    expect(compassPoint(0), CompassPoint.n);
    expect(compassPoint(181), CompassPoint.s);
    expect(compassPoint(350), CompassPoint.n);
    expect(compassPoint(100), CompassPoint.e);
  });

  test('a paired phone brings the readings of the sensor phone', () async {
    // The sensor phone
    AppDatabase sensor = AppDatabase.forTesting(NativeDatabase.memory());
    DateTime now = DateTime.now();
    for (int i = 0; i < 4; i++) {
      await sensor.into(sensor.sensorReadings).insert(
          SensorReadingsCompanion.insert(
              device: 'pixel',
              time: now.subtract(Duration(minutes: 5 * (3 - i))),
              lux: Value(2000.0 + i),
              pressure: const Value(1012.5),
              temperature: const Value(24.0)));
    }
    // Answers over a real socket, as on the local network
    ServerSocket server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4, SensorProtocol.port,
        shared: true);
    server.listen((socket) {
      utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .first
          .then((line) async {
        socket.write('${json.encode(await SensorProtocol.answer(
          json.decode(line),
          db: sensor,
          device: 'pixel',
          name: 'Pixel 6a',
          code: '123456',
          azimuth: 180,
        ))}\n');
        await socket.flush();
        socket.destroy();
      });
    });

    AppDatabase main = AppDatabase.forTesting(NativeDatabase.memory());
    SensorPhoneService service = SensorPhoneService(
      db: main,
      userSettingRepository: UserSettingRepository(db: main),
      collectionRepository: CollectionRepository(db: main),
      eventRepository: EventRepository(db: main),
      eventTypeRepository: EventTypeRepository(db: main),
    );
    expect((await service.add('127.0.0.1', '000000')).isError(), isTrue);
    SensorPhone phone =
        (await service.add('127.0.0.1', '123456')).getOrThrow();
    expect(phone.name, 'Pixel 6a');
    expect(phone.azimuth, 180);
    expect(await main.select(main.sensorReadings).get(), hasLength(4));

    // A new reading arrives with the next sync, without duplicates
    await sensor.into(sensor.sensorReadings).insert(
        SensorReadingsCompanion.insert(
            device: 'pixel',
            time: now.add(const Duration(minutes: 1)),
            lux: const Value(2100)));
    expect(await service.sync(), 1);
    expect(await main.select(main.sensorReadings).get(), hasLength(5));

    // Linked through a group of plants
    int species = await main.into(main.species).insert(
        SpeciesCompanion.insert(scientificName: 'Ficus', species: 'Ficus'));
    int plant = await main
        .into(main.plants)
        .insert(PlantsCompanion.insert(name: 'Ficus', species: species));
    CollectionRepository groups = CollectionRepository(db: main);
    int living = (await groups.insert('Salón')).getOrThrow();
    await groups.setPlantsOfCollection(living, {plant});
    await service.setLinks(phone.id, {-living});
    LightSummary summary = (await service.summaryOf(plant))!;
    expect(summary.last!.lux, 2100);
    expect(summary.lastDay, hasLength(5));
    expect(summary.todayDli, greaterThan(0));

    await server.close();
    await sensor.close();
    await main.close();
  });

  test('records a light event per complete day and keeps hand readings',
      () async {
    AppDatabase main = AppDatabase.forTesting(NativeDatabase.memory());
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1, 7);
    // A day of readings every five minutes, from 7:00
    List<List<Object?>> readings = [
      for (int i = 0; i < 120; i++)
        [
          yesterday.add(Duration(minutes: 5 * i)).millisecondsSinceEpoch,
          3000.0,
          null,
          null
        ]
    ];
    SensorPhoneService service = SensorPhoneService(
      db: main,
      userSettingRepository: UserSettingRepository(db: main),
      collectionRepository: CollectionRepository(db: main),
      eventRepository: EventRepository(db: main),
      eventTypeRepository: EventTypeRepository(db: main),
      ask: (address, code, {since}) async => {
        'ok': true,
        'device': 'pixel',
        'name': 'Pixel 6a',
        'readings': readings,
      },
    );
    int species = await main.into(main.species).insert(
        SpeciesCompanion.insert(scientificName: 'Ficus', species: 'Ficus'));
    int plant = await main
        .into(main.plants)
        .insert(PlantsCompanion.insert(name: 'Ficus', species: species));
    SensorPhone phone = (await service.add('10.0.0.2', '1')).getOrThrow();
    await service.setLinks(phone.id, {plant});

    expect(await service.recordLightEvents('Luz'), 1);
    expect(await service.recordLightEvents('Luz'), 0);
    Event event = (await main.select(main.events).get()).single;
    EventType type = (await main.select(main.eventTypes).get())
        .firstWhere((t) => t.id == event.type);
    expect(type.name, 'Luz');
    // 3000 lux for ten hours: 3000 x 0.0185 x 36 000 / 1e6
    expect(event.note, startsWith('2.0 mol'));

    // Readings by hand next to its group count for the plant
    CollectionRepository groups = CollectionRepository(db: main);
    int shelf = (await groups.insert('Estante')).getOrThrow();
    await groups.setPlantsOfCollection(shelf, {plant});
    await service.saveSpot(1500, groupId: shelf);
    await service.saveSpot(2500, plantId: plant);
    expect((await service.spotSamplesOf(plant)).map((s) => s.lux).toSet(),
        {1500.0, 2500.0});
    await main.close();
  });
}
