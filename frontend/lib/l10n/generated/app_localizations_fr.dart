// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get searchYourPlants => 'Rechercher vos plantes';

  @override
  String get filterActivities => 'Filtrer les activités';

  @override
  String get filter => 'Filtrer';

  @override
  String get eventTypes => 'Types d\'événements';

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
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$countString type$_temp0 d\'événement$_temp1';
  }

  @override
  String get whichEventsYouWantToAdd =>
      'Quels événements souhaitez-vous ajouter ?';

  @override
  String get plants => 'Plantes';

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
    return '$countString plante$_temp0';
  }

  @override
  String get whichPlantsYouWantToAdd =>
      'Quelles plantes souhaitez-vous ajouter ?';

  @override
  String get error => 'Erreur';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get areYouSureYouWantToDeleteThisEvent =>
      'Êtes-vous sûr de vouloir supprimer cet événement ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get eventDeleted => 'Événement supprimé';

  @override
  String get edit => 'Modifier';

  @override
  String get eventCreated => 'Événement créé';

  @override
  String get markDone => 'Marquer comme terminé';

  @override
  String get reminder => 'Rappel';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get confirm => 'Confirmer';

  @override
  String get createEvent => 'Créer un événement';

  @override
  String get create => 'Créer';

  @override
  String get eventsCreated => 'Événements créés';

  @override
  String get save => 'Enregistrer';

  @override
  String get editTheEvent => 'Modifier l\'événement';

  @override
  String get eventUpdated => 'Événement mis à jour';

  @override
  String get selectTheEventType => 'Sélectionner le type d\'événement';

  @override
  String get selectThePlant => 'Sélectionner la plante';

  @override
  String get nextActions => 'Prochaines actions';

  @override
  String get home => 'Accueil';

  @override
  String get calendar => 'Calendrier';

  @override
  String get search => 'Rechercher';

  @override
  String get more => 'Plus';

  @override
  String get addPlant => 'Ajouter une plante';

  @override
  String get add => 'Ajouter';

  @override
  String get plantAdded => 'Plante ajoutée';

  @override
  String get location => 'Emplacement';

  @override
  String get name => 'Nom';

  @override
  String get price => 'Prix';

  @override
  String get editPlant => 'Modifier la plante';

  @override
  String get plantUpdated => 'Plante mise à jour';

  @override
  String get deleteImage => 'Supprimer l\'image';

  @override
  String get areYouSureYouWantToDeleteThisImage =>
      'Êtes-vous sûr de vouloir supprimer cette image ?';

  @override
  String get info => 'Infos';

  @override
  String get imageInfo => 'Informations sur l\'image';

  @override
  String get ok => 'OK';

  @override
  String get download => 'Télécharger';

  @override
  String get unsetAsAvatar => 'Annuler l\'avatar';

  @override
  String get setAsAvatar => 'Définir comme avatar';

  @override
  String get information => 'Informations';

  @override
  String get care => 'Entretien';

  @override
  String get reminders => 'Rappels';

  @override
  String get events => 'Événements';

  @override
  String get gallery => 'Galerie';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get plantDuplicated => 'Plante dupliquée';

  @override
  String get plantDeleted => 'Plante supprimée';

  @override
  String get searchGreenFriends => 'Rechercher des amis verts';

  @override
  String get note => 'Note';

  @override
  String get update => 'Mettre à jour';

  @override
  String get custom => 'personnalisé';

  @override
  String get floraCodex => 'Flora Codex';

  @override
  String get seller => 'Vendeur';

  @override
  String get remove => 'Supprimer';

  @override
  String get createEventType => 'Créer un type d\'événement';

  @override
  String get selectAColor => 'Sélectionner une couleur';

  @override
  String get select => 'Sélectionner';

  @override
  String get whichColorYouWantToUse =>
      'Quelle couleur souhaitez-vous utiliser ?';

  @override
  String get description => 'Description';

  @override
  String get whichIconYouWantToUse => 'Quel icône souhaitez-vous utiliser ?';

  @override
  String get filterIcons => 'Filtrer les icônes';

  @override
  String get insertAName => 'Saisir un nom';

  @override
  String get editEventType => 'Modifier le type d\'événement';

  @override
  String get eventTypeUpdated => 'Type d\'événement mis à jour';

  @override
  String get areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents =>
      'Êtes-vous sûr de vouloir supprimer le type d\'événement et tous les événements liés ?';

  @override
  String get eventTypeDeleted => 'Type d\'événement supprimé';

  @override
  String get createReminder => 'Créer un rappel';

  @override
  String get reminderCreated => 'Rappel créé';

  @override
  String get whichEventTypeYouWantToSet =>
      'Quel type d\'événement souhaitez-vous définir ?';

  @override
  String get quantity => 'Quantité';

  @override
  String get whichPlantsYouWantToSet =>
      'Quelle plante souhaitez-vous définir ?';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get reminderUpdated => 'Rappel mis à jour';

  @override
  String get whichEventsYouWantToSet =>
      'Quels événements souhaitez-vous définir ?';

  @override
  String get reminderDeleted => 'Rappel supprimé';

  @override
  String get areYouSureYouWantToDeleteTheReminder =>
      'Êtes-vous sûr de vouloir supprimer le rappel ?';

  @override
  String get dataSources => 'Sources de données';

  @override
  String get configureTheFloraCodexSettings =>
      'Configurer les paramètres de Flora Codex';

  @override
  String get insertTheFloraCodexApiKey => 'Saisir la clé API de Flora Codex';

  @override
  String get enterApiKey => 'Saisir la clé API';

  @override
  String get enableDataSource => 'Activer la source de données';

  @override
  String get apiKey => 'Clé API';

  @override
  String get notProvided => 'non fournie';

  @override
  String get appInfo => 'Informations sur l\'application';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get sourceCode => 'Code source';

  @override
  String get support => 'Soutenir ♥️';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get selectWeekdaysAndTimes => 'Sélectionner les jours et heures';

  @override
  String get pickTime => 'Choisir l\'heure';

  @override
  String get done => 'Terminé';

  @override
  String get aboutPlantIt => 'À propos de Plant-it';

  @override
  String get manageTheEventTypes => 'Gérer les types d\'événements';

  @override
  String get manageTheReminders => 'Gérer les rappels';

  @override
  String get manageTheDataSources => 'Gérer les sources de données';

  @override
  String get configureWhenAndIfNotificationsAreReceived =>
      'Configurer quand et si les notifications sont reçues';

  @override
  String get detailsAboutTheApp => 'Détails sur l\'application';

  @override
  String get yourSupportHelpsUsGrow => 'Votre soutien nous aide à grandir !';

  @override
  String get supportTheProject => 'Soutenir le projet';

  @override
  String get whySupportPlantIt => 'Pourquoi soutenir Plant-it ?';

  @override
  String get openSourceProjectThatBenefitsEveryone =>
      'Projet open-source qui profite à tous.';

  @override
  String get yourDonationsHelpUsImproveTheApp =>
      'Vos dons nous aident à améliorer l\'application.';

  @override
  String get supportNewFeaturesAndUpdates =>
      'Soutenir les nouvelles fonctionnalités et mises à jour.';

  @override
  String get donateNow => 'Faire un don maintenant';

  @override
  String get createSpecies => 'Créer une espèce';

  @override
  String get speciesCreated => 'Espèce créée';

  @override
  String get avatar => 'Avatar';

  @override
  String get noAvatar => 'Aucun avatar';

  @override
  String get uploadPhoto => 'Télécharger une photo';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get noPhoto => 'Aucune photo';

  @override
  String get useWebImage => 'Utiliser une image sur le web';

  @override
  String get url => 'URL';

  @override
  String get light => 'Lumière';

  @override
  String get humidity => 'Humidité';

  @override
  String get temperature => 'Température';

  @override
  String get ph => 'pH';

  @override
  String get genus => 'Genre';

  @override
  String get family => 'Famille';

  @override
  String get synonym => 'Synonyme';

  @override
  String get addSynonym => 'Ajouter un synonyme';

  @override
  String get classification => 'Classification';

  @override
  String get species => 'Espèce';

  @override
  String get synonyms => 'Synonymes';

  @override
  String get editSpecies => 'Modifier l\'espèce';

  @override
  String get speciesUpdated => 'Espèce mise à jour';

  @override
  String get addToCollection => 'Ajouter à la collection';

  @override
  String get showNextNotificationsDateTime =>
      'Afficher la date et l\'heure des prochaines notifications';

  @override
  String get date => 'Date';

  @override
  String get plant => 'Plante';

  @override
  String get low => 'Faible';

  @override
  String get medium => 'Moyen';

  @override
  String get high => 'Élevé';

  @override
  String get sunlight => 'Ensoleillement';

  @override
  String get min => 'min';

  @override
  String get max => 'max';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get color => 'Couleur';

  @override
  String get red => 'rouge';

  @override
  String get green => 'vert';

  @override
  String get blue => 'bleu';

  @override
  String get white => 'blanc';

  @override
  String get teal => 'turquoise';

  @override
  String get yellow => 'jaune';

  @override
  String get icon => 'Icône';

  @override
  String get every => 'Tous les';

  @override
  String get repeatAfter => 'Répéter';

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
        'days': 'jour',
        'months': 'mois',
        'weeks': 'semaine',
        'other': 'année',
      },
    );
    return 'Chaque$_temp0 $_temp1';
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
        'days': 'jour',
        'months': 'mois',
        'weeks': 'semaine',
        'other': 'année',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Après $quantityString $_temp0$_temp1';
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
        'days': 'jour',
        'months': 'mois',
        'weeks': 'semaine',
        'other': 'année',
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
  String get day => 'jour';

  @override
  String get week => 'semaine';

  @override
  String get month => 'mois';

  @override
  String get year => 'année';

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
        'days': 'jour',
        'months': 'mois',
        'weeks': 'semaine',
        'other': 'années',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      endDate,
      {
        'null': '',
        'other': ' jusqu\'au $endDate',
      },
    );
    return 'Chaque$_temp0 $_temp1 à partir du $startDateString$_temp2';
  }

  @override
  String get start => 'Début';

  @override
  String plantClassificationInfo(
      String name, String species, String genus, String family) {
    String _temp0 = intl.Intl.selectLogic(
      genus,
      {
        'null': '',
        'other': ', genre |$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': '',
        'other': ', famille |$family|',
      },
    );
    return '$name est une plante de l\'espèce |$species|$_temp0$_temp1.';
  }

  @override
  String speciesSynonyms(String synonyms, String species) {
    String _temp0 = intl.Intl.selectLogic(
      synonyms,
      {
        'null': '$species n\'a pas de synonymes',
        'other': '$species est aussi connu sous le nom de : $synonyms',
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
        'null': 'inconnu',
        'other': '|$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': 'inconnue',
        'other': '|$family|',
      },
    );
    return '$species est une espèce du genre $_temp0 et de la famille $_temp1.';
  }

  @override
  String get eventType => 'Type d\'événement';

  @override
  String get end => 'Fin';

  @override
  String get databaseAndCache => 'Base de données et cache';

  @override
  String get manageDatabaseAndCache =>
      'Gérer les paramètres de la base de données et du cache';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get cacheCleaned => 'Cache vidé';

  @override
  String get noSynonyms => 'Aucun synonyme connu';

  @override
  String get areYouSureYouWantToDeleteThisPlant =>
      'Êtes-vous sûr de vouloir supprimer cette plante ?';

  @override
  String get areYouSureYouWantToDeleteThisSpecies =>
      'Êtes-vous sûr de vouloir supprimer cette espèce et toutes les plantes associées ?';

  @override
  String get speciesDeleted => 'Espèce supprimée';

  @override
  String get noPlantsFound => 'Aucune plante trouvée';

  @override
  String get yourPlantWillAppearHere =>
      'Vos plantes apparaîtront ici une fois ajoutées à votre collection';

  @override
  String get howToAddPlants => 'Comment ajouter des plantes';

  @override
  String get addPlantInstruction =>
      'Cette application fonctionne avec des plantes de diverses espèces.\n\nVous pouvez ajouter une nouvelle plante en recherchant d\'abord l\'espèce (ou en en ajoutant une nouvelle), puis en liant une plante à celle-ci.\n\nPour commencer, recherchez une espèce.';

  @override
  String get searchASpecies => 'Rechercher une espèce';

  @override
  String get noSpeciesFound => 'Aucune espèce trouvée';

  @override
  String get searchAndAddSpeciesInstructions =>
      'Vous pouvez ajouter une nouvelle espèce, ou connecter l\'application à un service pour accéder à des espèces supplémentaires.';

  @override
  String get connectToAService => 'Connecter à un service';

  @override
  String get noInfoAvailable => 'Aucune information disponible';

  @override
  String get noReminder =>
      'Aucun rappel trouvé.\n\nCréez un nouveau rappel pour vos plantes afin de recevoir des notifications et voir les prochaines actions à effectuer.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

  @override
  String inTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'jour',
        'weeks': 'semaine',
        'months': 'mois',
        'other': 'année',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'dans $quantityString $_temp0$_temp1';
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
        'days': 'jour',
        'weeks': 'semaine',
        'months': 'mois',
        'other': 'année',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'il y a $quantityString $_temp0$_temp1';
  }

  @override
  String get additionalInfo => 'Informations supplémentaires';

  @override
  String get floraCodexDescription =>
      'FloraCodex est un service qui fournit l\'accès à une base de données complète d\'espèces végétales, incluant leurs noms scientifiques, noms communs et autres informations pertinentes. Pour utiliser ce service, vous devez obtenir une clé API.';

  @override
  String get floraCodexGetApiKey =>
      'Pour obtenir votre clé API, visitez le site web de FloraCodex, ou cliquez ici';

  @override
  String get reloadNotificationMessages =>
      'Recharger les messages de notification';

  @override
  String get notificationMessagesReloaded =>
      'Messages de notification rechargés, fermez et rouvrez l\'application';

  @override
  String get notificationTitle1 => 'Pas de rose sans épines !';

  @override
  String get notificationTitle2 => 'SOS Plante !';

  @override
  String get notificationTitle3 => 'Chuchote à l\'oreille des plantes !';

  @override
  String get notificationTitle4 => 'Pas aujourd\'hui, Plante !';

  @override
  String get notificationTitle5 => 'Mets du beurre dans les épinards !';

  @override
  String get notificationTitle6 => 'C\'est le bouquet !';

  @override
  String get notificationTitle7 => 'Ça sent le sapin !';

  @override
  String get notificationTitle8 => 'Ramène ta fraise !';

  @override
  String get notificationBody1 =>
      '|emoji| |plantName| se sent mi figue mi raisin sans son |eventType|...!';

  @override
  String get notificationBody2 =>
      '|emoji| La moutarde monte au nez de |plantName| qui attend son |eventType| !';

  @override
  String get notificationBody3 =>
      '|emoji| C\'est bête comme chou, |plantName| a besoin de son |eventType| !';

  @override
  String get notificationBody4 =>
      '|emoji| Sans |eventType|, |plantName| va manger les pissenlits par la racine !';

  @override
  String get notificationBody5 =>
      '|emoji| Reste pas planté comme un poireau, |plantName| attend son |eventType| !';

  @override
  String get notificationBody6 =>
      '|emoji| |plantName| file un mauvais côton sans |eventType| !';

  @override
  String get notificationBody7 =>
      '|emoji| |plantName| poireaute en attendant son |eventType|...';

  @override
  String get notificationBody8 =>
      '|emoji| C\'est la fin des haricots, |plantName| veut son |eventType| !';

  @override
  String get gbifDescription =>
      'GBIF (Global Biodiversity Information Facility) est une base de données ouverte et gratuite contenant les noms scientifiques et communs de toutes les espèces végétales. Aucune clé API n\'est nécessaire. Les photos proviennent d\'iNaturalist.';

  @override
  String get configureTheGbifSettings =>
      'Rechercher des plantes par nom scientifique ou commun, gratuit';

  @override
  String get configureThePlantNetSettings =>
      'Identifier les plantes à partir d\'une photo';

  @override
  String get plantNetDescription =>
      'Pl@ntNet identifie les plantes à partir d\'une ou plusieurs photos et relie chaque résultat à son espèce GBIF. L\'offre gratuite permet 500 identifications par jour. Pour l\'utiliser, vous avez besoin d\'une clé API gratuite.';

  @override
  String get plantNetGetApiKey =>
      'Pour obtenir votre clé API, inscrivez-vous sur le site de Pl@ntNet, ou cliquez ici';

  @override
  String get insertThePlantNetApiKey => 'Saisir la clé API de Pl@ntNet';

  @override
  String get configureTheOpenPlantbookSettings =>
      'Données d\'entretien : lumière, température et humidité';

  @override
  String get openPlantbookDescription =>
      'Open Plantbook est une base de données gratuite contenant les plages de lumière, de température et d\'humidité de milliers de plantes. Elle ne fournit pas le pH du sol. Pour l\'utiliser, vous avez besoin d\'un client ID et d\'un client secret gratuits.';

  @override
  String get openPlantbookGetCredentials =>
      'Pour obtenir vos identifiants, inscrivez-vous sur le site d\'Open Plantbook et créez un client API, ou cliquez ici';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client secret';

  @override
  String get aiCare => 'IA pour compléter l\'entretien';

  @override
  String get configureTheAiCareSettings =>
      'Estimer les valeurs d\'entretien qu\'aucune source ne fournit';

  @override
  String get aiCareDescription =>
      'Lorsqu\'une plante a des valeurs d\'entretien qu\'aucune source ne fournit (par exemple le pH du sol), un modèle d\'IA peut les estimer. Les valeurs estimées sont signalées sur la page de l\'espèce et peuvent être modifiées une fois la plante dans votre collection. Seul le nom scientifique de la plante est envoyé.';

  @override
  String get aiProvider => 'Fournisseur d\'IA';

  @override
  String get aiProviderNone => 'Aucun';

  @override
  String get aiProviderClaudeHint =>
      'Payant. Obtenez une clé API dans la Claude Console';

  @override
  String get aiProviderGeminiHint =>
      'Offre gratuite disponible. Obtenez une clé API dans Google AI Studio';

  @override
  String get aiProviderGitHubModelsHint =>
      'Gratuit avec limites. Utilisez un jeton GitHub avec l\'autorisation « Models »';

  @override
  String get getApiKeyClickHere => 'Pour obtenir votre clé, cliquez ici';

  @override
  String get aiModel => 'Modèle';

  @override
  String aiModelDefault(String model) {
    return 'Par défaut : $model';
  }

  @override
  String get insertTheAiModel =>
      'Modèle à utiliser (laisser vide pour le modèle par défaut)';

  @override
  String get identifyByPhoto => 'Identifier par photo';

  @override
  String get camera => 'Appareil photo';

  @override
  String get identifying => 'Identification de la plante...';

  @override
  String get photoIdentificationResults =>
      'Espèces les plus probables sur votre photo';

  @override
  String get noPlantIdentified =>
      'Aucune plante n\'a pu être identifiée sur la photo. Essayez une photo plus rapprochée d\'une feuille ou d\'une fleur.';

  @override
  String get plantNetKeyMissing =>
      'Pour identifier les plantes par photo, ajoutez votre clé API Pl@ntNet dans Paramètres > Sources de données.';

  @override
  String identificationConfidence(String percent) {
    return '$percent % de correspondance';
  }

  @override
  String careSources(String sources) {
    return 'Sources : $sources';
  }

  @override
  String aiEstimatedCare(String provider, String fields) {
    return 'Estimé par l\'IA ($provider) : $fields. Vérifiez ces valeurs et modifiez-les si nécessaire.';
  }

  @override
  String get notes => 'Notes';

  @override
  String get noNotesTapToAdd =>
      'Pas encore de notes. Touchez pour en écrire une.';

  @override
  String get editNotes => 'Modifier les notes';

  @override
  String get notesSaved => 'Notes enregistrées';

  @override
  String get editCare => 'Modifier l\'entretien';

  @override
  String get editCareSharedWarning =>
      'L\'entretien appartient à l\'espèce, la modification s\'applique donc aussi à vos autres plantes de cette espèce.';

  @override
  String get allEvents => 'Historique';

  @override
  String get noEventsYet => 'Pas encore d\'événements';

  @override
  String showAllEvents(String count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get showLess => 'Afficher moins';

  @override
  String get careFieldLightLux => 'Lumière (lux)';

  @override
  String get careFieldLightHours => 'Heures de lumière par jour';

  @override
  String get careFieldEnvHumidity => 'Humidité ambiante';

  @override
  String get careFieldWateringSummer => 'Arrosage en été';

  @override
  String get careFieldWateringWinter => 'Arrosage en hiver';

  @override
  String get careFieldSoilMoisture => 'Humidité du sol';

  @override
  String get careFieldConductivity => 'Conductivité (EC)';

  @override
  String get careFieldWaterType => 'Type d\'eau';

  @override
  String get careFieldWateringMethod => 'Méthode d\'arrosage';

  @override
  String get careFieldSubstrate => 'Substrat';

  @override
  String get careFieldFertilizer => 'Engrais';

  @override
  String get careFieldPruning => 'Taille';

  @override
  String get careFieldRepotting => 'Rempotage';

  @override
  String get careFieldFloweringSeason => 'Floraison';

  @override
  String get careFieldDormancySeason => 'Dormance';

  @override
  String get careFieldCommonPests => 'Ravageurs courants';

  @override
  String get careFieldDiseases => 'Maladies';

  @override
  String get careFieldToxicity => 'Toxicité';

  @override
  String everyNDays(String days) {
    return 'tous les $days jours';
  }

  @override
  String get editMoreCare => 'Modifier plus d\'entretien';

  @override
  String get careSaved => 'Entretien enregistré';

  @override
  String get careFields => 'Catégories d\'entretien';

  @override
  String get manageCareFields =>
      'Choisissez l\'entretien à afficher et créez le vôtre';

  @override
  String get careFieldsDescription =>
      'Les catégories activées sont affichées dans la section Entretien de chaque espèce et plante, dans cet ordre : faites-les glisser pour les réordonner et touchez une icône pour la changer. Les ravageurs et traitements d\'une plante précise sont enregistrés comme événements (types « pest » et « treatment ») dans son historique.';

  @override
  String get addCareField => 'Nouvelle catégorie';

  @override
  String get careFieldUnit => 'Unité (facultative)';

  @override
  String get careFieldOptions => 'Options, séparées par des virgules';

  @override
  String get careFieldType => 'Type';

  @override
  String get careFieldTypeNumber => 'Nombre';

  @override
  String get careFieldTypeRange => 'Plage (min - max)';

  @override
  String get careFieldTypeText => 'Texte';

  @override
  String get careFieldTypeChoice => 'Liste d\'options';

  @override
  String get customCareField => 'Créé par vous';

  @override
  String get areYouSureYouWantToDeleteThisCareField =>
      'Ses valeurs seront supprimées de toutes les espèces.';

  @override
  String get estimatedByAi => 'Estimé par l\'IA';

  @override
  String get noCareFieldsEnabled =>
      'Aucune catégorie d\'entretien activée. Activez-les dans Paramètres > Catégories d\'entretien.';

  @override
  String get basicCare => 'Entretien de base';

  @override
  String get careCategories => 'Catégories';

  @override
  String get notSet => 'Non défini';

  @override
  String get editDescription => 'Modifier la description';

  @override
  String get noDescription =>
      'Pas encore de description. Touchez pour l\'écrire ou la remplir automatiquement.';

  @override
  String get fillAutomatically => 'Remplir automatiquement';

  @override
  String get noDescriptionFound =>
      'Aucune description trouvée pour cette espèce.';

  @override
  String get descriptionSaved => 'Description enregistrée';

  @override
  String get descriptionSharedWarning =>
      'La description appartient à l\'espèce, elle est donc partagée par vos plantes de cette espèce.';

  @override
  String get changeIcon => 'Changer l\'icône';

  @override
  String get restoreDefaultIcon => 'Icône d\'origine';

  @override
  String get indoor => 'Intérieur';

  @override
  String get outdoor => 'Extérieur';

  @override
  String get weatherAndLocation => 'Météo et emplacement';

  @override
  String get manageWeather => 'Météo locale et saison pour vos plantes';

  @override
  String get weatherDescription =>
      'Votre emplacement sert à afficher la météo et la saison, mettre en avant l\'arrosage de la saison actuelle et vous avertir du gel, de la chaleur et de la pluie pour vos plantes d\'extérieur. La météo vient d\'Open-Meteo, qui ne reçoit que votre position approximative.';

  @override
  String get searchCity => 'Cherchez votre ville';

  @override
  String get useMyLocation => 'Utiliser ma position';

  @override
  String get myLocation => 'Ma position';

  @override
  String get noPlaceSet => 'Aucun emplacement';

  @override
  String get locationPermissionDenied =>
      'La position n\'est pas disponible. Autorisez-la dans les réglages du téléphone ou cherchez votre ville.';

  @override
  String get noPlacesFound => 'Aucun lieu trouvé';

  @override
  String get setUpWeather =>
      'Indiquez votre emplacement pour voir la météo et la saison';

  @override
  String get seasonSpring => 'Printemps';

  @override
  String get seasonSummer => 'Été';

  @override
  String get seasonAutumn => 'Automne';

  @override
  String get seasonWinter => 'Hiver';

  @override
  String get seasonDry => 'Saison sèche';

  @override
  String get seasonRainy => 'Saison des pluies';

  @override
  String humidityPercent(String humidity) {
    return '$humidity% d\'humidité';
  }

  @override
  String get weatherClear => 'Dégagé';

  @override
  String get weatherPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherCloudy => 'Nuageux';

  @override
  String get weatherFog => 'Brouillard';

  @override
  String get weatherDrizzle => 'Bruine';

  @override
  String get weatherRain => 'Pluie';

  @override
  String get weatherSnow => 'Neige';

  @override
  String get weatherStorm => 'Orage';

  @override
  String frostAlert(String day, String temperature, String plant, String min) {
    return '$day : jusqu\'à $temperature °C. $plant supporte au moins $min °C';
  }

  @override
  String heatAlert(String day, String temperature, String plant, String max) {
    return '$day : jusqu\'à $temperature °C. $plant supporte au plus $max °C';
  }

  @override
  String rainAlert(String plants) {
    return 'Il pleut aujourd\'hui : vous pouvez sauter l\'arrosage de $plants';
  }

  @override
  String get outdoorAlertsHint =>
      'Les alertes de gel, chaleur et pluie concernent les plantes dont l\'emplacement est Extérieur.';

  @override
  String get currentSeason => 'maintenant';

  @override
  String get forecast => 'Prévisions';

  @override
  String get changePlantImage => 'Changer l\'image';

  @override
  String get phoneGallery => 'Galerie du téléphone';

  @override
  String get speciesPhotosOnline => 'Photos de l\'espèce sur internet';

  @override
  String get fromLink => 'Depuis un lien';

  @override
  String get imageLink => 'Lien de l\'image (https://…)';

  @override
  String get useSpeciesImage => 'Utiliser l\'image de l\'espèce';

  @override
  String get imageUpdated => 'Image mise à jour';

  @override
  String get noPhotosFound => 'Aucune photo trouvée pour cette espèce';

  @override
  String get photosFromINaturalist =>
      'Photos partagées sur iNaturalist. Celle choisie est enregistrée avec les photos de la plante.';

  @override
  String suggestionsForPlant(String plant) {
    return 'Suggestions pour $plant';
  }

  @override
  String get suggestionsHint =>
      'Selon son entretien, la saison et son emplacement. Touchez-en une pour la créer.';

  @override
  String get noSuggestions =>
      'Aucune suggestion : ajoutez un entretien comme l\'arrosage ou l\'engrais sur la fiche de la plante.';

  @override
  String get suggestionWatering => 'Arrosage';

  @override
  String get suggestionFertilizing => 'Engrais';

  @override
  String get suggestionPruning => 'Taille';

  @override
  String get suggestionRepotting => 'Rempotage';

  @override
  String get suggestionPestCheck => 'Vérifier les ravageurs';

  @override
  String get suggestionMisting => 'Brumiser les feuilles';

  @override
  String get suggestionProtectFromCold => 'Protéger du froid';

  @override
  String get suggestionMoveOutdoors => 'Sortir à l\'extérieur';

  @override
  String get reasonWatering => 'Arrosage de la saison actuelle';

  @override
  String get reasonFertilizing => 'Pendant la saison de croissance';

  @override
  String get reasonPruning => 'À sa période de taille';

  @override
  String get reasonRepotting => 'Selon sa fréquence de rempotage';

  @override
  String get reasonPestCheck =>
      'Cherchez ses ravageurs habituels sur feuilles et tiges';

  @override
  String get reasonMisting => 'Elle a besoin d\'une humidité ambiante élevée';

  @override
  String get reasonProtectFromCold =>
      'Plante d\'extérieur qui ne supporte pas le froid de l\'hiver';

  @override
  String get reasonMoveOutdoors => 'Quand le beau temps revient';

  @override
  String everyCountDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count jours',
      one: 'tous les jours',
    );
    return '$_temp0';
  }

  @override
  String everyCountWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'toutes les $count semaines',
      one: 'toutes les semaines',
    );
    return '$_temp0';
  }

  @override
  String everyCountMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count mois',
      one: 'tous les mois',
    );
    return '$_temp0';
  }

  @override
  String everyCountYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count ans',
      one: 'tous les ans',
    );
    return '$_temp0';
  }

  @override
  String fromDate(String date) {
    return 'à partir du $date';
  }

  @override
  String untilDate(String date) {
    return 'jusqu\'au $date';
  }

  @override
  String protectFromRainAlert(
      String plant, String rain, String days, String watering) {
    return '$plant : pluie sur $rain des $days prochains jours, plus souvent que son arrosage (tous les $watering jours). Protégez-la de la pluie';
  }

  @override
  String get careFieldMistingEvery => 'Fréquence de brumisation';

  @override
  String get careFieldFertilizerEvery => 'Fréquence d\'engrais';

  @override
  String get careFieldPruningMonth => 'Mois de taille';

  @override
  String get careFieldRepottingYears => 'Fréquence de rempotage';

  @override
  String get careFieldRepottingMonth => 'Mois de rempotage';

  @override
  String get careFieldMonth => 'Mois';

  @override
  String get fillWithAi => 'Compléter avec l\'IA';

  @override
  String get fillWithAiHint =>
      'Remplit les catégories vides utilisées pour suggérer des rappels, marquées d\'une cloche, avec l\'IA ou les valeurs typiques du groupe de la plante. Vérifiez-les et enregistrez.';

  @override
  String get usedForSuggestions => 'Sert à suggérer des rappels';

  @override
  String aiFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valeurs remplies par l\'IA. Vérifiez-les et enregistrez.',
      one: '1 valeur remplie par l\'IA. Vérifiez-la et enregistrez.',
      zero: 'L\'IA n\'a pas donné de nouvelles valeurs',
    );
    return '$_temp0';
  }

  @override
  String get aiNotConfigured =>
      'Choisissez un fournisseur d\'IA et sa clé dans Paramètres > Sources de données';

  @override
  String get careFieldUnitYears => 'ans';

  @override
  String remindersToCreate(int count) {
    return '$count rappels seront créés, un par période';
  }

  @override
  String get plantGroupCacti => 'Cactus';

  @override
  String get plantGroupSucculents => 'Succulentes';

  @override
  String get plantGroupZamioculcas => 'Zamioculcas';

  @override
  String get plantGroupAroids => 'Aracées';

  @override
  String get plantGroupFerns => 'Fougères';

  @override
  String get plantGroupOrchids => 'Orchidées';

  @override
  String get plantGroupAirPlants => 'Filles de l\'air';

  @override
  String get plantGroupBromeliads => 'Broméliacées';

  @override
  String get plantGroupPalms => 'Palmiers';

  @override
  String get plantGroupPrayerPlants => 'Marantas et calatheas';

  @override
  String get plantGroupFicus => 'Ficus';

  @override
  String get plantGroupDracaenas => 'Dracaenas et apparentées';

  @override
  String get plantGroupHerbs => 'Herbes aromatiques';

  @override
  String get plantGroupRoses => 'Rosiers';

  @override
  String get plantGroupBegonias => 'Bégonias';

  @override
  String get plantGroupGesneriads => 'Violettes africaines et apparentées';

  @override
  String get plantGroupCitrus => 'Agrumes';

  @override
  String get plantGroupCarnivorous => 'Plantes carnivores';

  @override
  String get careFieldFloweringMonths => 'Mois de floraison';

  @override
  String get careFieldDormancyMonths => 'Mois de repos';

  @override
  String typicalCareSource(String group) {
    return 'Valeurs typiques de $group';
  }

  @override
  String typicalValueOf(String group) {
    return 'Valeur typique de $group';
  }

  @override
  String fillWithGroup(String group) {
    return 'Valeurs typiques : $group';
  }

  @override
  String groupFilledValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valeurs typiques remplies. Vérifiez-les et enregistrez.',
      one: '1 valeur typique remplie. Vérifiez-la et enregistrez.',
      zero: 'Aucune catégorie vide à remplir',
    );
    return '$_temp0';
  }

  @override
  String get periodDormancy => 'Repos';

  @override
  String get createEventOrReminder => 'Que voulez-vous créer ?';

  @override
  String get createEventHint => 'Enregistrez un soin déjà fait';

  @override
  String get createReminderHint => 'Recevez un rappel pour un soin';

  @override
  String get plantCollections => 'Groupes';

  @override
  String get allPlants => 'Toutes';

  @override
  String get newCollection => 'Nouveau groupe';

  @override
  String get collectionName => 'Nom du groupe';

  @override
  String get renameCollection => 'Renommer';

  @override
  String get choosePlants => 'Choisir des plantes';

  @override
  String get deleteCollection => 'Supprimer le groupe';

  @override
  String deleteCollectionConfirm(String name) {
    return 'Supprimer le groupe $name ? Ses plantes sont conservées.';
  }

  @override
  String get emptyCollection =>
      'Pas encore de plantes dans ce groupe. Appuyez longuement pour les choisir.';

  @override
  String get noCollectionsYet =>
      'Pas encore de groupes : créez-en un pour classer vos plantes.';

  @override
  String get swipeToDismiss => 'Balayez une alerte pour l\'ignorer';

  @override
  String get ungroupedPlants => 'Sans groupe';

  @override
  String get perPlantSuggestions =>
      'Utiliser la fréquence suggérée pour chaque plante';

  @override
  String perPlantSuggestionsHint(String group) {
    return 'Un rappel sera créé pour chaque plante de $group. Les plantes sans suggestion utiliseront les valeurs du résumé.';
  }

  @override
  String remindersForGroup(String group) {
    return 'Un rappel sera créé pour chaque plante de $group, avec les valeurs du résumé.';
  }

  @override
  String suggestedForPlants(int count, int total) {
    return 'Suggéré pour $count sur $total';
  }

  @override
  String get rainPoint => 'Capteurs RainPoint';

  @override
  String get rainPointSubtitle =>
      'Humidité du sol et arrosages de vos appareils';

  @override
  String get rainPointHint =>
      'Lit l\'humidité du sol de vos capteurs RainPoint et enregistre les arrosages de vos programmateurs. Utilise le cloud RainPoint via une API non officielle, qui peut cesser de fonctionner si RainPoint la modifie.';

  @override
  String get rainPointSessionWarning =>
      'La connexion ferme la session de l\'app RainPoint sur vos autres appareils. Pour l\'éviter, créez un second compte et invitez-le dans votre maison depuis l\'app.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordKeep => 'Laissez vide pour garder celui enregistré';

  @override
  String get countryCode => 'Indicatif téléphonique du pays (ex. 33)';

  @override
  String get rainPointAppLabel => 'Compte de l\'app';

  @override
  String get connect => 'Connecter';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get refresh => 'Actualiser';

  @override
  String get devices => 'Appareils';

  @override
  String get noRainPointDevices => 'Aucun capteur ni programmateur trouvé';

  @override
  String linkedPlants(String plants) {
    return 'Plantes : $plants';
  }

  @override
  String get linkPlantsHint => 'Touchez pour lier des plantes';

  @override
  String soilMoistureValue(String value) {
    return 'Humidité du sol $value %';
  }

  @override
  String get wateringNow => 'Arrosage en cours';

  @override
  String lastWatering(String date, String liters) {
    return 'Dernier arrosage : $date · $liters l';
  }

  @override
  String get lowBattery => 'batterie faible';

  @override
  String get noReading => 'Pas encore de mesure';

  @override
  String get sensors => 'Capteurs';

  @override
  String drySoilAlert(String plant, String value, String min) {
    return '$plant : humidité du sol $value % (min. $min %). Il faut arroser.';
  }

  @override
  String rainPointWateringsRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arrosages enregistrés depuis RainPoint',
      one: '1 arrosage enregistré depuis RainPoint',
    );
    return '$_temp0';
  }
}
