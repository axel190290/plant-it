import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @searchYourPlants.
  ///
  /// In en, this message translates to:
  /// **'Search your plants'**
  String get searchYourPlants;

  /// No description provided for @filterActivities.
  ///
  /// In en, this message translates to:
  /// **'Filter Activities'**
  String get filterActivities;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @eventTypes.
  ///
  /// In en, this message translates to:
  /// **'Event Types'**
  String get eventTypes;

  /// A plural event type message
  ///
  /// In en, this message translates to:
  /// **'{count} event type{count, plural, =1 {} other {s}}'**
  String nEventTypes(num count);

  /// No description provided for @whichEventsYouWantToAdd.
  ///
  /// In en, this message translates to:
  /// **'Which events you want to add?'**
  String get whichEventsYouWantToAdd;

  /// No description provided for @plants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get plants;

  /// A plural plant message
  ///
  /// In en, this message translates to:
  /// **'{count} plant{count, plural, =1 {} other {s}}'**
  String nPlants(num count);

  /// No description provided for @whichPlantsYouWantToAdd.
  ///
  /// In en, this message translates to:
  /// **'Which plants you want to add?'**
  String get whichPlantsYouWantToAdd;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSureYouWantToDeleteThisEvent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event?'**
  String get areYouSureYouWantToDeleteThisEvent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted'**
  String get eventDeleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get eventCreated;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @eventsCreated.
  ///
  /// In en, this message translates to:
  /// **'Events created'**
  String get eventsCreated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editTheEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit the event'**
  String get editTheEvent;

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated'**
  String get eventUpdated;

  /// No description provided for @selectTheEventType.
  ///
  /// In en, this message translates to:
  /// **'Select the event type'**
  String get selectTheEventType;

  /// No description provided for @selectThePlant.
  ///
  /// In en, this message translates to:
  /// **'Select the plant'**
  String get selectThePlant;

  /// No description provided for @nextActions.
  ///
  /// In en, this message translates to:
  /// **'Next actions'**
  String get nextActions;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get addPlant;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @plantAdded.
  ///
  /// In en, this message translates to:
  /// **'Plant added'**
  String get plantAdded;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @editPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit Plant'**
  String get editPlant;

  /// No description provided for @plantUpdated.
  ///
  /// In en, this message translates to:
  /// **'Plant updated'**
  String get plantUpdated;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get deleteImage;

  /// No description provided for @areYouSureYouWantToDeleteThisImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get areYouSureYouWantToDeleteThisImage;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @imageInfo.
  ///
  /// In en, this message translates to:
  /// **'Image info'**
  String get imageInfo;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @unsetAsAvatar.
  ///
  /// In en, this message translates to:
  /// **'Unset as Avatar'**
  String get unsetAsAvatar;

  /// No description provided for @setAsAvatar.
  ///
  /// In en, this message translates to:
  /// **'Set as Avatar'**
  String get setAsAvatar;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @care.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get care;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @plantDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Plant duplicated'**
  String get plantDuplicated;

  /// No description provided for @plantDeleted.
  ///
  /// In en, this message translates to:
  /// **'Plant deleted'**
  String get plantDeleted;

  /// No description provided for @searchGreenFriends.
  ///
  /// In en, this message translates to:
  /// **'Search green friends'**
  String get searchGreenFriends;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'custom'**
  String get custom;

  /// No description provided for @floraCodex.
  ///
  /// In en, this message translates to:
  /// **'Flora Codex'**
  String get floraCodex;

  /// No description provided for @seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @createEventType.
  ///
  /// In en, this message translates to:
  /// **'Create Event Type'**
  String get createEventType;

  /// No description provided for @selectAColor.
  ///
  /// In en, this message translates to:
  /// **'Select a color'**
  String get selectAColor;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @whichColorYouWantToUse.
  ///
  /// In en, this message translates to:
  /// **'Which color you want to use?'**
  String get whichColorYouWantToUse;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @whichIconYouWantToUse.
  ///
  /// In en, this message translates to:
  /// **'Which icon you want to use?'**
  String get whichIconYouWantToUse;

  /// No description provided for @filterIcons.
  ///
  /// In en, this message translates to:
  /// **'Filter icons'**
  String get filterIcons;

  /// No description provided for @insertAName.
  ///
  /// In en, this message translates to:
  /// **'Insert a name'**
  String get insertAName;

  /// No description provided for @editEventType.
  ///
  /// In en, this message translates to:
  /// **'Edit Event Type'**
  String get editEventType;

  /// No description provided for @eventTypeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event Type updated'**
  String get eventTypeUpdated;

  /// No description provided for @areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the event type and all linked events?'**
  String get areYouSureYouWantToDeleteTheEventTypeAndAllLinkedEvents;

  /// No description provided for @eventTypeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event Type deleted'**
  String get eventTypeDeleted;

  /// No description provided for @createReminder.
  ///
  /// In en, this message translates to:
  /// **'Create Reminder'**
  String get createReminder;

  /// No description provided for @reminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Reminder created'**
  String get reminderCreated;

  /// No description provided for @whichEventTypeYouWantToSet.
  ///
  /// In en, this message translates to:
  /// **'Which event type you want to set?'**
  String get whichEventTypeYouWantToSet;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @whichPlantsYouWantToSet.
  ///
  /// In en, this message translates to:
  /// **'Which plant you want to set?'**
  String get whichPlantsYouWantToSet;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated'**
  String get reminderUpdated;

  /// No description provided for @whichEventsYouWantToSet.
  ///
  /// In en, this message translates to:
  /// **'Which events you want to set?'**
  String get whichEventsYouWantToSet;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @areYouSureYouWantToDeleteTheReminder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the reminder?'**
  String get areYouSureYouWantToDeleteTheReminder;

  /// No description provided for @dataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get dataSources;

  /// No description provided for @configureTheFloraCodexSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure the Flora Codex settings'**
  String get configureTheFloraCodexSettings;

  /// No description provided for @insertTheFloraCodexApiKey.
  ///
  /// In en, this message translates to:
  /// **'Insert the Flora Codex API Key'**
  String get insertTheFloraCodexApiKey;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter API Key'**
  String get enterApiKey;

  /// No description provided for @enableDataSource.
  ///
  /// In en, this message translates to:
  /// **'Enable data source'**
  String get enableDataSource;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'not provided'**
  String get notProvided;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support ♥️'**
  String get support;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @selectWeekdaysAndTimes.
  ///
  /// In en, this message translates to:
  /// **'Select Weekdays and Times'**
  String get selectWeekdaysAndTimes;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick Time'**
  String get pickTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @aboutPlantIt.
  ///
  /// In en, this message translates to:
  /// **'About Plant-it'**
  String get aboutPlantIt;

  /// No description provided for @manageTheEventTypes.
  ///
  /// In en, this message translates to:
  /// **'Manage the event types'**
  String get manageTheEventTypes;

  /// No description provided for @manageTheReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage the reminders'**
  String get manageTheReminders;

  /// No description provided for @manageTheDataSources.
  ///
  /// In en, this message translates to:
  /// **'Manage the data sources'**
  String get manageTheDataSources;

  /// No description provided for @configureWhenAndIfNotificationsAreReceived.
  ///
  /// In en, this message translates to:
  /// **'Configure when and if notifications are received'**
  String get configureWhenAndIfNotificationsAreReceived;

  /// No description provided for @detailsAboutTheApp.
  ///
  /// In en, this message translates to:
  /// **'Details about the app'**
  String get detailsAboutTheApp;

  /// No description provided for @yourSupportHelpsUsGrow.
  ///
  /// In en, this message translates to:
  /// **'Your support helps us grow!'**
  String get yourSupportHelpsUsGrow;

  /// No description provided for @supportTheProject.
  ///
  /// In en, this message translates to:
  /// **'Support the project'**
  String get supportTheProject;

  /// No description provided for @whySupportPlantIt.
  ///
  /// In en, this message translates to:
  /// **'Why Support Plant-it?'**
  String get whySupportPlantIt;

  /// No description provided for @openSourceProjectThatBenefitsEveryone.
  ///
  /// In en, this message translates to:
  /// **'Open-source project that benefits everyone.'**
  String get openSourceProjectThatBenefitsEveryone;

  /// No description provided for @yourDonationsHelpUsImproveTheApp.
  ///
  /// In en, this message translates to:
  /// **'Your donations help us improve the app.'**
  String get yourDonationsHelpUsImproveTheApp;

  /// No description provided for @supportNewFeaturesAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'Support new features and updates.'**
  String get supportNewFeaturesAndUpdates;

  /// No description provided for @donateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateNow;

  /// No description provided for @createSpecies.
  ///
  /// In en, this message translates to:
  /// **'Create Species'**
  String get createSpecies;

  /// No description provided for @speciesCreated.
  ///
  /// In en, this message translates to:
  /// **'Species created'**
  String get speciesCreated;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @noAvatar.
  ///
  /// In en, this message translates to:
  /// **'No avatar'**
  String get noAvatar;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhoto;

  /// No description provided for @useWebImage.
  ///
  /// In en, this message translates to:
  /// **'Use web image'**
  String get useWebImage;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'Url'**
  String get url;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @ph.
  ///
  /// In en, this message translates to:
  /// **'Ph'**
  String get ph;

  /// No description provided for @genus.
  ///
  /// In en, this message translates to:
  /// **'Genus'**
  String get genus;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @synonym.
  ///
  /// In en, this message translates to:
  /// **'Synonym'**
  String get synonym;

  /// No description provided for @addSynonym.
  ///
  /// In en, this message translates to:
  /// **'Add synonym'**
  String get addSynonym;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @synonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms'**
  String get synonyms;

  /// No description provided for @editSpecies.
  ///
  /// In en, this message translates to:
  /// **'Edit Species'**
  String get editSpecies;

  /// No description provided for @speciesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Species updated'**
  String get speciesUpdated;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get addToCollection;

  /// No description provided for @showNextNotificationsDateTime.
  ///
  /// In en, this message translates to:
  /// **'Show next notifications date and time'**
  String get showNextNotificationsDateTime;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plant;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @sunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get sunlight;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get max;

  /// An error with a message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get blue;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'white'**
  String get white;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'teal'**
  String get teal;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'yellow'**
  String get yellow;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @repeatAfter.
  ///
  /// In en, this message translates to:
  /// **'Repeat after'**
  String get repeatAfter;

  /// A representation of frequency
  ///
  /// In en, this message translates to:
  /// **'Every{quantity, plural, =1{} other{ {quantity}}} {unit, select, days{day} months{month} weeks{week} other{year}}{quantity, plural, =1 {} other {s}}'**
  String frequencyEvery(num quantity, String unit);

  /// A representation of after
  ///
  /// In en, this message translates to:
  /// **'After {quantity} {unit, select, days{day} months{month} weeks{week} other{year}}{quantity, plural, =1 {} other {s}}'**
  String afterMessage(num quantity, String unit);

  /// A representation of time
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit, select, days{day} months{month} weeks{week} other{year}}{quantity, plural, =1 {} other {s}}'**
  String frequency(num quantity, String unit);

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// A description of reminder
  ///
  /// In en, this message translates to:
  /// **'Every{quantity, plural, =1{} other{ {quantity}}} {unit, select, days{day} months{month} weeks{week} other{years}}{quantity, plural, =1{} other {s}} from {startDate}{endDate, select, null {} other { to {endDate}}}'**
  String reminderDescription(
      num quantity, String unit, DateTime startDate, String endDate);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// A description of a plant classification
  ///
  /// In en, this message translates to:
  /// **'{name} is a plant of species |{species}|{genus, select, null {} other {, genus |{genus}|}}{family, select, null {} other {, family |{family}|}}.'**
  String plantClassificationInfo(
      String name, String species, String genus, String family);

  /// A list of species synonyms
  ///
  /// In en, this message translates to:
  /// **'{synonyms, select, null {{species} has no synonyms} other {{species} is also known as: {synonyms}}}.'**
  String speciesSynonyms(String synonyms, String species);

  /// A description of a plant classification
  ///
  /// In en, this message translates to:
  /// **'{species} is a species of genus {genus, select, null {unknown} other {|{genus}|}} and family {family, select, null {unknown} other {|{family}|}}.'**
  String speciesClassificationInfo(String species, String genus, String family);

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @databaseAndCache.
  ///
  /// In en, this message translates to:
  /// **'Database and Cache'**
  String get databaseAndCache;

  /// No description provided for @manageDatabaseAndCache.
  ///
  /// In en, this message translates to:
  /// **'Manage Database and Cache settings'**
  String get manageDatabaseAndCache;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear the Cache'**
  String get clearCache;

  /// No description provided for @cacheCleaned.
  ///
  /// In en, this message translates to:
  /// **'Cache cleaned'**
  String get cacheCleaned;

  /// No description provided for @noSynonyms.
  ///
  /// In en, this message translates to:
  /// **'No known synonyms'**
  String get noSynonyms;

  /// No description provided for @areYouSureYouWantToDeleteThisPlant.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plant?'**
  String get areYouSureYouWantToDeleteThisPlant;

  /// No description provided for @areYouSureYouWantToDeleteThisSpecies.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this species and all of your related plants?'**
  String get areYouSureYouWantToDeleteThisSpecies;

  /// No description provided for @speciesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Species deleted'**
  String get speciesDeleted;

  /// No description provided for @noPlantsFound.
  ///
  /// In en, this message translates to:
  /// **'No plants found'**
  String get noPlantsFound;

  /// No description provided for @yourPlantWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your plants will appear here when once you add them into your collection'**
  String get yourPlantWillAppearHere;

  /// No description provided for @howToAddPlants.
  ///
  /// In en, this message translates to:
  /// **'How to add plants'**
  String get howToAddPlants;

  /// No description provided for @addPlantInstruction.
  ///
  /// In en, this message translates to:
  /// **'This app works with plants from various species.\n\nYou can add a new plant by first searching for the species (or adding a new one) and then linking a plant to it.\n\nTo get started, search for a species.'**
  String get addPlantInstruction;

  /// No description provided for @searchASpecies.
  ///
  /// In en, this message translates to:
  /// **'Search a species'**
  String get searchASpecies;

  /// No description provided for @noSpeciesFound.
  ///
  /// In en, this message translates to:
  /// **'No species found'**
  String get noSpeciesFound;

  /// No description provided for @searchAndAddSpeciesInstructions.
  ///
  /// In en, this message translates to:
  /// **'You can add a new species, or you can connect the app to a service to access additional species.'**
  String get searchAndAddSpeciesInstructions;

  /// No description provided for @connectToAService.
  ///
  /// In en, this message translates to:
  /// **'Connect to a service'**
  String get connectToAService;

  /// No description provided for @noInfoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No info available'**
  String get noInfoAvailable;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminders found.\n\nCreate a new reminder for your plants to receive notifications and see the next actions you need to take.'**
  String get noReminder;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// In quantity time
  ///
  /// In en, this message translates to:
  /// **'in {quantity} {unit, select, days{day} weeks{week} months{month} other{year}}{quantity, plural, =1{} other {s}}'**
  String inTime(num quantity, String unit);

  /// Ago quantity time
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit, select, days{day} weeks{week} months{month} other{year}}{quantity, plural, =1{} other {s}} ago'**
  String agoTime(num quantity, String unit);

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional info'**
  String get additionalInfo;

  /// No description provided for @floraCodexDescription.
  ///
  /// In en, this message translates to:
  /// **'FloraCodex is a database service that provides access to a comprehensive database of plant species, including their scientific names, common names, and other relevant information. To use this service, you need to obtain an API key.'**
  String get floraCodexDescription;

  /// No description provided for @floraCodexGetApiKey.
  ///
  /// In en, this message translates to:
  /// **'To get your API key, visit the FloraCodex website, or click here'**
  String get floraCodexGetApiKey;

  /// No description provided for @reloadNotificationMessages.
  ///
  /// In en, this message translates to:
  /// **'Reload the notification messages'**
  String get reloadNotificationMessages;

  /// No description provided for @notificationMessagesReloaded.
  ///
  /// In en, this message translates to:
  /// **'Notification messages reloaded, close and open the app'**
  String get notificationMessagesReloaded;

  /// No description provided for @notificationTitle1.
  ///
  /// In en, this message translates to:
  /// **'Oops, You Did It Again!'**
  String get notificationTitle1;

  /// No description provided for @notificationTitle2.
  ///
  /// In en, this message translates to:
  /// **'Plant SOS!'**
  String get notificationTitle2;

  /// No description provided for @notificationTitle3.
  ///
  /// In en, this message translates to:
  /// **'Time to be a Plant Whisperer!'**
  String get notificationTitle3;

  /// No description provided for @notificationTitle4.
  ///
  /// In en, this message translates to:
  /// **'Not Today, Plant!'**
  String get notificationTitle4;

  /// No description provided for @notificationTitle5.
  ///
  /// In en, this message translates to:
  /// **'Plant Caffeine Required!'**
  String get notificationTitle5;

  /// No description provided for @notificationTitle6.
  ///
  /// In en, this message translates to:
  /// **'Leaf It Up to You!'**
  String get notificationTitle6;

  /// No description provided for @notificationTitle7.
  ///
  /// In en, this message translates to:
  /// **'Call the Green Squad!'**
  String get notificationTitle7;

  /// No description provided for @notificationTitle8.
  ///
  /// In en, this message translates to:
  /// **'You\'ve Been \'Leafing\' It Alone'**
  String get notificationTitle8;

  /// No description provided for @notificationBody1.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| needs its |eventType|. Don\'t keep it waiting!'**
  String get notificationBody1;

  /// No description provided for @notificationBody2.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| is calling for |eventType|. Time to save the day!'**
  String get notificationBody2;

  /// No description provided for @notificationBody3.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| needs |eventType|. It\'s waiting for you!'**
  String get notificationBody3;

  /// No description provided for @notificationBody4.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| is tired of waiting for |eventType|. Show it some TLC!'**
  String get notificationBody4;

  /// No description provided for @notificationBody5.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| is overdue for |eventType|. Give it a boost!'**
  String get notificationBody5;

  /// No description provided for @notificationBody6.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| is ready for |eventType|. Don\'t let it down!'**
  String get notificationBody6;

  /// No description provided for @notificationBody7.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| needs its |eventType|. You\'re the hero it deserves!'**
  String get notificationBody7;

  /// No description provided for @notificationBody8.
  ///
  /// In en, this message translates to:
  /// **'|emoji| |plantName| misses its |eventType|. Time to make it happy again!'**
  String get notificationBody8;

  /// No description provided for @gbifDescription.
  ///
  /// In en, this message translates to:
  /// **'GBIF (Global Biodiversity Information Facility) is a free, open database with the scientific and common names of every plant species. It needs no API key. Photos are taken from iNaturalist.'**
  String get gbifDescription;

  /// No description provided for @configureTheGbifSettings.
  ///
  /// In en, this message translates to:
  /// **'Search plants by scientific or common name, free'**
  String get configureTheGbifSettings;

  /// No description provided for @configureThePlantNetSettings.
  ///
  /// In en, this message translates to:
  /// **'Identify plants from a photo'**
  String get configureThePlantNetSettings;

  /// No description provided for @plantNetDescription.
  ///
  /// In en, this message translates to:
  /// **'Pl@ntNet identifies plants from one or more photos and links each result to its GBIF species. The free plan allows 500 identifications per day. To use it you need a free API key.'**
  String get plantNetDescription;

  /// No description provided for @plantNetGetApiKey.
  ///
  /// In en, this message translates to:
  /// **'To get your API key, sign up on the Pl@ntNet website, or click here'**
  String get plantNetGetApiKey;

  /// No description provided for @insertThePlantNetApiKey.
  ///
  /// In en, this message translates to:
  /// **'Insert the Pl@ntNet API Key'**
  String get insertThePlantNetApiKey;

  /// No description provided for @configureTheOpenPlantbookSettings.
  ///
  /// In en, this message translates to:
  /// **'Care data: light, temperature and humidity'**
  String get configureTheOpenPlantbookSettings;

  /// No description provided for @openPlantbookDescription.
  ///
  /// In en, this message translates to:
  /// **'Open Plantbook is a free database with the light, temperature and humidity ranges of thousands of plants. It does not provide soil pH. To use it you need a free client ID and client secret.'**
  String get openPlantbookDescription;

  /// No description provided for @openPlantbookGetCredentials.
  ///
  /// In en, this message translates to:
  /// **'To get your credentials, sign up on the Open Plantbook website and create an API client, or click here'**
  String get openPlantbookGetCredentials;

  /// No description provided for @clientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get clientId;

  /// No description provided for @clientSecret.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get clientSecret;

  /// No description provided for @aiCare.
  ///
  /// In en, this message translates to:
  /// **'AI to complete care'**
  String get aiCare;

  /// No description provided for @configureTheAiCareSettings.
  ///
  /// In en, this message translates to:
  /// **'Estimate the care values no source provides'**
  String get configureTheAiCareSettings;

  /// No description provided for @aiCareDescription.
  ///
  /// In en, this message translates to:
  /// **'When a plant has care values that no data source provides (for example soil pH), an AI model can estimate them. Estimated values are marked as such on the species page and can be edited once the plant is in your collection. Only the scientific name of the plant is sent.'**
  String get aiCareDescription;

  /// No description provided for @aiProvider.
  ///
  /// In en, this message translates to:
  /// **'AI provider'**
  String get aiProvider;

  /// No description provided for @aiProviderNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get aiProviderNone;

  /// No description provided for @aiProviderClaudeHint.
  ///
  /// In en, this message translates to:
  /// **'Paid. Get an API key in the Claude Console'**
  String get aiProviderClaudeHint;

  /// No description provided for @aiProviderGeminiHint.
  ///
  /// In en, this message translates to:
  /// **'Has a free tier. Get an API key in Google AI Studio'**
  String get aiProviderGeminiHint;

  /// No description provided for @aiProviderGitHubModelsHint.
  ///
  /// In en, this message translates to:
  /// **'Free with limits. Use a GitHub token with the \"Models\" permission'**
  String get aiProviderGitHubModelsHint;

  /// No description provided for @getApiKeyClickHere.
  ///
  /// In en, this message translates to:
  /// **'To get your key, click here'**
  String get getApiKeyClickHere;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiModel;

  /// No description provided for @aiModelDefault.
  ///
  /// In en, this message translates to:
  /// **'Default: {model}'**
  String aiModelDefault(String model);

  /// No description provided for @insertTheAiModel.
  ///
  /// In en, this message translates to:
  /// **'Model to use (leave empty for the default)'**
  String get insertTheAiModel;

  /// No description provided for @identifyByPhoto.
  ///
  /// In en, this message translates to:
  /// **'Identify by photo'**
  String get identifyByPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @identifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying the plant...'**
  String get identifying;

  /// No description provided for @photoIdentificationResults.
  ///
  /// In en, this message translates to:
  /// **'Most likely species in your photo'**
  String get photoIdentificationResults;

  /// No description provided for @noPlantIdentified.
  ///
  /// In en, this message translates to:
  /// **'No plant could be identified in the photo. Try a closer photo of a leaf or flower.'**
  String get noPlantIdentified;

  /// No description provided for @plantNetKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'To identify plants by photo, add your Pl@ntNet API key in Settings > Data sources.'**
  String get plantNetKeyMissing;

  /// No description provided for @identificationConfidence.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String identificationConfidence(String percent);

  /// No description provided for @careSources.
  ///
  /// In en, this message translates to:
  /// **'Sources: {sources}'**
  String careSources(String sources);

  /// No description provided for @aiEstimatedCare.
  ///
  /// In en, this message translates to:
  /// **'Estimated by AI ({provider}): {fields}. Check these values and edit them if needed.'**
  String aiEstimatedCare(String provider, String fields);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noNotesTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap to write one.'**
  String get noNotesTapToAdd;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get editNotes;

  /// No description provided for @notesSaved.
  ///
  /// In en, this message translates to:
  /// **'Notes saved'**
  String get notesSaved;

  /// No description provided for @editCare.
  ///
  /// In en, this message translates to:
  /// **'Edit care'**
  String get editCare;

  /// No description provided for @editCareSharedWarning.
  ///
  /// In en, this message translates to:
  /// **'Care belongs to the species, so the change also applies to your other plants of this species.'**
  String get editCareSharedWarning;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get allEvents;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @showAllEvents.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String showAllEvents(String count);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @careFieldLightLux.
  ///
  /// In en, this message translates to:
  /// **'Light (lux)'**
  String get careFieldLightLux;

  /// No description provided for @careFieldLightHours.
  ///
  /// In en, this message translates to:
  /// **'Hours of light per day'**
  String get careFieldLightHours;

  /// No description provided for @careFieldEnvHumidity.
  ///
  /// In en, this message translates to:
  /// **'Ambient humidity'**
  String get careFieldEnvHumidity;

  /// No description provided for @careFieldWateringSummer.
  ///
  /// In en, this message translates to:
  /// **'Watering in summer'**
  String get careFieldWateringSummer;

  /// No description provided for @careFieldWateringWinter.
  ///
  /// In en, this message translates to:
  /// **'Watering in winter'**
  String get careFieldWateringWinter;

  /// No description provided for @careFieldSoilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil moisture'**
  String get careFieldSoilMoisture;

  /// No description provided for @careFieldConductivity.
  ///
  /// In en, this message translates to:
  /// **'Conductivity (EC)'**
  String get careFieldConductivity;

  /// No description provided for @careFieldWaterType.
  ///
  /// In en, this message translates to:
  /// **'Type of water'**
  String get careFieldWaterType;

  /// No description provided for @careFieldWateringMethod.
  ///
  /// In en, this message translates to:
  /// **'Watering method'**
  String get careFieldWateringMethod;

  /// No description provided for @careFieldSubstrate.
  ///
  /// In en, this message translates to:
  /// **'Substrate'**
  String get careFieldSubstrate;

  /// No description provided for @careFieldFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get careFieldFertilizer;

  /// No description provided for @careFieldPruning.
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get careFieldPruning;

  /// No description provided for @careFieldRepotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get careFieldRepotting;

  /// No description provided for @careFieldFloweringSeason.
  ///
  /// In en, this message translates to:
  /// **'Flowering'**
  String get careFieldFloweringSeason;

  /// No description provided for @careFieldDormancySeason.
  ///
  /// In en, this message translates to:
  /// **'Dormancy'**
  String get careFieldDormancySeason;

  /// No description provided for @careFieldCommonPests.
  ///
  /// In en, this message translates to:
  /// **'Common pests'**
  String get careFieldCommonPests;

  /// No description provided for @careFieldDiseases.
  ///
  /// In en, this message translates to:
  /// **'Diseases'**
  String get careFieldDiseases;

  /// No description provided for @careFieldToxicity.
  ///
  /// In en, this message translates to:
  /// **'Toxicity'**
  String get careFieldToxicity;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'every {days} days'**
  String everyNDays(String days);

  /// No description provided for @editMoreCare.
  ///
  /// In en, this message translates to:
  /// **'Edit more care'**
  String get editMoreCare;

  /// No description provided for @careSaved.
  ///
  /// In en, this message translates to:
  /// **'Care saved'**
  String get careSaved;

  /// No description provided for @careFields.
  ///
  /// In en, this message translates to:
  /// **'Care categories'**
  String get careFields;

  /// No description provided for @manageCareFields.
  ///
  /// In en, this message translates to:
  /// **'Choose which care to show and create your own'**
  String get manageCareFields;

  /// No description provided for @careFieldsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enabled categories are shown in the Care section of every species and plant, in this order: drag them to reorder them and tap an icon to change it. Pests and treatments of a specific plant are recorded as events (\"pest\" and \"treatment\" types) in its history.'**
  String get careFieldsDescription;

  /// No description provided for @addCareField.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get addCareField;

  /// No description provided for @careFieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit (optional)'**
  String get careFieldUnit;

  /// No description provided for @careFieldOptions.
  ///
  /// In en, this message translates to:
  /// **'Options, separated by commas'**
  String get careFieldOptions;

  /// No description provided for @careFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get careFieldType;

  /// No description provided for @careFieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get careFieldTypeNumber;

  /// No description provided for @careFieldTypeRange.
  ///
  /// In en, this message translates to:
  /// **'Range (min - max)'**
  String get careFieldTypeRange;

  /// No description provided for @careFieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get careFieldTypeText;

  /// No description provided for @careFieldTypeChoice.
  ///
  /// In en, this message translates to:
  /// **'List of options'**
  String get careFieldTypeChoice;

  /// No description provided for @customCareField.
  ///
  /// In en, this message translates to:
  /// **'Created by you'**
  String get customCareField;

  /// No description provided for @areYouSureYouWantToDeleteThisCareField.
  ///
  /// In en, this message translates to:
  /// **'Its values will be deleted from every species.'**
  String get areYouSureYouWantToDeleteThisCareField;

  /// No description provided for @estimatedByAi.
  ///
  /// In en, this message translates to:
  /// **'Estimated by AI'**
  String get estimatedByAi;

  /// No description provided for @noCareFieldsEnabled.
  ///
  /// In en, this message translates to:
  /// **'No care categories are enabled. Enable them in Settings > Care categories.'**
  String get noCareFieldsEnabled;

  /// No description provided for @basicCare.
  ///
  /// In en, this message translates to:
  /// **'Basic care'**
  String get basicCare;

  /// No description provided for @careCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get careCategories;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit description'**
  String get editDescription;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet. Tap to write one or fill it in automatically.'**
  String get noDescription;

  /// No description provided for @fillAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Fill in automatically'**
  String get fillAutomatically;

  /// No description provided for @noDescriptionFound.
  ///
  /// In en, this message translates to:
  /// **'No description was found for this species.'**
  String get noDescriptionFound;

  /// No description provided for @descriptionSaved.
  ///
  /// In en, this message translates to:
  /// **'Description saved'**
  String get descriptionSaved;

  /// No description provided for @descriptionSharedWarning.
  ///
  /// In en, this message translates to:
  /// **'The description belongs to the species, so it is shared by your plants of this species.'**
  String get descriptionSharedWarning;

  /// No description provided for @changeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get changeIcon;

  /// No description provided for @restoreDefaultIcon.
  ///
  /// In en, this message translates to:
  /// **'Default icon'**
  String get restoreDefaultIcon;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @weatherAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Weather and location'**
  String get weatherAndLocation;

  /// No description provided for @manageWeather.
  ///
  /// In en, this message translates to:
  /// **'Local weather and season for your plants'**
  String get manageWeather;

  /// No description provided for @weatherDescription.
  ///
  /// In en, this message translates to:
  /// **'Your location is used to show the local weather and season, highlight the watering of the current season and warn about frost, heat and rain for your outdoor plants. The weather comes from Open-Meteo, which receives only your approximate location.'**
  String get weatherDescription;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search your city'**
  String get searchCity;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @noPlaceSet.
  ///
  /// In en, this message translates to:
  /// **'No location set'**
  String get noPlaceSet;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'The location is not available. Allow it in the phone settings or search your city.'**
  String get locationPermissionDenied;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No place found'**
  String get noPlacesFound;

  /// No description provided for @setUpWeather.
  ///
  /// In en, this message translates to:
  /// **'Set your location to see the weather and the season'**
  String get setUpWeather;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @seasonDry.
  ///
  /// In en, this message translates to:
  /// **'Dry season'**
  String get seasonDry;

  /// No description provided for @seasonRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy season'**
  String get seasonRainy;

  /// No description provided for @humidityPercent.
  ///
  /// In en, this message translates to:
  /// **'{humidity}% humidity'**
  String humidityPercent(String humidity);

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get weatherStorm;

  /// No description provided for @frostAlert.
  ///
  /// In en, this message translates to:
  /// **'{day}: down to {temperature} °C. {plant} withstands at least {min} °C'**
  String frostAlert(String day, String temperature, String plant, String min);

  /// No description provided for @heatAlert.
  ///
  /// In en, this message translates to:
  /// **'{day}: up to {temperature} °C. {plant} withstands at most {max} °C'**
  String heatAlert(String day, String temperature, String plant, String max);

  /// No description provided for @rainAlert.
  ///
  /// In en, this message translates to:
  /// **'Rain today: you can skip watering {plants}'**
  String rainAlert(String plants);

  /// No description provided for @outdoorAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'Frost, heat and rain alerts are shown for plants whose location is Outdoor.'**
  String get outdoorAlertsHint;

  /// No description provided for @currentSeason.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get currentSeason;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// No description provided for @changePlantImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changePlantImage;

  /// No description provided for @phoneGallery.
  ///
  /// In en, this message translates to:
  /// **'Phone gallery'**
  String get phoneGallery;

  /// No description provided for @speciesPhotosOnline.
  ///
  /// In en, this message translates to:
  /// **'Photos of the species on the Internet'**
  String get speciesPhotosOnline;

  /// No description provided for @fromLink.
  ///
  /// In en, this message translates to:
  /// **'From a link'**
  String get fromLink;

  /// No description provided for @imageLink.
  ///
  /// In en, this message translates to:
  /// **'Image link (https://…)'**
  String get imageLink;

  /// No description provided for @useSpeciesImage.
  ///
  /// In en, this message translates to:
  /// **'Use the species image'**
  String get useSpeciesImage;

  /// No description provided for @imageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Image updated'**
  String get imageUpdated;

  /// No description provided for @noPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'No photos found for this species'**
  String get noPhotosFound;

  /// No description provided for @photosFromINaturalist.
  ///
  /// In en, this message translates to:
  /// **'Photos shared on iNaturalist. The one you choose is saved with the plant photos.'**
  String get photosFromINaturalist;

  /// No description provided for @suggestionsForPlant.
  ///
  /// In en, this message translates to:
  /// **'Suggestions for {plant}'**
  String suggestionsForPlant(String plant);

  /// No description provided for @suggestionsHint.
  ///
  /// In en, this message translates to:
  /// **'Based on its care, the season and its location. Tap one to create it.'**
  String get suggestionsHint;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions: add care such as watering or fertilizer to the plant\'s species.'**
  String get noSuggestions;

  /// No description provided for @suggestionWatering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get suggestionWatering;

  /// No description provided for @suggestionFertilizing.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get suggestionFertilizing;

  /// No description provided for @suggestionPruning.
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get suggestionPruning;

  /// No description provided for @suggestionRepotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get suggestionRepotting;

  /// No description provided for @suggestionPestCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for pests'**
  String get suggestionPestCheck;

  /// No description provided for @suggestionMisting.
  ///
  /// In en, this message translates to:
  /// **'Mist the leaves'**
  String get suggestionMisting;

  /// No description provided for @suggestionProtectFromCold.
  ///
  /// In en, this message translates to:
  /// **'Protect from the cold'**
  String get suggestionProtectFromCold;

  /// No description provided for @suggestionMoveOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Move outdoors'**
  String get suggestionMoveOutdoors;

  /// No description provided for @reasonWatering.
  ///
  /// In en, this message translates to:
  /// **'Watering of the current season'**
  String get reasonWatering;

  /// No description provided for @reasonFertilizing.
  ///
  /// In en, this message translates to:
  /// **'During the growing season'**
  String get reasonFertilizing;

  /// No description provided for @reasonPruning.
  ///
  /// In en, this message translates to:
  /// **'At its pruning time'**
  String get reasonPruning;

  /// No description provided for @reasonRepotting.
  ///
  /// In en, this message translates to:
  /// **'At its repotting frequency'**
  String get reasonRepotting;

  /// No description provided for @reasonPestCheck.
  ///
  /// In en, this message translates to:
  /// **'Look for its usual pests on leaves and stems'**
  String get reasonPestCheck;

  /// No description provided for @reasonMisting.
  ///
  /// In en, this message translates to:
  /// **'It needs a high ambient humidity'**
  String get reasonMisting;

  /// No description provided for @reasonProtectFromCold.
  ///
  /// In en, this message translates to:
  /// **'Outdoor plant that does not withstand winter cold'**
  String get reasonProtectFromCold;

  /// No description provided for @reasonMoveOutdoors.
  ///
  /// In en, this message translates to:
  /// **'When the warm weather returns'**
  String get reasonMoveOutdoors;

  /// No description provided for @everyCountDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{every day} other{every {count} days}}'**
  String everyCountDays(int count);

  /// No description provided for @everyCountWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{every week} other{every {count} weeks}}'**
  String everyCountWeeks(int count);

  /// No description provided for @everyCountMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{every month} other{every {count} months}}'**
  String everyCountMonths(int count);

  /// No description provided for @everyCountYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{every year} other{every {count} years}}'**
  String everyCountYears(int count);

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'from {date}'**
  String fromDate(String date);

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String untilDate(String date);

  /// No description provided for @protectFromRainAlert.
  ///
  /// In en, this message translates to:
  /// **'{day}: {rain} mm of rain. {plant} is watered every {days} days: protect it from the rain'**
  String protectFromRainAlert(
      String day, String rain, String plant, String days);
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fr':
      return LFr();
    case 'it':
      return LIt();
  }

  throw FlutterError(
      'L.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
