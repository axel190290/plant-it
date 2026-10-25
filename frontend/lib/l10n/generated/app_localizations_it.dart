// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get searchYourPlants => 'Cerca nelle tue piante';

  @override
  String get filterActivities => 'Filtra Attività';

  @override
  String get filter => 'Filtra';

  @override
  String get eventTypes => 'Tipi Evento';

  @override
  String nEventTypes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString tipi evento';
  }

  @override
  String get whichEventsYouWantToAdd => 'Quali eventi vuoi aggiungere?';

  @override
  String get plants => 'Piante';

  @override
  String nPlants(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    return '$countString piant$_temp0';
  }

  @override
  String get whichPlantsYouWantToAdd => 'Quali piante vuoi aggiungere?';

  @override
  String get error => 'Errore';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get confirmDelete => 'Conferma eliminazione';

  @override
  String get areYouSureYouWantToDeleteThisEvent =>
      'Sei sicuro di rimuovere l\'evento?';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Rimuovi';

  @override
  String get eventDeleted => 'Evento rimosso';

  @override
  String get edit => 'Modifica';

  @override
  String get eventCreated => 'Evento creato';

  @override
  String get markDone => 'Segna fatto';

  @override
  String get reminder => 'Promemoria';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Avanti';

  @override
  String get confirm => 'Conferma';

  @override
  String get createEvent => 'Crea Evento';

  @override
  String get create => 'Crea';

  @override
  String get eventsCreated => 'Evento creato';

  @override
  String get save => 'Salva';

  @override
  String get editTheEvent => 'Modifica l\'evento';

  @override
  String get eventUpdated => 'Evento aggiornato';

  @override
  String get selectTheEventType => 'Seleziona il tipo di evento';

  @override
  String get selectThePlant => 'Seleziona la pianta';

  @override
  String get nextActions => 'Prossime azioni';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendario';

  @override
  String get search => 'Cerca';

  @override
  String get more => 'Altro';

  @override
  String get addPlant => 'Aggiungi Pianta';

  @override
  String get add => 'Aggiungi';

  @override
  String get plantAdded => 'Pianta aggiunta';

  @override
  String get location => 'Posizione';

  @override
  String get name => 'Nome';

  @override
  String get price => 'Prezzo';

  @override
  String get editPlant => 'Modifica Pianta';

  @override
  String get plantUpdated => 'Pianta aggiornata';

  @override
  String get deleteImage => 'Elimina immagine';

  @override
  String get areYouSureYouWantToDeleteThisImage =>
      'Sicuro di voler rimuovere l\'immagine?';

  @override
  String get info => 'Info';

  @override
  String get imageInfo => 'Info sull\'immagine';

  @override
  String get ok => 'Ok';

  @override
  String get download => 'Download';

  @override
  String get unsetAsAvatar => 'Rimuovi come Avatar';

  @override
  String get setAsAvatar => 'Seleziona come Avatar';

  @override
  String get information => 'Informazioni';

  @override
  String get care => 'Cura';

  @override
  String get reminders => 'Promemoria';

  @override
  String get events => 'Eventi';

  @override
  String get gallery => 'Galleria';

  @override
  String get duplicate => 'Duplica';

  @override
  String get plantDuplicated => 'Pianta duplicata';

  @override
  String get plantDeleted => 'Pianta eliminata';

  @override
  String get searchGreenFriends => 'Cerca nuovi amici';

  @override
  String get note => 'Note';

  @override
  String get update => 'Aggiorna';

  @override
  String get custom => 'creato';

  @override
  String get floraCodex => 'Flora Codex';

  @override
  String get seller => 'Venditore';

  @override
  String get remove => 'Rimuovi';

  @override
  String get createEventType => 'Crea Tipo Evento';

  @override
  String get selectAColor => 'Seleziona un colore';

  @override
  String get select => 'Seleziona';

  @override
  String get whichColorYouWantToUse => 'Quale colore vuoi usare?';

  @override
  String get description => 'Descrizione';

  @override
  String get whichIconYouWantToUse => 'Quale icona vuoi usare?';

  @override
  String get filterIcons => 'Filtra icone';

  @override
  String get insertAName => 'Inserisci un nome';

  @override
  String get editEventType => 'Modifica Tipo Evento';

  @override
  String get eventTypeUpdated => 'Tipo Evento aggiornato';

  @override
  String get areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents =>
      'Sicuro di voler eliminare il tipo evento e tutti gli eventi collegati?';

  @override
  String get eventTypeDeleted => 'Tipo Evento eliminato';

  @override
  String get createReminder => 'Crea Promemoria';

  @override
  String get reminderCreated => 'Promemoria creato';

  @override
  String get whichEventTypeYouWantToSet =>
      'Quale tipo evento vuoi selezionare?';

  @override
  String get quantity => 'Quantità';

  @override
  String get whichPlantsYouWantToSet => 'Quale pianta vuoi selezionare?';

  @override
  String get editReminder => 'Modifica Promemoria';

  @override
  String get reminderUpdated => 'Promemoria aggiornato';

  @override
  String get whichEventsYouWantToSet => 'Quali eventi vuoi selezionare?';

  @override
  String get reminderDeleted => 'Promemoria eliminato';

  @override
  String get areYouSureYouWantToDeleteTheReminder =>
      'Sicuro di voler eliminare il promemoria?';

  @override
  String get dataSources => 'Sorgenti dei dati';

  @override
  String get configureTheFloraCodexSettings =>
      'Configura le impostazioni di Flora Codex';

  @override
  String get insertTheFloraCodexApiKey => 'Inserisci l\'API Key di Flora Codex';

  @override
  String get enterApiKey => 'Inserisci l\'API Key';

  @override
  String get enableDataSource => 'Attiva la sorgente dei dati';

  @override
  String get apiKey => 'API Key';

  @override
  String get notProvided => 'non specificata';

  @override
  String get appInfo => 'Informazioni sull\'app';

  @override
  String get appVersion => 'Versione dell\'app';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get support => 'Supporta ♥️';

  @override
  String get notifications => 'Notifiche';

  @override
  String get enableNotifications => 'Attiva Notifiche';

  @override
  String get selectWeekdaysAndTimes => 'Seleziona giorni e orari';

  @override
  String get pickTime => 'Scegli orario';

  @override
  String get done => 'Fatto';

  @override
  String get aboutPlantIt => 'Plant-it info';

  @override
  String get manageTheEventTypes => 'Gestisci i tipi di evento';

  @override
  String get manageTheReminders => 'Gestisci i promemoria';

  @override
  String get manageTheDataSources => 'Gestisci le sorgenti di dati';

  @override
  String get configureWhenAndIfNotificationsAreReceived =>
      'Configura se e quando ricevere notifiche';

  @override
  String get detailsAboutTheApp => 'Dettagli sull\'app';

  @override
  String get yourSupportHelpsUsGrow => 'Il tuo supporto ci aiuta a crescere!';

  @override
  String get supportTheProject => 'Supporta il progetto';

  @override
  String get whySupportPlantIt => 'Perchè supportare Plant-it?';

  @override
  String get openSourceProjectThatBenefitsEveryone =>
      'Progetto open-source utilizzabile da chiunque';

  @override
  String get yourDonationsHelpUsImproveTheApp =>
      'Le donazioni ci aiutano a migliorare l\'app';

  @override
  String get supportNewFeaturesAndUpdates => 'Supporta nuovi aggiornamenti';

  @override
  String get donateNow => 'Dona Ora';

  @override
  String get createSpecies => 'Crea Specie';

  @override
  String get speciesCreated => 'Specie creata';

  @override
  String get avatar => 'Avatar';

  @override
  String get noAvatar => 'Nessun avatar';

  @override
  String get uploadPhoto => 'Carica foto';

  @override
  String get choosePhoto => 'Scegli foto';

  @override
  String get noPhoto => 'Nessuna foto';

  @override
  String get useWebImage => 'Usa immagine web';

  @override
  String get url => 'Url';

  @override
  String get light => 'Luce';

  @override
  String get humidity => 'Umidità';

  @override
  String get temperature => 'Temperatura';

  @override
  String get ph => 'Ph';

  @override
  String get genus => 'Genere';

  @override
  String get family => 'Famiglia';

  @override
  String get synonym => 'Sinonimo';

  @override
  String get addSynonym => 'Aggiungi sinonimo';

  @override
  String get classification => 'Classificazione';

  @override
  String get species => 'Specie';

  @override
  String get synonyms => 'Sinonimi';

  @override
  String get editSpecies => 'Modifica Specie';

  @override
  String get speciesUpdated => 'Specie aggiornata';

  @override
  String get addToCollection => 'Aggiungi alla collezione';

  @override
  String get showNextNotificationsDateTime =>
      'Mostra prossimi giorni e orari delle notifiche';

  @override
  String get date => 'Data';

  @override
  String get plant => 'Pianta';

  @override
  String get low => 'Basso';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get sunlight => 'Luce';

  @override
  String get min => 'min';

  @override
  String get max => 'max';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get color => 'Colore';

  @override
  String get red => 'rosso';

  @override
  String get green => 'verde';

  @override
  String get blue => 'blu';

  @override
  String get white => 'bianco';

  @override
  String get teal => 'verde acqua';

  @override
  String get yellow => 'giallo';

  @override
  String get icon => 'Icona';

  @override
  String get every => 'Ogni';

  @override
  String get repeatAfter => 'Ripeti dopo';

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
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp4 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp5 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp1',
        'months': 'mes$_temp2',
        'weeks': 'settiman$_temp3',
        'other': 'ann$_temp4',
      },
    );
    return 'Ogni$_temp0 $_temp5';
  }

  @override
  String afterMessage(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp4 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp0',
        'months': 'mes$_temp1',
        'weeks': 'settiman$_temp2',
        'other': 'ann$_temp3',
      },
    );
    return 'Dopo $quantityString $_temp4';
  }

  @override
  String frequency(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp4 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp0',
        'months': 'mes$_temp1',
        'weeks': 'settiman$_temp2',
        'other': 'ann$_temp3',
      },
    );
    return '$quantityString $_temp4';
  }

  @override
  String get day => 'giorno';

  @override
  String get week => 'settimane';

  @override
  String get month => 'mesi';

  @override
  String get year => 'anni';

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
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp4 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp5 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp1',
        'months': 'mes$_temp2',
        'weeks': 'settiman$_temp3',
        'other': 'ann$_temp4',
      },
    );
    String _temp6 = intl.Intl.selectLogic(
      endDate,
      {
        'null': '',
        'other': ' a $endDate',
      },
    );
    return 'Ogni$_temp0 $_temp5 da $startDateString$_temp6';
  }

  @override
  String get start => 'Inizio';

  @override
  String plantClassificationInfo(
      String name, String species, String genus, String family) {
    String _temp0 = intl.Intl.selectLogic(
      genus,
      {
        'null': '',
        'other': ', genere |$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': '',
        'other': ', famiglia |$family|',
      },
    );
    return '$name è una pianta della specie |$species|$_temp0$_temp1.';
  }

  @override
  String speciesSynonyms(String synonyms, String species) {
    String _temp0 = intl.Intl.selectLogic(
      synonyms,
      {
        'null': '$species non ha sinonimi',
        'other': '$species è conosciuta anche come: $synonyms',
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
        'null': 'sconosciuto',
        'other': '|$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': 'sconosciuta',
        'other': '|$family|',
      },
    );
    return '$species è una specie del genere $_temp0 e famiglia $_temp1.';
  }

  @override
  String get eventType => 'Tipo Evento';

  @override
  String get end => 'Fine';

  @override
  String get databaseAndCache => 'Database e Cache';

  @override
  String get manageDatabaseAndCache =>
      'Gestisci le impostazioni del Database e della Cache';

  @override
  String get clearCache => 'Svuota la Cache';

  @override
  String get cacheCleaned => 'Cache svuotata';

  @override
  String get noSynonyms => 'Nessun sinonimo conosciuto';

  @override
  String get areYouSureYouWantToDeleteThisPlant =>
      'Sicuro di voler eliminare questa pianta?';

  @override
  String get areYouSureYouWantToDeleteThisSpecies =>
      'Sicuro di voler eliminare questa specie e tutte le tue piante collegate?';

  @override
  String get speciesDeleted => 'Specie eliminata';

  @override
  String get noPlantsFound => 'Nessuna pianta trovata';

  @override
  String get yourPlantWillAppearHere =>
      'Le tue piante appariranno qui una volta aggiunte alla tua collezione';

  @override
  String get howToAddPlants => 'Come aggiungere una pianta';

  @override
  String get addPlantInstruction =>
      'Questa app funziona con piante di varie specie.\n\nPuoi aggiungere una nuova pianta cercando prima la specie (o aggiungendone una nuova) e poi collegando una pianta ad essa.\n\nPer iniziare, cerca una specie.';

  @override
  String get searchASpecies => 'Cerca una specie';

  @override
  String get noSpeciesFound => 'Nessuna specie trovata';

  @override
  String get searchAndAddSpeciesInstructions =>
      'Puoi aggiungere una nuova specie, oppure puoi collegare l\'app a un servizio per accedere a ulteriori specie.';

  @override
  String get connectToAService => 'Connetti l\'app ad un servizio';

  @override
  String get noInfoAvailable => 'Nessuna informazione disponibile';

  @override
  String get noReminder =>
      'Nessun promemoria trovato.\n\nCrea un nuovo promemoria per le tue piante per ricevere notifiche e vedere le prossime azioni da fare.';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get yesterday => 'Ieri';

  @override
  String inTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp4 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp0',
        'months': 'mes$_temp1',
        'weeks': 'settiman$_temp2',
        'other': 'ann$_temp3',
      },
    );
    return 'in $quantityString $_temp4';
  }

  @override
  String agoTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'e',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'e',
      one: 'a',
    );
    String _temp3 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    String _temp4 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'giorn$_temp0',
        'months': 'mes$_temp1',
        'weeks': 'settiman$_temp2',
        'other': 'ann$_temp3',
      },
    );
    return '$quantityString $_temp4 fa';
  }

  @override
  String get additionalInfo => 'Altre informazioni';

  @override
  String get floraCodexDescription =>
      'FloraCodex è un servizio che fornisce accesso a un database completo di specie, comprese le loro denominazioni scientifiche, nomi comuni e altre informazioni rilevanti. Per utilizzare questo servizio, è necessario ottenere una chiave API.';

  @override
  String get floraCodexGetApiKey =>
      'Per ottenere la tua chiave API, visita il sito web di FloraCodex, oppure clicca qui.';

  @override
  String get reloadNotificationMessages =>
      'Ricarica i messaggi delle notifiche';

  @override
  String get notificationMessagesReloaded =>
      'Messaggi delle notifiche ricaricati, chiudi e apri di nuovo l\'app';

  @override
  String get notificationTitle1 => 'Ops, l\'hai fatto di nuovo!';

  @override
  String get notificationTitle2 => 'SOS Piante!';

  @override
  String get notificationTitle3 =>
      'È tempo di diventare un sussurratore di piante!';

  @override
  String get notificationTitle4 => 'Non oggi, Pianta!';

  @override
  String get notificationTitle5 => 'Caffeina per piante necessaria!';

  @override
  String get notificationTitle6 => 'La pianta sta chiamando!';

  @override
  String get notificationTitle7 => 'Chiama la Squadra Verde!';

  @override
  String get notificationTitle8 => 'Drin drin...';

  @override
  String get notificationBody1 =>
      '|emoji| |plantName| ha bisogno del suo |eventType|. Non farlo aspettare!';

  @override
  String get notificationBody2 =>
      '|emoji| |plantName| sta chiamando per |eventType|. È tempo di salvare la situazione!';

  @override
  String get notificationBody3 =>
      '|emoji| |plantName| ha bisogno di |eventType|. Ti sta aspettando!';

  @override
  String get notificationBody4 =>
      '|emoji| |plantName| è stanco di aspettare per |eventType|. Mostragli un po\' di affetto!';

  @override
  String get notificationBody5 =>
      '|emoji| |plantName| è in ritardo per |eventType|. Dagli una spinta!';

  @override
  String get notificationBody6 =>
      '|emoji| |plantName| è pronto per |eventType|. Non deluderlo!';

  @override
  String get notificationBody7 =>
      '|emoji| |plantName| ha bisogno del suo |eventType|. Sei l\'eroe che merita!';

  @override
  String get notificationBody8 =>
      '|emoji| |plantName| sente la mancanza del suo |eventType|. È tempo di renderlo felice di nuovo!';

  @override
  String get gbifDescription =>
      'GBIF (Global Biodiversity Information Facility) è un database aperto e gratuito con i nomi scientifici e comuni di tutte le specie vegetali. Non richiede una chiave API. Le foto provengono da iNaturalist.';

  @override
  String get configureTheGbifSettings =>
      'Cerca piante per nome scientifico o comune, gratis';

  @override
  String get configureThePlantNetSettings => 'Identifica le piante da una foto';

  @override
  String get plantNetDescription =>
      'Pl@ntNet identifica le piante da una o più foto e collega ogni risultato alla relativa specie GBIF. Il piano gratuito consente 500 identificazioni al giorno. Per usarlo serve una chiave API gratuita.';

  @override
  String get plantNetGetApiKey =>
      'Per ottenere la tua chiave API, registrati sul sito di Pl@ntNet oppure clicca qui';

  @override
  String get insertThePlantNetApiKey => 'Inserisci l\'API Key di Pl@ntNet';

  @override
  String get configureTheOpenPlantbookSettings =>
      'Dati di cura: luce, temperatura e umidità';

  @override
  String get openPlantbookDescription =>
      'Open Plantbook è un database gratuito con gli intervalli di luce, temperatura e umidità di migliaia di piante. Non fornisce il pH del terreno. Per usarlo servono un client ID e un client secret gratuiti.';

  @override
  String get openPlantbookGetCredentials =>
      'Per ottenere le tue credenziali, registrati sul sito di Open Plantbook e crea un client API, oppure clicca qui';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client secret';

  @override
  String get aiCare => 'IA per completare la cura';

  @override
  String get configureTheAiCareSettings =>
      'Stima i valori di cura che nessuna fonte fornisce';

  @override
  String get aiCareDescription =>
      'Quando una pianta ha valori di cura che nessuna fonte fornisce (ad esempio il pH del terreno), un modello di IA può stimarli. I valori stimati sono indicati nella pagina della specie e si possono modificare quando la pianta è nella tua collezione. Viene inviato solo il nome scientifico della pianta.';

  @override
  String get aiProvider => 'Fornitore di IA';

  @override
  String get aiProviderNone => 'Nessuno';

  @override
  String get aiProviderClaudeHint =>
      'A pagamento. Ottieni una chiave API nella Claude Console';

  @override
  String get aiProviderGeminiHint =>
      'Ha un piano gratuito. Ottieni una chiave API in Google AI Studio';

  @override
  String get aiProviderGitHubModelsHint =>
      'Gratis con limiti. Usa un token GitHub con il permesso \"Models\"';

  @override
  String get getApiKeyClickHere => 'Per ottenere la tua chiave, clicca qui';

  @override
  String get aiModel => 'Modello';

  @override
  String aiModelDefault(String model) {
    return 'Predefinito: $model';
  }

  @override
  String get insertTheAiModel =>
      'Modello da usare (lascia vuoto per quello predefinito)';

  @override
  String get identifyByPhoto => 'Identifica da foto';

  @override
  String get camera => 'Fotocamera';

  @override
  String get identifying => 'Identificazione della pianta...';

  @override
  String get photoIdentificationResults =>
      'Specie più probabili nella tua foto';

  @override
  String get noPlantIdentified =>
      'Nessuna pianta identificata nella foto. Prova con una foto più ravvicinata di una foglia o di un fiore.';

  @override
  String get plantNetKeyMissing =>
      'Per identificare le piante da foto, aggiungi la tua chiave API di Pl@ntNet in Impostazioni > Sorgenti dei dati.';

  @override
  String identificationConfidence(String percent) {
    return '$percent% di corrispondenza';
  }

  @override
  String careSources(String sources) {
    return 'Fonti: $sources';
  }

  @override
  String aiEstimatedCare(String provider, String fields) {
    return 'Stimato dall\'IA ($provider): $fields. Controlla questi valori e modificali se necessario.';
  }

  @override
  String get notes => 'Note';

  @override
  String get noNotesTapToAdd => 'Ancora nessuna nota. Tocca per scriverne una.';

  @override
  String get editNotes => 'Modifica note';

  @override
  String get notesSaved => 'Note salvate';

  @override
  String get editCare => 'Modifica cura';

  @override
  String get editCareSharedWarning =>
      'La cura appartiene alla specie, quindi la modifica vale anche per le altre tue piante di questa specie.';

  @override
  String get allEvents => 'Cronologia';

  @override
  String get noEventsYet => 'Ancora nessun evento';

  @override
  String showAllEvents(String count) {
    return 'Mostra tutti ($count)';
  }

  @override
  String get showLess => 'Mostra meno';
}
