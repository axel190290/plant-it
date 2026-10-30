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

  @override
  String get careFieldLightLux => 'Luce (lux)';

  @override
  String get careFieldLightHours => 'Ore di luce al giorno';

  @override
  String get careFieldEnvHumidity => 'Umidità ambientale';

  @override
  String get careFieldWateringSummer => 'Annaffiatura in estate';

  @override
  String get careFieldWateringWinter => 'Annaffiatura in inverno';

  @override
  String get careFieldSoilMoisture => 'Umidità del terreno';

  @override
  String get careFieldConductivity => 'Conducibilità (EC)';

  @override
  String get careFieldWaterType => 'Tipo di acqua';

  @override
  String get careFieldWateringMethod => 'Metodo di annaffiatura';

  @override
  String get careFieldSubstrate => 'Substrato';

  @override
  String get careFieldFertilizer => 'Concime';

  @override
  String get careFieldPruning => 'Potatura';

  @override
  String get careFieldRepotting => 'Rinvaso';

  @override
  String get careFieldFloweringSeason => 'Fioritura';

  @override
  String get careFieldDormancySeason => 'Riposo vegetativo';

  @override
  String get careFieldCommonPests => 'Parassiti comuni';

  @override
  String get careFieldDiseases => 'Malattie';

  @override
  String get careFieldToxicity => 'Tossicità';

  @override
  String everyNDays(String days) {
    return 'ogni $days giorni';
  }

  @override
  String get editMoreCare => 'Modifica altre cure';

  @override
  String get careSaved => 'Cure salvate';

  @override
  String get careFields => 'Categorie di cura';

  @override
  String get manageCareFields => 'Scegli quali cure mostrare e crea le tue';

  @override
  String get careFieldsDescription =>
      'Le categorie attive sono mostrate nella sezione Cura di ogni specie e pianta, in questo ordine: trascinale per riordinarle e tocca un\'icona per cambiarla. Parassiti e trattamenti di una pianta specifica si registrano come eventi (tipi \"pest\" e \"treatment\") nella sua cronologia.';

  @override
  String get addCareField => 'Nuova categoria';

  @override
  String get careFieldUnit => 'Unità (facoltativa)';

  @override
  String get careFieldOptions => 'Opzioni, separate da virgole';

  @override
  String get careFieldType => 'Tipo';

  @override
  String get careFieldTypeNumber => 'Numero';

  @override
  String get careFieldTypeRange => 'Intervallo (min - max)';

  @override
  String get careFieldTypeText => 'Testo';

  @override
  String get careFieldTypeChoice => 'Elenco di opzioni';

  @override
  String get customCareField => 'Creato da te';

  @override
  String get areYouSureYouWantToDeleteThisCareField =>
      'I suoi valori saranno eliminati da tutte le specie.';

  @override
  String get estimatedByAi => 'Stimato dall\'IA';

  @override
  String get noCareFieldsEnabled =>
      'Nessuna categoria di cura attiva. Attivale in Impostazioni > Categorie di cura.';

  @override
  String get basicCare => 'Cure di base';

  @override
  String get careCategories => 'Categorie';

  @override
  String get notSet => 'Non impostato';

  @override
  String get editDescription => 'Modifica descrizione';

  @override
  String get noDescription =>
      'Ancora nessuna descrizione. Tocca per scriverla o compilarla automaticamente.';

  @override
  String get fillAutomatically => 'Compila automaticamente';

  @override
  String get noDescriptionFound =>
      'Nessuna descrizione trovata per questa specie.';

  @override
  String get descriptionSaved => 'Descrizione salvata';

  @override
  String get descriptionSharedWarning =>
      'La descrizione appartiene alla specie, quindi è condivisa dalle tue piante di questa specie.';

  @override
  String get changeIcon => 'Cambia icona';

  @override
  String get restoreDefaultIcon => 'Icona originale';

  @override
  String get indoor => 'Interno';

  @override
  String get outdoor => 'Esterno';

  @override
  String get weatherAndLocation => 'Meteo e posizione';

  @override
  String get manageWeather => 'Meteo locale e stagione per le tue piante';

  @override
  String get weatherDescription =>
      'La tua posizione serve a mostrare meteo e stagione, evidenziare l\'annaffiatura della stagione attuale e avvisarti di gelate, caldo e pioggia per le piante esterne. Il meteo proviene da Open-Meteo, che riceve solo la tua posizione approssimativa.';

  @override
  String get searchCity => 'Cerca la tua città';

  @override
  String get useMyLocation => 'Usa la mia posizione';

  @override
  String get myLocation => 'La mia posizione';

  @override
  String get noPlaceSet => 'Nessuna posizione';

  @override
  String get locationPermissionDenied =>
      'La posizione non è disponibile. Consentila nelle impostazioni del telefono o cerca la tua città.';

  @override
  String get noPlacesFound => 'Nessun luogo trovato';

  @override
  String get setUpWeather =>
      'Imposta la tua posizione per vedere meteo e stagione';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Estate';

  @override
  String get seasonAutumn => 'Autunno';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonDry => 'Stagione secca';

  @override
  String get seasonRainy => 'Stagione delle piogge';

  @override
  String humidityPercent(String humidity) {
    return '$humidity% umidità';
  }

  @override
  String get weatherClear => 'Sereno';

  @override
  String get weatherPartlyCloudy => 'Parzialmente nuvoloso';

  @override
  String get weatherCloudy => 'Nuvoloso';

  @override
  String get weatherFog => 'Nebbia';

  @override
  String get weatherDrizzle => 'Pioviggine';

  @override
  String get weatherRain => 'Pioggia';

  @override
  String get weatherSnow => 'Neve';

  @override
  String get weatherStorm => 'Temporale';

  @override
  String frostAlert(String day, String temperature, String plant, String min) {
    return '$day: fino a $temperature °C. $plant resiste almeno $min °C';
  }

  @override
  String heatAlert(String day, String temperature, String plant, String max) {
    return '$day: fino a $temperature °C. $plant resiste al massimo $max °C';
  }

  @override
  String rainAlert(String plants) {
    return 'Oggi piove: puoi saltare l\'annaffiatura di $plants';
  }

  @override
  String get outdoorAlertsHint =>
      'Gli avvisi di gelo, caldo e pioggia sono mostrati per le piante con posizione Esterno.';

  @override
  String get currentSeason => 'ora';

  @override
  String get forecast => 'Previsioni';

  @override
  String get changePlantImage => 'Cambia immagine';

  @override
  String get phoneGallery => 'Galleria del telefono';

  @override
  String get speciesPhotosOnline => 'Foto della specie su internet';

  @override
  String get fromLink => 'Da un link';

  @override
  String get imageLink => 'Link dell\'immagine (https://…)';

  @override
  String get useSpeciesImage => 'Usa l\'immagine della specie';

  @override
  String get imageUpdated => 'Immagine aggiornata';

  @override
  String get noPhotosFound => 'Nessuna foto trovata per questa specie';

  @override
  String get photosFromINaturalist =>
      'Foto condivise su iNaturalist. Quella scelta viene salvata con le foto della pianta.';

  @override
  String suggestionsForPlant(String plant) {
    return 'Suggerimenti per $plant';
  }

  @override
  String get suggestionsHint =>
      'In base alle sue cure, alla stagione e alla sua posizione. Toccane uno per crearlo.';

  @override
  String get noSuggestions =>
      'Nessun suggerimento: aggiungi cure come annaffiatura o concime nella scheda della pianta.';

  @override
  String get suggestionWatering => 'Annaffiatura';

  @override
  String get suggestionFertilizing => 'Concime';

  @override
  String get suggestionPruning => 'Potatura';

  @override
  String get suggestionRepotting => 'Rinvaso';

  @override
  String get suggestionPestCheck => 'Controllare i parassiti';

  @override
  String get suggestionMisting => 'Nebulizzare le foglie';

  @override
  String get suggestionProtectFromCold => 'Proteggere dal freddo';

  @override
  String get suggestionMoveOutdoors => 'Portare all\'esterno';

  @override
  String get reasonWatering => 'Annaffiatura della stagione attuale';

  @override
  String get reasonFertilizing => 'Durante la stagione di crescita';

  @override
  String get reasonPruning => 'Nel suo periodo di potatura';

  @override
  String get reasonRepotting => 'Secondo la sua frequenza di rinvaso';

  @override
  String get reasonPestCheck =>
      'Cerca i suoi parassiti abituali su foglie e steli';

  @override
  String get reasonMisting => 'Ha bisogno di un\'alta umidità ambientale';

  @override
  String get reasonProtectFromCold =>
      'Pianta esterna che non resiste al freddo invernale';

  @override
  String get reasonMoveOutdoors => 'Quando torna il bel tempo';

  @override
  String everyCountDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ogni $count giorni',
      one: 'ogni giorno',
    );
    return '$_temp0';
  }

  @override
  String everyCountWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ogni $count settimane',
      one: 'ogni settimana',
    );
    return '$_temp0';
  }

  @override
  String everyCountMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ogni $count mesi',
      one: 'ogni mese',
    );
    return '$_temp0';
  }

  @override
  String everyCountYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ogni $count anni',
      one: 'ogni anno',
    );
    return '$_temp0';
  }

  @override
  String fromDate(String date) {
    return 'dal $date';
  }

  @override
  String untilDate(String date) {
    return 'fino al $date';
  }

  @override
  String protectFromRainAlert(
      String plant, String rain, String days, String watering) {
    return '$plant: pioggia in $rain dei prossimi $days giorni, più spesso di quanto si annaffia (ogni $watering giorni). Proteggila dalla pioggia';
  }

  @override
  String get careFieldMistingEvery => 'Frequenza di nebulizzazione';

  @override
  String get careFieldFertilizerEvery => 'Frequenza di concimazione';

  @override
  String get careFieldPruningMonth => 'Mese di potatura';

  @override
  String get careFieldRepottingYears => 'Frequenza di rinvaso';

  @override
  String get careFieldRepottingMonth => 'Mese di rinvaso';

  @override
  String get careFieldMonth => 'Mese';

  @override
  String get fillWithAi => 'Completa con l\'IA';

  @override
  String get fillWithAiHint =>
      'Compila le categorie vuote usate per suggerire promemoria, segnate con una campana, con l\'IA o con i valori tipici del gruppo della pianta. Controllale e salva.';

  @override
  String get usedForSuggestions => 'Usato per suggerire promemoria';

  @override
  String aiFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valori compilati dall\'IA. Controllali e salva.',
      one: '1 valore compilato dall\'IA. Controllalo e salva.',
      zero: 'L\'IA non ha dato nuovi valori',
    );
    return '$_temp0';
  }

  @override
  String get aiNotConfigured =>
      'Scegli un fornitore di IA e la sua chiave in Impostazioni > Sorgenti dei dati';

  @override
  String get careFieldUnitYears => 'anni';

  @override
  String remindersToCreate(int count) {
    return 'Verranno creati $count promemoria, uno per periodo';
  }

  @override
  String get plantGroupCacti => 'Cactus';

  @override
  String get plantGroupSucculents => 'Succulente';

  @override
  String get plantGroupZamioculcas => 'Zamioculcas';

  @override
  String get plantGroupAroids => 'Aracee';

  @override
  String get plantGroupFerns => 'Felci';

  @override
  String get plantGroupOrchids => 'Orchidee';

  @override
  String get plantGroupAirPlants => 'Tillandsie';

  @override
  String get plantGroupBromeliads => 'Bromeliacee';

  @override
  String get plantGroupPalms => 'Palme';

  @override
  String get plantGroupPrayerPlants => 'Maranta e calathea';

  @override
  String get plantGroupFicus => 'Ficus';

  @override
  String get plantGroupDracaenas => 'Dracene e simili';

  @override
  String get plantGroupHerbs => 'Erbe aromatiche';

  @override
  String get plantGroupRoses => 'Rose';

  @override
  String get plantGroupBegonias => 'Begonie';

  @override
  String get plantGroupGesneriads => 'Violette africane e simili';

  @override
  String get plantGroupCitrus => 'Agrumi';

  @override
  String get plantGroupCarnivorous => 'Piante carnivore';

  @override
  String get careFieldFloweringMonths => 'Mesi di fioritura';

  @override
  String get careFieldDormancyMonths => 'Mesi di riposo';

  @override
  String typicalCareSource(String group) {
    return 'Valori tipici di $group';
  }

  @override
  String typicalValueOf(String group) {
    return 'Valore tipico di $group';
  }

  @override
  String fillWithGroup(String group) {
    return 'Valori tipici: $group';
  }

  @override
  String groupFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valori tipici compilati. Controllali e salva.',
      one: '1 valore tipico compilato. Controllalo e salva.',
      zero: 'Nessuna categoria vuota da compilare',
    );
    return '$_temp0';
  }

  @override
  String get periodDormancy => 'Riposo';

  @override
  String get createEventOrReminder => 'Cosa vuoi creare?';

  @override
  String get createEventHint => 'Registra una cura già fatta';

  @override
  String get createReminderHint => 'Ricevi un promemoria per una cura';

  @override
  String get plantCollections => 'Gruppi';

  @override
  String get allPlants => 'Tutte';

  @override
  String get newCollection => 'Nuovo gruppo';

  @override
  String get collectionName => 'Nome del gruppo';

  @override
  String get renameCollection => 'Rinomina';

  @override
  String get choosePlants => 'Scegli piante';

  @override
  String get deleteCollection => 'Elimina gruppo';

  @override
  String deleteCollectionConfirm(String name) {
    return 'Eliminare il gruppo $name? Le sue piante restano.';
  }

  @override
  String get emptyCollection =>
      'Ancora nessuna pianta in questo gruppo. Tienilo premuto per sceglierle.';

  @override
  String get noCollectionsYet =>
      'Ancora nessun gruppo: creane uno per ordinare le piante.';

  @override
  String get swipeToDismiss => 'Scorri un avviso per ignorarlo';

  @override
  String get ungroupedPlants => 'Senza gruppo';
}
