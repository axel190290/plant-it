import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_client.dart';
import 'package:plant_it/data/service/sensors/rainpoint_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/rainpoint.dart';

void main() {
  late AppDatabase db;
  late int logins;
  // The water timer reports this payload: last watering 1.5 l, ended then
  late String valveStatus;

  RainPointService service() {
    MockClient cloud = MockClient((request) async {
      Map<String, dynamic> body(Object? data) => {'code': 0, 'data': data};
      String path = request.url.path;
      Object? data;
      if (path == '/auth/basic/app/login') {
        logins++;
        Map<String, dynamic> sent = json.decode(request.body);
        expect(sent['password'], hasLength(32));
        data = {'token': 'T', 'tokenExpired': 86400};
      } else {
        expect(request.headers['auth'], 'T');
        data = switch (path) {
          '/app/member/appHome/list' => [
              {'hid': 7, 'homeName': 'Mi casa'}
            ],
          '/app/device/getDeviceByHid' => [
              {
                'mid': 42,
                'model': 'HWG023WBRF',
                'subDevices': [
                  {'addr': 1, 'model': 'HWG023WBRF', 'name': 'Hub'},
                  {'addr': 2, 'model': 'HCS026FRF', 'name': 'Sensor'},
                  {'addr': 3, 'model': 'HTV145FRF', 'name': 'Grifo'},
                ]
              }
            ],
          '/app/device/getDeviceStatus' => {
              'subDeviceStatus': [
                {'id': 'D02', 'value': '1,-62,1;766,52,G=31351'},
                {'id': 'D03', 'value': valveStatus},
              ]
            },
          _ => null,
        };
      }
      return http.Response(json.encode(body(data)), 200);
    });
    return RainPointService(
      client: RainPointClient(httpClient: cloud),
      userSettingRepository: UserSettingRepository(db: db),
      eventRepository: EventRepository(db: db),
      eventTypeRepository: EventTypeRepository(db: db),
      collectionRepository: CollectionRepository(db: db),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    logins = 0;
    valveStatus = '1,-70,1;0,15,0,1775856207,600,0';
  });

  tearDown(() => db.close());

  test('connects, lists the devices and keeps the token', () async {
    RainPointService rainPoint = service();
    List<RainPointDevice> devices = (await rainPoint.connect(
      email: 'me@example.com',
      password: 'secret',
      areaCode: '52',
      appCode: RainPointClient.rainPointApp,
    ))
        .getOrThrow();
    expect(devices.map((d) => d.key), ['42_2', '42_3']);
    expect(devices.first.reading!.soilMoisture, 52);
    expect(devices.last.kind, RainPointKind.valve);

    // A new service reuses the saved token instead of logging in again
    await service().devices(refresh: true);
    expect(logins, 1);
  });

  test('records the new waterings of the linked water timers', () async {
    RainPointService rainPoint = service();
    await rainPoint.connect(
        email: 'me@example.com',
        password: 'secret',
        areaCode: '52',
        appCode: RainPointClient.rainPointApp);
    int species = await db.into(db.species).insert(
        SpeciesCompanion.insert(scientificName: 'Rosa', species: 'Rosa'));
    int plant = await db
        .into(db.plants)
        .insert(PlantsCompanion.insert(name: 'Rosal', species: species));
    // Linked through a group of plants
    CollectionRepository groups = CollectionRepository(db: db);
    int balcony = (await groups.insert('Balcón')).getOrThrow();
    await groups.setPlantsOfCollection(balcony, {plant});
    await rainPoint.setLinks('42_3', {-balcony});
    expect(await rainPoint.linkedPlants(), {
      '42_3': {plant}
    });
    expect((await rainPoint.devicesOf(plant)).single.name, 'Grifo');

    // The first check only remembers the last watering
    expect(await rainPoint.recordWaterings(), 0);
    valveStatus = '1,-70,1;0,25,0,1775900000,600,0';
    await rainPoint.devices(refresh: true);
    expect(await rainPoint.recordWaterings(), 1);
    expect(await rainPoint.recordWaterings(), 0);
    List<Event> events = await db.select(db.events).get();
    expect(events.single.plant, plant);
    expect(events.single.note, contains('2.5 l'));
    expect(events.single.note, contains('10 min'));

    // A misting is seen while it runs, and recorded as one when it ends
    valveStatus = '1,-70,1;34,3,0,1775990000,120,0';
    await rainPoint.devices(refresh: true);
    expect(await rainPoint.recordWaterings(), 0);
    valveStatus = '1,-70,1;0,3,0,1775990000,120,0';
    await rainPoint.devices(refresh: true);
    expect(await rainPoint.recordWaterings(), 1);
    EventType misting = (await db.select(db.eventTypes).get())
        .firstWhere((t) => t.name == 'misting');
    expect((await db.select(db.events).get()).last.type, misting.id);
  });
}
