// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get searchYourPlants => 'Buscar tus plantas';

  @override
  String get filterActivities => 'Filtrar actividades';

  @override
  String get filter => 'Filtrar';

  @override
  String get eventTypes => 'Tipos de eventos';

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
    return '$countString tipo$_temp0 de evento$_temp1';
  }

  @override
  String get whichEventsYouWantToAdd => '¿Qué eventos quieres añadir?';

  @override
  String get plants => 'Plantas';

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
    return '$countString planta$_temp0';
  }

  @override
  String get whichPlantsYouWantToAdd => '¿Qué plantas quieres añadir?';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get areYouSureYouWantToDeleteThisEvent =>
      '¿Estás seguro de que quieres eliminar este evento?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get eventDeleted => 'Evento eliminado';

  @override
  String get edit => 'Editar';

  @override
  String get eventCreated => 'Evento creado';

  @override
  String get markDone => 'Marcar como completado';

  @override
  String get reminder => 'Recordatorio';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get confirm => 'Confirmar';

  @override
  String get createEvent => 'Crear evento';

  @override
  String get create => 'Crear';

  @override
  String get eventsCreated => 'Eventos creados';

  @override
  String get save => 'Guardar';

  @override
  String get editTheEvent => 'Editar el evento';

  @override
  String get eventUpdated => 'Evento actualizado';

  @override
  String get selectTheEventType => 'Seleccionar el tipo de evento';

  @override
  String get selectThePlant => 'Seleccionar la planta';

  @override
  String get nextActions => 'Próximas acciones';

  @override
  String get home => 'Inicio';

  @override
  String get calendar => 'Calendario';

  @override
  String get search => 'Buscar';

  @override
  String get more => 'Más';

  @override
  String get addPlant => 'Añadir planta';

  @override
  String get add => 'Añadir';

  @override
  String get plantAdded => 'Planta añadida';

  @override
  String get location => 'Ubicación';

  @override
  String get name => 'Nombre';

  @override
  String get price => 'Precio';

  @override
  String get editPlant => 'Editar planta';

  @override
  String get plantUpdated => 'Planta actualizada';

  @override
  String get deleteImage => 'Eliminar imagen';

  @override
  String get areYouSureYouWantToDeleteThisImage =>
      '¿Estás seguro de que quieres eliminar esta imagen?';

  @override
  String get info => 'Info';

  @override
  String get imageInfo => 'Información de la imagen';

  @override
  String get ok => 'Ok';

  @override
  String get download => 'Descargar';

  @override
  String get unsetAsAvatar => 'Quitar como avatar';

  @override
  String get setAsAvatar => 'Establecer como avatar';

  @override
  String get information => 'Información';

  @override
  String get care => 'Cuidados';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get events => 'Eventos';

  @override
  String get gallery => 'Galería';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get plantDuplicated => 'Planta duplicada';

  @override
  String get plantDeleted => 'Planta eliminada';

  @override
  String get searchGreenFriends => 'Buscar amigos verdes';

  @override
  String get note => 'Nota';

  @override
  String get update => 'Actualizar';

  @override
  String get custom => 'personalizado';

  @override
  String get floraCodex => 'Flora Codex';

  @override
  String get seller => 'Vendedor';

  @override
  String get remove => 'Quitar';

  @override
  String get createEventType => 'Crear tipo de evento';

  @override
  String get selectAColor => 'Seleccionar un color';

  @override
  String get select => 'Seleccionar';

  @override
  String get whichColorYouWantToUse => '¿Qué color quieres usar?';

  @override
  String get description => 'Descripción';

  @override
  String get whichIconYouWantToUse => '¿Qué icono quieres usar?';

  @override
  String get filterIcons => 'Filtrar iconos';

  @override
  String get insertAName => 'Introduce un nombre';

  @override
  String get editEventType => 'Editar tipo de evento';

  @override
  String get eventTypeUpdated => 'Tipo de evento actualizado';

  @override
  String get areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents =>
      '¿Estás seguro de que quieres eliminar el tipo de evento y todos los eventos asociados?';

  @override
  String get eventTypeDeleted => 'Tipo de evento eliminado';

  @override
  String get createReminder => 'Crear recordatorio';

  @override
  String get reminderCreated => 'Recordatorio creado';

  @override
  String get whichEventTypeYouWantToSet =>
      '¿Qué tipo de evento quieres configurar?';

  @override
  String get quantity => 'Cantidad';

  @override
  String get whichPlantsYouWantToSet => '¿Qué planta quieres configurar?';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get reminderUpdated => 'Recordatorio actualizado';

  @override
  String get whichEventsYouWantToSet => '¿Qué eventos quieres configurar?';

  @override
  String get reminderDeleted => 'Recordatorio eliminado';

  @override
  String get areYouSureYouWantToDeleteTheReminder =>
      '¿Estás seguro de que quieres eliminar el recordatorio?';

  @override
  String get dataSources => 'Fuentes de datos';

  @override
  String get configureTheFloraCodexSettings =>
      'Configurar los ajustes de Flora Codex';

  @override
  String get insertTheFloraCodexApiKey =>
      'Introduce la clave API de Flora Codex';

  @override
  String get enterApiKey => 'Introduce la clave API';

  @override
  String get enableDataSource => 'Activar la fuente de datos';

  @override
  String get apiKey => 'Clave API';

  @override
  String get notProvided => 'no proporcionada';

  @override
  String get appInfo => 'Información de la app';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get support => 'Apoyar ♥️';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get selectWeekdaysAndTimes => 'Seleccionar días y horas';

  @override
  String get pickTime => 'Elegir hora';

  @override
  String get done => 'Hecho';

  @override
  String get aboutPlantIt => 'Acerca de Plant-it';

  @override
  String get manageTheEventTypes => 'Gestionar los tipos de eventos';

  @override
  String get manageTheReminders => 'Gestionar los recordatorios';

  @override
  String get manageTheDataSources => 'Gestionar las fuentes de datos';

  @override
  String get configureWhenAndIfNotificationsAreReceived =>
      'Configurar cuándo y si se reciben notificaciones';

  @override
  String get detailsAboutTheApp => 'Detalles sobre la app';

  @override
  String get yourSupportHelpsUsGrow => '¡Tu apoyo nos ayuda a crecer!';

  @override
  String get supportTheProject => 'Apoyar el proyecto';

  @override
  String get whySupportPlantIt => '¿Por qué apoyar Plant-it?';

  @override
  String get openSourceProjectThatBenefitsEveryone =>
      'Proyecto de código abierto que beneficia a todos.';

  @override
  String get yourDonationsHelpUsImproveTheApp =>
      'Tus donaciones nos ayudan a mejorar la app.';

  @override
  String get supportNewFeaturesAndUpdates =>
      'Apoya nuevas funciones y actualizaciones.';

  @override
  String get donateNow => 'Donar ahora';

  @override
  String get createSpecies => 'Crear especie';

  @override
  String get speciesCreated => 'Especie creada';

  @override
  String get avatar => 'Avatar';

  @override
  String get noAvatar => 'Sin avatar';

  @override
  String get uploadPhoto => 'Subir foto';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get noPhoto => 'Sin foto';

  @override
  String get useWebImage => 'Usar imagen de la web';

  @override
  String get url => 'Url';

  @override
  String get light => 'Luz';

  @override
  String get humidity => 'Humedad';

  @override
  String get temperature => 'Temperatura';

  @override
  String get ph => 'pH';

  @override
  String get genus => 'Género';

  @override
  String get family => 'Familia';

  @override
  String get synonym => 'Sinónimo';

  @override
  String get addSynonym => 'Añadir sinónimo';

  @override
  String get classification => 'Clasificación';

  @override
  String get species => 'Especie';

  @override
  String get synonyms => 'Sinónimos';

  @override
  String get editSpecies => 'Editar especie';

  @override
  String get speciesUpdated => 'Especie actualizada';

  @override
  String get addToCollection => 'Añadir a la colección';

  @override
  String get showNextNotificationsDateTime =>
      'Mostrar fecha y hora de las próximas notificaciones';

  @override
  String get date => 'Fecha';

  @override
  String get plant => 'Planta';

  @override
  String get low => 'Bajo';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get sunlight => 'Luz solar';

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
  String get red => 'rojo';

  @override
  String get green => 'verde';

  @override
  String get blue => 'azul';

  @override
  String get white => 'blanco';

  @override
  String get teal => 'verde azulado';

  @override
  String get yellow => 'amarillo';

  @override
  String get icon => 'Icono';

  @override
  String get every => 'Cada';

  @override
  String get repeatAfter => 'Repetir después de';

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
        'days': 'día',
        'months': 'mes',
        'weeks': 'semana',
        'other': 'año',
      },
    );
    String _temp2 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Cada$_temp0 $_temp1$_temp2';
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
        'days': 'día',
        'months': 'mes',
        'weeks': 'semana',
        'other': 'año',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Después de $quantityString $_temp0$_temp1';
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
        'days': 'día',
        'months': 'mes',
        'weeks': 'semana',
        'other': 'año',
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
  String get day => 'día';

  @override
  String get week => 'semana';

  @override
  String get month => 'mes';

  @override
  String get year => 'año';

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
        'days': 'día',
        'months': 'mes',
        'weeks': 'semana',
        'other': 'año',
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
        'other': ' hasta $endDate',
      },
    );
    return 'Cada$_temp0 $_temp1$_temp2 desde $startDateString$_temp3';
  }

  @override
  String get start => 'Inicio';

  @override
  String plantClassificationInfo(
      String name, String species, String genus, String family) {
    String _temp0 = intl.Intl.selectLogic(
      genus,
      {
        'null': '',
        'other': ', género |$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': '',
        'other': ', familia |$family|',
      },
    );
    return '$name es una planta de la especie |$species|$_temp0$_temp1.';
  }

  @override
  String speciesSynonyms(String synonyms, String species) {
    String _temp0 = intl.Intl.selectLogic(
      synonyms,
      {
        'null': '$species no tiene sinónimos',
        'other': '$species también se conoce como: $synonyms',
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
        'null': 'desconocido',
        'other': '|$genus|',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      family,
      {
        'null': 'desconocida',
        'other': '|$family|',
      },
    );
    return '$species es una especie del género $_temp0 y de la familia $_temp1.';
  }

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get end => 'Fin';

  @override
  String get databaseAndCache => 'Base de datos y caché';

  @override
  String get manageDatabaseAndCache =>
      'Gestionar los ajustes de la base de datos y la caché';

  @override
  String get clearCache => 'Vaciar caché';

  @override
  String get cacheCleaned => 'Caché vaciada';

  @override
  String get noSynonyms => 'Sin sinónimos conocidos';

  @override
  String get areYouSureYouWantToDeleteThisPlant =>
      '¿Estás seguro de que quieres eliminar esta planta?';

  @override
  String get areYouSureYouWantToDeleteThisSpecies =>
      '¿Estás seguro de que quieres eliminar esta especie y todas las plantas asociadas?';

  @override
  String get speciesDeleted => 'Especie eliminada';

  @override
  String get noPlantsFound => 'No se han encontrado plantas';

  @override
  String get yourPlantWillAppearHere =>
      'Tus plantas aparecerán aquí cuando las añadas a tu colección';

  @override
  String get howToAddPlants => 'Cómo añadir plantas';

  @override
  String get addPlantInstruction =>
      'Esta app funciona con plantas de distintas especies.\n\nPuedes añadir una nueva planta buscando primero la especie (o añadiendo una nueva) y luego vinculando una planta a ella.\n\nPara empezar, busca una especie.';

  @override
  String get searchASpecies => 'Buscar una especie';

  @override
  String get noSpeciesFound => 'No se han encontrado especies';

  @override
  String get searchAndAddSpeciesInstructions =>
      'Puedes añadir una nueva especie o conectar la app a un servicio para acceder a más especies.';

  @override
  String get connectToAService => 'Conectar a un servicio';

  @override
  String get noInfoAvailable => 'No hay información disponible';

  @override
  String get noReminder =>
      'No se ha encontrado ningún recordatorio.\n\nCrea un nuevo recordatorio para tus plantas para recibir notificaciones y ver las próximas acciones que debes realizar.';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get yesterday => 'Ayer';

  @override
  String inTime(num quantity, String unit) {
    final intl.NumberFormat quantityNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String quantityString = quantityNumberFormat.format(quantity);

    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'days': 'día',
        'weeks': 'semana',
        'months': 'mes',
        'other': 'año',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'en $quantityString $_temp0$_temp1';
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
        'days': 'día',
        'weeks': 'semana',
        'months': 'mes',
        'other': 'año',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'hace $quantityString $_temp0$_temp1';
  }

  @override
  String get additionalInfo => 'Información adicional';

  @override
  String get floraCodexDescription =>
      'FloraCodex es un servicio que proporciona acceso a una base de datos completa de especies de plantas, incluidos sus nombres científicos, nombres comunes y otra información relevante. Para utilizar este servicio, necesitas obtener una clave API.';

  @override
  String get floraCodexGetApiKey =>
      'Para obtener tu clave API, visita la web de FloraCodex o haz clic aquí';

  @override
  String get reloadNotificationMessages =>
      'Recargar los mensajes de notificación';

  @override
  String get notificationMessagesReloaded =>
      'Mensajes de notificación recargados, cierra y vuelve a abrir la app';

  @override
  String get notificationTitle1 => '¡Uy, lo has vuelto a hacer!';

  @override
  String get notificationTitle2 => '¡SOS Planta!';

  @override
  String get notificationTitle3 => '¡Hora de ser un susurrador de plantas!';

  @override
  String get notificationTitle4 => '¡Hoy no, planta!';

  @override
  String get notificationTitle5 => '¡Se necesita cafeína para plantas!';

  @override
  String get notificationTitle6 => '¡La planta está llamando!';

  @override
  String get notificationTitle7 => '¡Llama al escuadrón verde!';

  @override
  String get notificationTitle8 => 'Has dejado la planta «en visto»';

  @override
  String get notificationBody1 =>
      '|emoji| |plantName| necesita su |eventType|. ¡No la hagas esperar!';

  @override
  String get notificationBody2 =>
      '|emoji| |plantName| está pidiendo su |eventType|. ¡Es hora de salvarla!';

  @override
  String get notificationBody3 =>
      '|emoji| |plantName| necesita |eventType|. ¡Te está esperando!';

  @override
  String get notificationBody4 =>
      '|emoji| |plantName| está cansada de esperar su |eventType|. ¡Dale un poco de cariño!';

  @override
  String get notificationBody5 =>
      '|emoji| |plantName| lleva retraso con su |eventType|. ¡Dale un empujón!';

  @override
  String get notificationBody6 =>
      '|emoji| |plantName| está lista para su |eventType|. ¡No la defraudes!';

  @override
  String get notificationBody7 =>
      '|emoji| |plantName| necesita su |eventType|. ¡Eres el héroe que se merece!';

  @override
  String get notificationBody8 =>
      '|emoji| |plantName| echa de menos su |eventType|. ¡Es hora de hacerla feliz de nuevo!';

  @override
  String get gbifDescription =>
      'GBIF (Global Biodiversity Information Facility) es una base de datos abierta y gratuita con los nombres científicos y comunes de todas las especies de plantas. No necesita clave API. Las fotos se obtienen de iNaturalist.';

  @override
  String get configureTheGbifSettings =>
      'Busca plantas por nombre científico o común, gratis';

  @override
  String get configureThePlantNetSettings =>
      'Identifica plantas a partir de una foto';

  @override
  String get plantNetDescription =>
      'Pl@ntNet identifica plantas a partir de una o varias fotos y enlaza cada resultado con su especie de GBIF. El plan gratuito permite 500 identificaciones al día. Para usarlo necesitas una clave API gratuita.';

  @override
  String get plantNetGetApiKey =>
      'Para obtener tu clave API, regístrate en la web de Pl@ntNet o haz clic aquí';

  @override
  String get insertThePlantNetApiKey => 'Introduce la clave API de Pl@ntNet';

  @override
  String get configureTheOpenPlantbookSettings =>
      'Datos de cuidado: luz, temperatura y humedad';

  @override
  String get openPlantbookDescription =>
      'Open Plantbook es una base de datos gratuita con los rangos de luz, temperatura y humedad de miles de plantas. No incluye el pH del suelo. Para usarla necesitas un client ID y un client secret gratuitos.';

  @override
  String get openPlantbookGetCredentials =>
      'Para obtener tus credenciales, regístrate en la web de Open Plantbook y crea un cliente API, o haz clic aquí';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client secret';

  @override
  String get aiCare => 'IA para completar cuidados';

  @override
  String get configureTheAiCareSettings =>
      'Estima los cuidados que ninguna fuente proporciona';

  @override
  String get aiCareDescription =>
      'Cuando una planta tiene cuidados que ninguna fuente proporciona (por ejemplo, el pH del suelo), un modelo de IA puede estimarlos. Los valores estimados aparecen marcados en la ficha de la especie y se pueden editar cuando la planta está en tu colección. Solo se envía el nombre científico de la planta.';

  @override
  String get aiProvider => 'Proveedor de IA';

  @override
  String get aiProviderNone => 'Ninguno';

  @override
  String get aiProviderClaudeHint =>
      'De pago. Consigue una clave API en la Claude Console';

  @override
  String get aiProviderGeminiHint =>
      'Tiene nivel gratuito. Consigue una clave API en Google AI Studio';

  @override
  String get aiProviderGitHubModelsHint =>
      'Gratis con límites. Usa un token de GitHub con el permiso \"Models\"';

  @override
  String get getApiKeyClickHere => 'Para obtener tu clave, haz clic aquí';

  @override
  String get aiModel => 'Modelo';

  @override
  String aiModelDefault(String model) {
    return 'Por defecto: $model';
  }

  @override
  String get insertTheAiModel =>
      'Modelo a usar (déjalo vacío para usar el predeterminado)';

  @override
  String get identifyByPhoto => 'Identificar por foto';

  @override
  String get camera => 'Cámara';

  @override
  String get identifying => 'Identificando la planta...';

  @override
  String get photoIdentificationResults => 'Especies más probables de tu foto';

  @override
  String get noPlantIdentified =>
      'No se ha podido identificar ninguna planta en la foto. Prueba con una foto más cercana de una hoja o una flor.';

  @override
  String get plantNetKeyMissing =>
      'Para identificar plantas por foto, añade tu clave API de Pl@ntNet en Ajustes > Fuentes de datos.';

  @override
  String identificationConfidence(String percent) {
    return '$percent% de coincidencia';
  }

  @override
  String careSources(String sources) {
    return 'Fuentes: $sources';
  }

  @override
  String aiEstimatedCare(String provider, String fields) {
    return 'Estimado por IA ($provider): $fields. Revisa estos valores y edítalos si hace falta.';
  }

  @override
  String get notes => 'Notas';

  @override
  String get noNotesTapToAdd => 'Aún no hay notas. Toca para escribir una.';

  @override
  String get editNotes => 'Editar notas';

  @override
  String get notesSaved => 'Notas guardadas';

  @override
  String get editCare => 'Editar cuidados';

  @override
  String get editCareSharedWarning =>
      'Los cuidados pertenecen a la especie, así que el cambio también se aplica a tus otras plantas de esta especie.';

  @override
  String get allEvents => 'Historial';

  @override
  String get noEventsYet => 'Aún no hay eventos';

  @override
  String showAllEvents(String count) {
    return 'Ver todos ($count)';
  }

  @override
  String get showLess => 'Ver menos';

  @override
  String get careFieldLightLux => 'Luz (lux)';

  @override
  String get careFieldLightHours => 'Horas de luz al día';

  @override
  String get careFieldEnvHumidity => 'Humedad ambiente';

  @override
  String get careFieldWateringSummer => 'Riego en verano';

  @override
  String get careFieldWateringWinter => 'Riego en invierno';

  @override
  String get careFieldSoilMoisture => 'Humedad del suelo';

  @override
  String get careFieldConductivity => 'Conductividad (EC)';

  @override
  String get careFieldWaterType => 'Tipo de agua';

  @override
  String get careFieldWateringMethod => 'Método de riego';

  @override
  String get careFieldSubstrate => 'Sustrato';

  @override
  String get careFieldFertilizer => 'Abono';

  @override
  String get careFieldPruning => 'Poda';

  @override
  String get careFieldRepotting => 'Trasplante';

  @override
  String get careFieldFloweringSeason => 'Floración';

  @override
  String get careFieldDormancySeason => 'Reposo';

  @override
  String get careFieldCommonPests => 'Plagas habituales';

  @override
  String get careFieldDiseases => 'Enfermedades';

  @override
  String get careFieldToxicity => 'Toxicidad';

  @override
  String everyNDays(String days) {
    return 'cada $days días';
  }

  @override
  String get editMoreCare => 'Editar más cuidados';

  @override
  String get careSaved => 'Cuidados guardados';

  @override
  String get careFields => 'Categorías de cuidado';

  @override
  String get manageCareFields => 'Elige qué cuidados mostrar y crea los tuyos';

  @override
  String get careFieldsDescription =>
      'Las categorías activadas se muestran en la sección Cuidados de todas las especies y plantas, en este orden: arrástralas para reordenarlas y toca un icono para cambiarlo. Las plagas y tratamientos de una planta concreta se registran como eventos (tipos \"pest\" y \"treatment\") en su historial.';

  @override
  String get addCareField => 'Nueva categoría';

  @override
  String get careFieldUnit => 'Unidad (opcional)';

  @override
  String get careFieldOptions => 'Opciones, separadas por comas';

  @override
  String get careFieldType => 'Tipo';

  @override
  String get careFieldTypeNumber => 'Número';

  @override
  String get careFieldTypeRange => 'Rango (mín. - máx.)';

  @override
  String get careFieldTypeText => 'Texto';

  @override
  String get careFieldTypeChoice => 'Lista de opciones';

  @override
  String get customCareField => 'Creado por ti';

  @override
  String get areYouSureYouWantToDeleteThisCareField =>
      'Se borrarán sus valores en todas las especies.';

  @override
  String get estimatedByAi => 'Estimado por IA';

  @override
  String get noCareFieldsEnabled =>
      'No hay categorías de cuidado activadas. Actívalas en Ajustes > Categorías de cuidado.';

  @override
  String get basicCare => 'Cuidados básicos';

  @override
  String get careCategories => 'Categorías';

  @override
  String get notSet => 'Sin definir';

  @override
  String get editDescription => 'Editar descripción';

  @override
  String get noDescription =>
      'Aún no hay descripción. Toca para escribirla o rellenarla automáticamente.';

  @override
  String get fillAutomatically => 'Rellenar automáticamente';

  @override
  String get noDescriptionFound =>
      'No se ha encontrado ninguna descripción para esta especie.';

  @override
  String get descriptionSaved => 'Descripción guardada';

  @override
  String get descriptionSharedWarning =>
      'La descripción pertenece a la especie, así que la comparten tus plantas de esta especie.';

  @override
  String get changeIcon => 'Cambiar icono';

  @override
  String get restoreDefaultIcon => 'Icono original';

  @override
  String get indoor => 'Interior';

  @override
  String get outdoor => 'Exterior';

  @override
  String get weatherAndLocation => 'Clima y ubicación';

  @override
  String get manageWeather => 'Clima local y estación para tus plantas';

  @override
  String get weatherDescription =>
      'Tu ubicación se usa para mostrar el clima y la estación, destacar el riego de la estación actual y avisarte de heladas, calor y lluvia para tus plantas de exterior. El clima viene de Open-Meteo, que solo recibe tu ubicación aproximada.';

  @override
  String get searchCity => 'Busca tu ciudad';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get myLocation => 'Mi ubicación';

  @override
  String get noPlaceSet => 'Sin ubicación';

  @override
  String get locationPermissionDenied =>
      'La ubicación no está disponible. Permítela en los ajustes del móvil o busca tu ciudad.';

  @override
  String get noPlacesFound => 'No se ha encontrado ningún lugar';

  @override
  String get setUpWeather =>
      'Indica tu ubicación para ver el clima y la estación';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verano';

  @override
  String get seasonAutumn => 'Otoño';

  @override
  String get seasonWinter => 'Invierno';

  @override
  String get seasonDry => 'Estación seca';

  @override
  String get seasonRainy => 'Estación lluviosa';

  @override
  String humidityPercent(String humidity) {
    return '$humidity% humedad';
  }

  @override
  String get weatherClear => 'Despejado';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get weatherFog => 'Niebla';

  @override
  String get weatherDrizzle => 'Llovizna';

  @override
  String get weatherRain => 'Lluvia';

  @override
  String get weatherSnow => 'Nieve';

  @override
  String get weatherStorm => 'Tormenta';

  @override
  String frostAlert(String day, String temperature, String plant, String min) {
    return '$day: hasta $temperature °C. $plant aguanta mínimo $min °C';
  }

  @override
  String heatAlert(String day, String temperature, String plant, String max) {
    return '$day: hasta $temperature °C. $plant aguanta máximo $max °C';
  }

  @override
  String rainAlert(String plants) {
    return 'Hoy llueve: puedes saltarte el riego de $plants';
  }

  @override
  String get outdoorAlertsHint =>
      'Los avisos de helada, calor y lluvia se muestran para las plantas con ubicación Exterior.';

  @override
  String get currentSeason => 'ahora';

  @override
  String get forecast => 'Pronóstico';

  @override
  String get changePlantImage => 'Cambiar imagen';

  @override
  String get phoneGallery => 'Galería del móvil';

  @override
  String get speciesPhotosOnline => 'Fotos de la especie en internet';

  @override
  String get fromLink => 'Desde un enlace';

  @override
  String get imageLink => 'Enlace de la imagen (https://…)';

  @override
  String get useSpeciesImage => 'Usar la imagen de la especie';

  @override
  String get imageUpdated => 'Imagen actualizada';

  @override
  String get noPhotosFound => 'No se han encontrado fotos de esta especie';

  @override
  String get photosFromINaturalist =>
      'Fotos compartidas en iNaturalist. La que elijas se guarda con las fotos de la planta.';
}
