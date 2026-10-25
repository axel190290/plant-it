import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/open_plantbook_client.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';

void main() {
  group('OpenPlantbookClient.toCare', () {
    test('converts lux, humidity and temperature to the app scales', () {
      SpeciesCareCompanion care = OpenPlantbookClient.toCare({
        'min_light_lux': 2500,
        'max_light_lux': 60000,
        'min_env_humid': 30,
        'max_env_humid': 80,
        'min_temp': 12,
        'max_temp': 35,
      });
      // sqrt(2500 * 60000) ~ 12247 lux
      expect(care.light.value, 6);
      expect(care.humidity.value, 6);
      expect(care.tempMin.value, 12);
      expect(care.tempMax.value, 35);
      expect(care.phMin.value, isNull);
      expect(care.phMax.value, isNull);
    });

    test('clamps extreme values and keeps missing ones empty', () {
      SpeciesCareCompanion care = OpenPlantbookClient.toCare({
        'min_light_lux': 200000,
        'min_temp': -45,
      });
      expect(care.light.value, 10);
      expect(care.humidity.value, isNull);
      expect(care.tempMin.value, -30);
      expect(care.tempMax.value, isNull);
    });
  });

  group('AiCareEstimator.parseCare', () {
    test('reads JSON wrapped in a code fence and clamps it', () {
      SpeciesCareCompanion care = AiCareEstimator.parseCare('''```json
{"light": 12, "humidity": 6, "tempMin": "15", "tempMax": 30,
 "phMin": 5.6, "phMax": null}
```''').getOrThrow();
      expect(care.light.value, 10);
      expect(care.humidity.value, 6);
      expect(care.tempMin.value, 15);
      expect(care.tempMax.value, 30);
      expect(care.phMin.value, 6);
      expect(care.phMax.value, isNull);
    });

    test('fails on an answer without JSON', () {
      expect(AiCareEstimator.parseCare('I do not know').isError(), isTrue);
    });
  });

  group('CareSources', () {
    test('round-trips through the bibliography', () {
      CareSources sources = CareSources(
        species: 'gbif',
        care: CareSources.openPlantbook,
        aiProvider: AiProvider.gemini.key,
        aiFields: CareSources.groupFields(['phMin', 'phMax', 'light']),
      );
      String encoded = sources.encode();
      expect(encoded,
          'plantit-sources:species=gbif;care=openplantbook;ai=gemini:light,ph');
      expect(encoded.length, lessThanOrEqualTo(200));

      CareSources decoded = CareSources.decode(encoded)!;
      expect(decoded.species, 'gbif');
      expect(decoded.care, CareSources.openPlantbook);
      expect(decoded.aiProvider, 'gemini');
      expect(decoded.aiFields, ['light', 'ph']);
      expect(decoded.hasAiEstimate, isTrue);
    });

    test('ignores bibliographies written by the user', () {
      expect(CareSources.decode('Some book, 1990'), isNull);
      expect(CareSources.decode(null), isNull);
    });
  });
}
