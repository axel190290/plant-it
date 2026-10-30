// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get searchYourPlants => 'Search your plants';

  @override
  String get filterActivities => 'Filter Activities';

  @override
  String get filter => 'Filter';

  @override
  String get eventTypes => 'Event Types';

  @override
  String nEventTypes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$countString event type$_temp0';
  }

  @override
  String get whichEventsYouWantToAdd => 'Which events you want to add?';

  @override
  String get plants => 'Plants';

  @override
  String nPlants(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$countString plant$_temp0';
  }

  @override
  String get whichPlantsYouWantToAdd => 'Which plants you want to add?';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try again';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get areYouSureYouWantToDeleteThisEvent =>
      'Are you sure you want to delete this event?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get eventDeleted => 'Event deleted';

  @override
  String get edit => 'Edit';

  @override
  String get eventCreated => 'Event created';

  @override
  String get markDone => 'Mark done';

  @override
  String get reminder => 'Reminder';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get confirm => 'Confirm';

  @override
  String get createEvent => 'Create Event';

  @override
  String get create => 'Create';

  @override
  String get eventsCreated => 'Events created';

  @override
  String get save => 'Save';

  @override
  String get editTheEvent => 'Edit the event';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get selectTheEventType => 'Select the event type';

  @override
  String get selectThePlant => 'Select the plant';

  @override
  String get nextActions => 'Next actions';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get search => 'Search';

  @override
  String get more => 'More';

  @override
  String get addPlant => 'Add Plant';

  @override
  String get add => 'Add';

  @override
  String get plantAdded => 'Plant added';

  @override
  String get location => 'Location';

  @override
  String get name => 'Name';

  @override
  String get price => 'Price';

  @override
  String get editPlant => 'Edit Plant';

  @override
  String get plantUpdated => 'Plant updated';

  @override
  String get deleteImage => 'Delete image';

  @override
  String get areYouSureYouWantToDeleteThisImage =>
      'Are you sure you want to delete this image?';

  @override
  String get info => 'Info';

  @override
  String get imageInfo => 'Image info';

  @override
  String get ok => 'Ok';

  @override
  String get download => 'Download';

  @override
  String get unsetAsAvatar => 'Unset as Avatar';

  @override
  String get setAsAvatar => 'Set as Avatar';

  @override
  String get information => 'Information';

  @override
  String get care => 'Care';

  @override
  String get reminders => 'Reminders';

  @override
  String get events => 'Events';

  @override
  String get gallery => 'Gallery';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get plantDuplicated => 'Plant duplicated';

  @override
  String get plantDeleted => 'Plant deleted';

  @override
  String get searchGreenFriends => 'Search green friends';

  @override
  String get note => 'Note';

  @override
  String get update => 'Update';

  @override
  String get custom => 'custom';

  @override
  String get floraCodex => 'Flora Codex';

  @override
  String get seller => 'Seller';

  @override
  String get remove => 'Remove';

  @override
  String get createEventType => 'Create Event Type';

  @override
  String get selectAColor => 'Select a color';

  @override
  String get select => 'Select';

  @override
  String get whichColorYouWantToUse => 'Which color you want to use?';

  @override
  String get description => 'Description';

  @override
  String get whichIconYouWantToUse => 'Which icon you want to use?';

  @override
  String get filterIcons => 'Filter icons';

  @override
  String get insertAName => 'Insert a name';

  @override
  String get editEventType => 'Edit Event Type';

  @override
  String get eventTypeUpdated => 'Event Type updated';

  @override
  String get areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents =>
      'Are you sure you want to delete the event type and all linked events?';

  @override
  String get eventTypeDeleted => 'Event Type deleted';

  @override
  String get createReminder => 'Create Reminder';

  @override
  String get reminderCreated => 'Reminder created';

  @override
  String get whichEventTypeYouWantToSet => 'Which event type you want to set?';

  @override
  String get quantity => 'Quantity';

  @override
  String get whichPlantsYouWantToSet => 'Which plant you want to set?';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get reminderUpdated => 'Reminder updated';

  @override
  String get whichEventsYouWantToSet => 'Which events you want to set?';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get areYouSureYouWantToDeleteTheReminder =>
      'Are you sure you want to delete the reminder?';

  @override
  String get dataSources => 'Data sources';

  @override
  String get configureTheFloraCodexSettings =>
      'Configure the Flora Codex settings';

  @override
  String get insertTheFloraCodexApiKey => 'Insert the Flora Codex API Key';

  @override
  String get enterApiKey => 'Enter API Key';

  @override
  String get enableDataSource => 'Enable data source';

  @override
  String get apiKey => 'API Key';

  @override
  String get notProvided => 'not provided';

  @override
  String get appInfo => 'App Info';

  @override
  String get appVersion => 'App version';

  @override
  String get sourceCode => 'Source code';

  @override
  String get support => 'Support ♥️';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get selectWeekdaysAndTimes => 'Select Weekdays and Times';

  @override
  String get pickTime => 'Pick Time';

  @override
  String get done => 'Done';

  @override
  String get aboutPlantIt => 'About Plant-it';

  @override
  String get manageTheEventTypes => 'Manage the event types';

  @override
  String get manageTheReminders => 'Manage the reminders';

  @override
  String get manageTheDataSources => 'Manage the data sources';

  @override
  String get configureWhenAndIfNotificationsAreReceived =>
      'Configure when and if notifications are received';

  @override
  String get detailsAboutTheApp => 'Details about the app';

  @override
  String get yourSupportHelpsUsGrow => 'Your support helps us grow!';

  @override
  String get supportTheProject => 'Support the project';

  @override
  String get whySupportPlantIt => 'Why Support Plant-it?';

  @override
  String get openSourceProjectThatBenefitsEveryone =>
      'Open-source project that benefits everyone.';

  @override
  String get yourDonationsHelpUsImproveTheApp =>
      'Your donations help us improve the app.';

  @override
  String get supportNewFeaturesAndUpdates =>
      'Support new features and updates.';

  @override
  String get donateNow => 'Donate Now';

  @override
  String get createSpecies => 'Create Species';

  @override
  String get speciesCreated => 'Species created';

  @override
  String get avatar => 'Avatar';

  @override
  String get noAvatar => 'No avatar';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get noPhoto => 'No photo';

  @override
  String get useWebImage => 'Use web image';

  @override
  String get url => 'Url';

  @override
  String get light => 'Light';

  @override
  String get humidity => 'Humidity';

  @override
  String get temperature => 'Temperature';

  @override
  String get ph => 'Ph';

  @override
  String get genus => 'Genus';

  @override
  String get family => 'Family';

  @override
  String get synonym => 'Synonym';

  @override
  String get addSynonym => 'Add synonym';

  @override
  String get classification => 'Classification';

  @override
  String get species => 'Species';

  @override
  String get synonyms => 'Synonyms';

  @override
  String get editSpecies => 'Edit Species';

  @override
  String get speciesUpdated => 'Species updated';

  @override
  String get addToCollection => 'Add to collection';

  @override
  String get showNextNotificationsDateTime =>
      'Show next notifications date and time';

  @override
  String get date => 'Date';

  @override
  String get plant => 'Plant';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get sunlight => 'Sunlight';

  @override
  String get min => 'min';

  @override
  String get max => 'max';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get color => 'Color';

  @override
  String get red => 'red';

  @override
  String get green => 'green';

  @override
  String get blue => 'blue';

  @override
  String get white => 'white';

  @override
  String get teal => 'teal';

  @override
  String get yellow => 'yellow';

  @override
  String get icon => 'Icon';

  @override
  String get every => 'Every';

  @override
  String get repeatAfter => 'Repeat after';

  @override
  String frequencyEvery(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: ' $quantityString',
      one: '',
    );
    String _temp1 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'months': 'month',
        'weeks': 'week',
        'other': 'year',
      },
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Every$_temp0 $_temp1$_temp2';
  }

  @override
  String afterMessage(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'months': 'month',
        'weeks': 'week',
        'other': 'year',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'After $quantityString $_temp0$_temp1';
  }

  @override
  String frequency(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'months': 'month',
        'weeks': 'week',
        'other': 'year',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$quantityString $_temp0$_temp1';
  }

  @override
  String get day => 'day';

  @override
  String get week => 'week';

  @override
  String get month => 'month';

  @override
  String get year => 'year';

  @override
  String reminderDescription(
      num quantity, String unit, DateTime startDate, String endDate) {
    final intl.DateFormat startDateDateFormat = intl.DateFormat.yMd(localeName);
    final String startDateString = startDateDateFormat.format(startDate);

    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: ' $quantityString',
      one: '',
    );
    String _temp1 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'months': 'month',
        'weeks': 'week',
        'other': 'years',
      },
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp3 = intl.Intl.selectLogic(
      endDate,
      {
        'null': '',
        'other': ' to $endDate',
      },
    );
    return 'Every$_temp0 $_temp1$_temp2 from $startDateString$_temp3';
  }

  @override
  String get start => 'Start';

  @override
  String plantClassificationInfo(
      String name, String species, String genus, String family) {
    String _temp0 = intl.Intl.selectLogic(
      genus,
      {
        'null': '',
        'other': ', genus |$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': '',
        'other': ', family |$family|',
      },
    );
    return '$name is a plant of species |$species|$_temp0$_temp1.';
  }

  @override
  String speciesSynonyms(String synonyms, String species) {
    String _temp0 = intl.Intl.selectLogic(
      synonyms,
      {
        'null': '$species has no synonyms',
        'other': '$species is also known as: $synonyms',
      },
    );
    return '$_temp0.';
  }

  @override
  String speciesClassificationInfo(
      String species, String genus, String family) {
    String _temp0 = intl.Intl.selectLogic(
      genus,
      {
        'null': 'unknown',
        'other': '|$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': 'unknown',
        'other': '|$family|',
      },
    );
    return '$species is a species of genus $_temp0 and family $_temp1.';
  }

  @override
  String get eventType => 'Event Type';

  @override
  String get end => 'End';

  @override
  String get databaseAndCache => 'Database and Cache';

  @override
  String get manageDatabaseAndCache => 'Manage Database and Cache settings';

  @override
  String get clearCache => 'Clear the Cache';

  @override
  String get cacheCleaned => 'Cache cleaned';

  @override
  String get noSynonyms => 'No known synonyms';

  @override
  String get areYouSureYouWantToDeleteThisPlant =>
      'Are you sure you want to delete this plant?';

  @override
  String get areYouSureYouWantToDeleteThisSpecies =>
      'Are you sure you want to delete this species and all of your related plants?';

  @override
  String get speciesDeleted => 'Species deleted';

  @override
  String get noPlantsFound => 'No plants found';

  @override
  String get yourPlantWillAppearHere =>
      'Your plants will appear here when once you add them into your collection';

  @override
  String get howToAddPlants => 'How to add plants';

  @override
  String get addPlantInstruction =>
      'This app works with plants from various species.\n\nYou can add a new plant by first searching for the species (or adding a new one) and then linking a plant to it.\n\nTo get started, search for a species.';

  @override
  String get searchASpecies => 'Search a species';

  @override
  String get noSpeciesFound => 'No species found';

  @override
  String get searchAndAddSpeciesInstructions =>
      'You can add a new species, or you can connect the app to a service to access additional species.';

  @override
  String get connectToAService => 'Connect to a service';

  @override
  String get noInfoAvailable => 'No info available';

  @override
  String get noReminder =>
      'No reminders found.\n\nCreate a new reminder for your plants to receive notifications and see the next actions you need to take.';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String inTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'weeks': 'week',
        'months': 'month',
        'other': 'year',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'in $quantityString $_temp0$_temp1';
  }

  @override
  String agoTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'day',
        'weeks': 'week',
        'months': 'month',
        'other': 'year',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$quantityString $_temp0$_temp1 ago';
  }

  @override
  String get additionalInfo => 'Additional info';

  @override
  String get floraCodexDescription =>
      'FloraCodex is a database service that provides access to a comprehensive database of plant species, including their scientific names, common names, and other relevant information. To use this service, you need to obtain an API key.';

  @override
  String get floraCodexGetApiKey =>
      'To get your API key, visit the FloraCodex website, or click here';

  @override
  String get reloadNotificationMessages => 'Reload the notification messages';

  @override
  String get notificationMessagesReloaded =>
      'Notification messages reloaded, close and open the app';

  @override
  String get notificationTitle1 => 'Oops, You Did It Again!';

  @override
  String get notificationTitle2 => 'Plant SOS!';

  @override
  String get notificationTitle3 => 'Time to be a Plant Whisperer!';

  @override
  String get notificationTitle4 => 'Not Today, Plant!';

  @override
  String get notificationTitle5 => 'Plant Caffeine Required!';

  @override
  String get notificationTitle6 => 'Leaf It Up to You!';

  @override
  String get notificationTitle7 => 'Call the Green Squad!';

  @override
  String get notificationTitle8 => 'You\'ve Been \'Leafing\' It Alone';

  @override
  String get notificationBody1 =>
      '|emoji| |plantName| needs its |eventType|. Don\'t keep it waiting!';

  @override
  String get notificationBody2 =>
      '|emoji| |plantName| is calling for |eventType|. Time to save the day!';

  @override
  String get notificationBody3 =>
      '|emoji| |plantName| needs |eventType|. It\'s waiting for you!';

  @override
  String get notificationBody4 =>
      '|emoji| |plantName| is tired of waiting for |eventType|. Show it some TLC!';

  @override
  String get notificationBody5 =>
      '|emoji| |plantName| is overdue for |eventType|. Give it a boost!';

  @override
  String get notificationBody6 =>
      '|emoji| |plantName| is ready for |eventType|. Don\'t let it down!';

  @override
  String get notificationBody7 =>
      '|emoji| |plantName| needs its |eventType|. You\'re the hero it deserves!';

  @override
  String get notificationBody8 =>
      '|emoji| |plantName| misses its |eventType|. Time to make it happy again!';

  @override
  String get gbifDescription =>
      'GBIF (Global Biodiversity Information Facility) is a free, open database with the scientific and common names of every plant species. It needs no API key. Photos are taken from iNaturalist.';

  @override
  String get configureTheGbifSettings =>
      'Search plants by scientific or common name, free';

  @override
  String get configureThePlantNetSettings => 'Identify plants from a photo';

  @override
  String get plantNetDescription =>
      'Pl@ntNet identifies plants from one or more photos and links each result to its GBIF species. The free plan allows 500 identifications per day. To use it you need a free API key.';

  @override
  String get plantNetGetApiKey =>
      'To get your API key, sign up on the Pl@ntNet website, or click here';

  @override
  String get insertThePlantNetApiKey => 'Insert the Pl@ntNet API Key';

  @override
  String get configureTheOpenPlantbookSettings =>
      'Care data: light, temperature and humidity';

  @override
  String get openPlantbookDescription =>
      'Open Plantbook is a free database with the light, temperature and humidity ranges of thousands of plants. It does not provide soil pH. To use it you need a free client ID and client secret.';

  @override
  String get openPlantbookGetCredentials =>
      'To get your credentials, sign up on the Open Plantbook website and create an API client, or click here';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client secret';

  @override
  String get aiCare => 'AI to complete care';

  @override
  String get configureTheAiCareSettings =>
      'Estimate the care values no source provides';

  @override
  String get aiCareDescription =>
      'When a plant has care values that no data source provides (for example soil pH), an AI model can estimate them. Estimated values are marked as such on the species page and can be edited once the plant is in your collection. Only the scientific name of the plant is sent.';

  @override
  String get aiProvider => 'AI provider';

  @override
  String get aiProviderNone => 'None';

  @override
  String get aiProviderClaudeHint =>
      'Paid. Get an API key in the Claude Console';

  @override
  String get aiProviderGeminiHint =>
      'Has a free tier. Get an API key in Google AI Studio';

  @override
  String get aiProviderGitHubModelsHint =>
      'Free with limits. Use a GitHub token with the \"Models\" permission';

  @override
  String get getApiKeyClickHere => 'To get your key, click here';

  @override
  String get aiModel => 'Model';

  @override
  String aiModelDefault(String model) {
    return 'Default: $model';
  }

  @override
  String get insertTheAiModel => 'Model to use (leave empty for the default)';

  @override
  String get identifyByPhoto => 'Identify by photo';

  @override
  String get camera => 'Camera';

  @override
  String get identifying => 'Identifying the plant...';

  @override
  String get photoIdentificationResults => 'Most likely species in your photo';

  @override
  String get noPlantIdentified =>
      'No plant could be identified in the photo. Try a closer photo of a leaf or flower.';

  @override
  String get plantNetKeyMissing =>
      'To identify plants by photo, add your Pl@ntNet API key in Settings > Data sources.';

  @override
  String identificationConfidence(String percent) {
    return '$percent% match';
  }

  @override
  String careSources(String sources) {
    return 'Sources: $sources';
  }

  @override
  String aiEstimatedCare(String provider, String fields) {
    return 'Estimated by AI ($provider): $fields. Check these values and edit them if needed.';
  }

  @override
  String get notes => 'Notes';

  @override
  String get noNotesTapToAdd => 'No notes yet. Tap to write one.';

  @override
  String get editNotes => 'Edit notes';

  @override
  String get notesSaved => 'Notes saved';

  @override
  String get editCare => 'Edit care';

  @override
  String get editCareSharedWarning =>
      'Care belongs to the species, so the change also applies to your other plants of this species.';

  @override
  String get allEvents => 'History';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String showAllEvents(String count) {
    return 'Show all ($count)';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get careFieldLightLux => 'Light (lux)';

  @override
  String get careFieldLightHours => 'Hours of light per day';

  @override
  String get careFieldEnvHumidity => 'Ambient humidity';

  @override
  String get careFieldWateringSummer => 'Watering in summer';

  @override
  String get careFieldWateringWinter => 'Watering in winter';

  @override
  String get careFieldSoilMoisture => 'Soil moisture';

  @override
  String get careFieldConductivity => 'Conductivity (EC)';

  @override
  String get careFieldWaterType => 'Type of water';

  @override
  String get careFieldWateringMethod => 'Watering method';

  @override
  String get careFieldSubstrate => 'Substrate';

  @override
  String get careFieldFertilizer => 'Fertilizer';

  @override
  String get careFieldPruning => 'Pruning';

  @override
  String get careFieldRepotting => 'Repotting';

  @override
  String get careFieldFloweringSeason => 'Flowering';

  @override
  String get careFieldDormancySeason => 'Dormancy';

  @override
  String get careFieldCommonPests => 'Common pests';

  @override
  String get careFieldDiseases => 'Diseases';

  @override
  String get careFieldToxicity => 'Toxicity';

  @override
  String everyNDays(String days) {
    return 'every $days days';
  }

  @override
  String get editMoreCare => 'Edit more care';

  @override
  String get careSaved => 'Care saved';

  @override
  String get careFields => 'Care categories';

  @override
  String get manageCareFields =>
      'Choose which care to show and create your own';

  @override
  String get careFieldsDescription =>
      'Enabled categories are shown in the Care section of every species and plant, in this order: drag them to reorder them and tap an icon to change it. Pests and treatments of a specific plant are recorded as events (\"pest\" and \"treatment\" types) in its history.';

  @override
  String get addCareField => 'New category';

  @override
  String get careFieldUnit => 'Unit (optional)';

  @override
  String get careFieldOptions => 'Options, separated by commas';

  @override
  String get careFieldType => 'Type';

  @override
  String get careFieldTypeNumber => 'Number';

  @override
  String get careFieldTypeRange => 'Range (min - max)';

  @override
  String get careFieldTypeText => 'Text';

  @override
  String get careFieldTypeChoice => 'List of options';

  @override
  String get customCareField => 'Created by you';

  @override
  String get areYouSureYouWantToDeleteThisCareField =>
      'Its values will be deleted from every species.';

  @override
  String get estimatedByAi => 'Estimated by AI';

  @override
  String get noCareFieldsEnabled =>
      'No care categories are enabled. Enable them in Settings > Care categories.';

  @override
  String get basicCare => 'Basic care';

  @override
  String get careCategories => 'Categories';

  @override
  String get notSet => 'Not set';

  @override
  String get editDescription => 'Edit description';

  @override
  String get noDescription =>
      'No description yet. Tap to write one or fill it in automatically.';

  @override
  String get fillAutomatically => 'Fill in automatically';

  @override
  String get noDescriptionFound => 'No description was found for this species.';

  @override
  String get descriptionSaved => 'Description saved';

  @override
  String get descriptionSharedWarning =>
      'The description belongs to the species, so it is shared by your plants of this species.';

  @override
  String get changeIcon => 'Change icon';

  @override
  String get restoreDefaultIcon => 'Default icon';

  @override
  String get indoor => 'Indoor';

  @override
  String get outdoor => 'Outdoor';

  @override
  String get weatherAndLocation => 'Weather and location';

  @override
  String get manageWeather => 'Local weather and season for your plants';

  @override
  String get weatherDescription =>
      'Your location is used to show the local weather and season, highlight the watering of the current season and warn about frost, heat and rain for your outdoor plants. The weather comes from Open-Meteo, which receives only your approximate location.';

  @override
  String get searchCity => 'Search your city';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get myLocation => 'My location';

  @override
  String get noPlaceSet => 'No location set';

  @override
  String get locationPermissionDenied =>
      'The location is not available. Allow it in the phone settings or search your city.';

  @override
  String get noPlacesFound => 'No place found';

  @override
  String get setUpWeather =>
      'Set your location to see the weather and the season';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonDry => 'Dry season';

  @override
  String get seasonRainy => 'Rainy season';

  @override
  String humidityPercent(String humidity) {
    return '$humidity% humidity';
  }

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherStorm => 'Storm';

  @override
  String frostAlert(String day, String temperature, String plant, String min) {
    return '$day: down to $temperature °C. $plant withstands at least $min °C';
  }

  @override
  String heatAlert(String day, String temperature, String plant, String max) {
    return '$day: up to $temperature °C. $plant withstands at most $max °C';
  }

  @override
  String rainAlert(String plants) {
    return 'Rain today: you can skip watering $plants';
  }

  @override
  String get outdoorAlertsHint =>
      'Frost, heat and rain alerts are shown for plants whose location is Outdoor.';

  @override
  String get currentSeason => 'now';

  @override
  String get forecast => 'Forecast';

  @override
  String get changePlantImage => 'Change image';

  @override
  String get phoneGallery => 'Phone gallery';

  @override
  String get speciesPhotosOnline => 'Photos of the species on the Internet';

  @override
  String get fromLink => 'From a link';

  @override
  String get imageLink => 'Image link (https://…)';

  @override
  String get useSpeciesImage => 'Use the species image';

  @override
  String get imageUpdated => 'Image updated';

  @override
  String get noPhotosFound => 'No photos found for this species';

  @override
  String get photosFromINaturalist =>
      'Photos shared on iNaturalist. The one you choose is saved with the plant photos.';

  @override
  String suggestionsForPlant(String plant) {
    return 'Suggestions for $plant';
  }

  @override
  String get suggestionsHint =>
      'Based on its care, the season and its location. Tap one to create it.';

  @override
  String get noSuggestions =>
      'No suggestions: add care such as watering or fertilizer to the plant\'s species.';

  @override
  String get suggestionWatering => 'Watering';

  @override
  String get suggestionFertilizing => 'Fertilizer';

  @override
  String get suggestionPruning => 'Pruning';

  @override
  String get suggestionRepotting => 'Repotting';

  @override
  String get suggestionPestCheck => 'Check for pests';

  @override
  String get suggestionMisting => 'Mist the leaves';

  @override
  String get suggestionProtectFromCold => 'Protect from the cold';

  @override
  String get suggestionMoveOutdoors => 'Move outdoors';

  @override
  String get reasonWatering => 'Watering of the current season';

  @override
  String get reasonFertilizing => 'During the growing season';

  @override
  String get reasonPruning => 'At its pruning time';

  @override
  String get reasonRepotting => 'At its repotting frequency';

  @override
  String get reasonPestCheck => 'Look for its usual pests on leaves and stems';

  @override
  String get reasonMisting => 'It needs a high ambient humidity';

  @override
  String get reasonProtectFromCold =>
      'Outdoor plant that does not withstand winter cold';

  @override
  String get reasonMoveOutdoors => 'When the warm weather returns';

  @override
  String everyCountDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count days',
      one: 'every day',
    );
    return '$_temp0';
  }

  @override
  String everyCountWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count weeks',
      one: 'every week',
    );
    return '$_temp0';
  }

  @override
  String everyCountMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count months',
      one: 'every month',
    );
    return '$_temp0';
  }

  @override
  String everyCountYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count years',
      one: 'every year',
    );
    return '$_temp0';
  }

  @override
  String fromDate(String date) {
    return 'from $date';
  }

  @override
  String untilDate(String date) {
    return 'until $date';
  }

  @override
  String protectFromRainAlert(
      String plant, String rain, String days, String watering) {
    return '$plant: rain on $rain of the next $days days, more often than it is watered (every $watering days). Protect it from the rain';
  }

  @override
  String get careFieldMistingEvery => 'Misting frequency';

  @override
  String get careFieldFertilizerEvery => 'Fertilizer frequency';

  @override
  String get careFieldPruningMonth => 'Pruning month';

  @override
  String get careFieldRepottingYears => 'Repotting frequency';

  @override
  String get careFieldRepottingMonth => 'Repotting month';

  @override
  String get careFieldMonth => 'Month';

  @override
  String get fillWithAi => 'Fill in with AI';

  @override
  String get fillWithAiHint =>
      'Fills the empty categories used to suggest reminders, marked with a bell, with the AI or with the typical values of the plant group. Review them and save.';

  @override
  String get usedForSuggestions => 'Used to suggest reminders';

  @override
  String aiFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values filled in by AI. Review them and save.',
      one: '1 value filled in by AI. Review it and save.',
      zero: 'The AI did not give new values',
    );
    return '$_temp0';
  }

  @override
  String get aiNotConfigured =>
      'Choose an AI provider and its key in Settings > Data sources';

  @override
  String get careFieldUnitYears => 'years';

  @override
  String remindersToCreate(int count) {
    return '$count reminders will be created, one per period';
  }

  @override
  String get plantGroupCacti => 'Cacti';

  @override
  String get plantGroupSucculents => 'Succulents';

  @override
  String get plantGroupZamioculcas => 'ZZ plants';

  @override
  String get plantGroupAroids => 'Aroids';

  @override
  String get plantGroupFerns => 'Ferns';

  @override
  String get plantGroupOrchids => 'Orchids';

  @override
  String get plantGroupAirPlants => 'Air plants';

  @override
  String get plantGroupBromeliads => 'Bromeliads';

  @override
  String get plantGroupPalms => 'Palms';

  @override
  String get plantGroupPrayerPlants => 'Prayer plants';

  @override
  String get plantGroupFicus => 'Ficus';

  @override
  String get plantGroupDracaenas => 'Dracaenas and relatives';

  @override
  String get plantGroupHerbs => 'Aromatic herbs';

  @override
  String get plantGroupRoses => 'Roses';

  @override
  String get plantGroupBegonias => 'Begonias';

  @override
  String get plantGroupGesneriads => 'African violets and relatives';

  @override
  String get plantGroupCitrus => 'Citrus';

  @override
  String get plantGroupCarnivorous => 'Carnivorous plants';

  @override
  String get careFieldFloweringMonths => 'Flowering months';

  @override
  String get careFieldDormancyMonths => 'Rest months';

  @override
  String typicalCareSource(String group) {
    return 'Typical values of $group';
  }

  @override
  String typicalValueOf(String group) {
    return 'Typical value of $group';
  }

  @override
  String fillWithGroup(String group) {
    return 'Typical values: $group';
  }

  @override
  String groupFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count typical values filled in. Review them and save.',
      one: '1 typical value filled in. Review it and save.',
      zero: 'No empty category to fill in',
    );
    return '$_temp0';
  }

  @override
  String get periodDormancy => 'Rest';

  @override
  String get createEventOrReminder => 'What do you want to create?';

  @override
  String get createEventHint => 'Record a care already done';

  @override
  String get createReminderHint => 'Get reminded of a care';

  @override
  String get plantCollections => 'Groups';

  @override
  String get allPlants => 'All';

  @override
  String get newCollection => 'New group';

  @override
  String get collectionName => 'Group name';

  @override
  String get renameCollection => 'Rename';

  @override
  String get choosePlants => 'Choose plants';

  @override
  String get deleteCollection => 'Delete group';

  @override
  String deleteCollectionConfirm(String name) {
    return 'Delete the group $name? Its plants are kept.';
  }

  @override
  String get emptyCollection =>
      'No plants in this group yet. Long press it to choose them.';

  @override
  String get noCollectionsYet =>
      'No groups yet: create one to sort your plants.';

  @override
  String get swipeToDismiss => 'Swipe an alert to dismiss it';

  @override
  String get ungroupedPlants => 'Without group';

  @override
  String get perPlantSuggestions =>
      'Use the frequency suggested for each plant';

  @override
  String perPlantSuggestionsHint(String group) {
    return 'A reminder is made for each plant of $group. Plants without a suggestion take the values of the summary.';
  }

  @override
  String remindersForGroup(String group) {
    return 'A reminder is made for each plant of $group, with the values of the summary.';
  }

  @override
  String suggestedForPlants(int count, int total) {
    return 'Suggested for $count of $total';
  }
}
