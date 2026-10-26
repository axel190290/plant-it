enum UserSettingsKeys {
  notificationEnabled('notification_enabled'),
  notificationTimeMonday('notification_time_monday'),
  notificationTimeTuesday('notification_time_tuesday'),
  notificationTimeWednesday('notification_time_wednesday'),
  notificationTimeThursday('notification_time_thursday'),
  notificationTimeFriday('notification_time_friday'),
  notificationTimeSaturday('notification_time_saturday'),
  notificationTimeSunday('notification_time_sunday'),

  notificationDateTimeMonday('notification_datetime_monday'),
  notificationDateTimeTuesday('notification_datetime_tuesday'),
  notificationDateTimeWednesday('notification_datetime_wednesday'),
  notificationDateTimeThursday('notification_datetime_thursday'),
  notificationDateTimeFriday('notification_datetime_friday'),
  notificationDateTimeSaturday('notification_datetime_saturday'),
  notificationDateTimeSunday('notification_datetime_sunday'),

  useFloraCodex('use_flora_codex'),
  floraCodexKey('flora_codex_key'),

  useGbif('use_gbif'),
  plantNetKey('plantnet_key'),
  plantbookClientId('plantbook_client_id'),
  plantbookClientSecret('plantbook_client_secret'),

  aiProvider('ai_provider'),
  claudeKey('claude_key'),
  claudeModel('claude_model'),
  geminiKey('gemini_key'),
  geminiModel('gemini_model'),
  githubModelsToken('github_models_token'),
  githubModelsModel('github_models_model'),

  weatherPlace('weather_place'),
  weatherLatitude('weather_latitude'),
  weatherLongitude('weather_longitude');

  final String key;

  const UserSettingsKeys(this.key);
}
