import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/image_repository.dart';
import 'package:plant_it/data/repository/notifications_lang_repository.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/reminder_occurrence_repository.dart';
import 'package:plant_it/data/repository/reminder_repository.dart';
import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/repository/species_repository.dart';
import 'package:plant_it/data/repository/species_synonym_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/notification_service.dart';
import 'package:plant_it/data/service/scheduling_service.dart';
import 'package:plant_it/data/service/reminder_occurrence_service.dart';
import 'package:plant_it/data/service/backup/backup_service.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/open_plantbook_client.dart';
import 'package:plant_it/data/service/care/reminder_suggestion_service.dart';
import 'package:plant_it/data/service/care/species_care_enricher.dart';
import 'package:plant_it/data/service/care/suggestion_care_filler.dart';
import 'package:plant_it/data/service/care/species_description_service.dart';
import 'package:plant_it/data/service/identify/plantnet_identifier.dart';
import 'package:plant_it/data/service/sensors/rainpoint_client.dart';
import 'package:plant_it/data/service/sensors/sensor_phone_service.dart';
import 'package:plant_it/data/service/sensors/sensor_station.dart';
import 'package:plant_it/data/service/sensors/rainpoint_service.dart';
import 'package:plant_it/data/service/search/flora_codex_searcher.dart';
import 'package:plant_it/data/service/search/gbif_searcher.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/data/service/search/local_searcher.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/config/dependencies.dart';

// Every service is created the way the app creates it: a provider that
// reads one declared after it fails when the app opens, with a grey screen.
void main() {
  testWidgets('every provider finds the ones it reads', (tester) async {
    Map<Type, Object Function()> created = {};
    // Real timers: the database starts opening with one
    await tester.runAsync(() => tester.pumpWidget(MultiProvider(
          providers: providersLocal,
          child: Builder(builder: (context) {
            created = {
              AiCareEstimator: () => context.read<AiCareEstimator>(),
              BackupService: () => context.read<BackupService>(),
              CareFieldRepository: () => context.read<CareFieldRepository>(),
              CollectionRepository: () => context.read<CollectionRepository>(),
              EventRepository: () => context.read<EventRepository>(),
              EventTypeRepository: () => context.read<EventTypeRepository>(),
              FloraCodexSearcher: () => context.read<FloraCodexSearcher>(),
              GbifSearcher: () => context.read<GbifSearcher>(),
              ImageRepository: () => context.read<ImageRepository>(),
              LocalSearcher: () => context.read<LocalSearcher>(),
              NotificationService: () => context.read<NotificationService>(),
              NotificationsLangRepository: () =>
                  context.read<NotificationsLangRepository>(),
              OpenPlantbookClient: () => context.read<OpenPlantbookClient>(),
              PlantNetIdentifier: () => context.read<PlantNetIdentifier>(),
              PlantRepository: () => context.read<PlantRepository>(),
              RainPointService: () => context.read<RainPointService>(),
              ReminderOccurrenceService: () =>
                  context.read<ReminderOccurrenceService>(),
              ReminderOccurrenceRepository: () =>
                  context.read<ReminderOccurrenceRepository>(),
              ReminderRepository: () => context.read<ReminderRepository>(),
              ReminderSuggestionService: () =>
                  context.read<ReminderSuggestionService>(),
              SchedulingService: () => context.read<SchedulingService>(),
              SensorPhoneService: () => context.read<SensorPhoneService>(),
              SensorStation: () => context.read<SensorStation>(),
              SpeciesCareEnricher: () => context.read<SpeciesCareEnricher>(),
              SpeciesCareRepository: () =>
                  context.read<SpeciesCareRepository>(),
              SpeciesCareValueRepository: () =>
                  context.read<SpeciesCareValueRepository>(),
              SpeciesDescriptionService: () =>
                  context.read<SpeciesDescriptionService>(),
              SpeciesRepository: () => context.read<SpeciesRepository>(),
              SpeciesSynonymsRepository: () =>
                  context.read<SpeciesSynonymsRepository>(),
              SuggestionCareFiller: () => context.read<SuggestionCareFiller>(),
              UserSettingRepository: () =>
                  context.read<UserSettingRepository>(),
              WeatherService: () => context.read<WeatherService>(),
            };
            return const SizedBox();
          }),
        )));
    for (MapEntry<Type, Object Function()> e in created.entries) {
      expect(e.value, returnsNormally, reason: '${e.key}');
    }
  });
}
