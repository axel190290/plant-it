import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/ui/core/ui/plant_group_format.dart';
import 'package:plant_it/domain/models/reminder_occurrence.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/plant/view_models/plant_view_model.dart';
import 'package:plant_it/ui/plant/widgets/info_widget.dart';
import 'package:plant_it/utils/common.dart';
import 'package:plant_it/utils/icons.dart';

abstract class InfoGridWidget extends StatefulWidget {
  final SpeciesCareCompanion care;
  final int maxNum;
  final L appLocalizations;
  // When false, every tile is shown in rows of two instead of pages
  final bool paginate;

  const InfoGridWidget({
    super.key,
    required this.care,
    required this.maxNum,
    required this.appLocalizations,
    this.paginate = true,
  });

  List<InfoWidget> getInfoChildren();

  @override
  State<InfoGridWidget> createState() => _InfoGridWidgetState();
}

class _InfoGridWidgetState extends State<InfoGridWidget> {
  // Computed on every build, so new values are shown after a reload
  int get _pages => (widget.getInfoChildren().length / widget.maxNum).ceil();

  // Size of a tile in two columns on a phone in portrait
  static const double _tileMaxWidth = 200;
  static const double _tileHeight = 72;

  Widget _buildSinglePage(List<Widget>? tiles) {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Without pages, tiles keep their size and wider screens get more
      // columns; pages hold two columns of [maxNum] tiles
      gridDelegate: widget.paginate
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            )
          : const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _tileMaxWidth,
              mainAxisExtent: _tileHeight,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
      itemCount: tiles?.length ?? 0,
      itemBuilder: (context, index) {
        return tiles!.elementAt(index);
      },
    );
  }

  Widget _buildMultiplePages() {
    final List<List<Widget>> pagesList = _chunkWidgets(widget.maxNum);

    final List<Widget> pageWidgets =
        pagesList.map((chunk) => _buildSinglePage(chunk)).toList();

    return FlutterCarousel(
      options: FlutterCarouselOptions(
        showIndicator: true,
        enableInfiniteScroll: false,
        viewportFraction: 1,
        indicatorMargin: 0,
        height: 230,
        slideIndicator: CircularSlideIndicator(
            slideIndicatorOptions: SlideIndicatorOptions(
          currentIndicatorColor: Theme.of(context).primaryColor,
          // ignore: deprecated_member_use
          indicatorBackgroundColor: Colors.grey.withOpacity(.5),
        )),
      ),
      items: pageWidgets,
    );
  }

  List<List<Widget>> _chunkWidgets(int chunkSize) {
    List<Widget> widgets = widget.getInfoChildren();
    List<List<Widget>> chunks = [];
    for (var i = 0; i < widgets.length; i += chunkSize) {
      final chunk = widgets.sublist(
          i, i + chunkSize > widgets.length ? widgets.length : i + chunkSize);
      chunks.add(chunk);
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == 0) {
      return SizedBox();
    }
    if (_pages == 1 || !widget.paginate) {
      return _buildSinglePage(widget.getInfoChildren());
    }
    return _buildMultiplePages();
  }
}

class SpeciesCareInfoGridWidget extends InfoGridWidget {
  // The care categories, basic care included, in display order
  final List<CareField> careFields;
  final Map<int, CareValue> careValues;
  final void Function(String title, String value, bool estimated, String? note)?
      onTapValue;
  // Keys of the categories that apply now, like the watering of the season
  final Set<String> currentKeys;

  const SpeciesCareInfoGridWidget({
    super.key,
    required super.care,
    required super.maxNum,
    required super.appLocalizations,
    super.paginate = false,
    this.careFields = const [],
    this.careValues = const {},
    this.onTapValue,
    this.currentKeys = const {},
  });

  /// The value of a basic care category, or null if it is not set.
  String? _basicValue(String key) {
    switch (key) {
      case basicLightKey:
        if (care.light.value == null) return null;
        if (care.light.value! > 5) return appLocalizations.high;
        if (care.light.value! > 3) return appLocalizations.medium;
        return appLocalizations.low;
      case basicHumidityKey:
        return care.humidity.value == null ? null : "${care.humidity.value!}0%";
      case basicTemperatureKey:
        int? min = care.tempMin.value;
        int? max = care.tempMax.value;
        if (min != null && max != null) return "$min - $max °C";
        if (min != null) return "${appLocalizations.min} $min °C";
        if (max != null) return "${appLocalizations.max} $max °C";
        return null;
      case basicPhKey:
        int? min = care.phMin.value;
        int? max = care.phMax.value;
        if (min != null && max != null) return "$min - $max";
        if (min != null) return "${appLocalizations.min} $min";
        if (max != null) return "${appLocalizations.max} $max";
        return null;
    }
    return null;
  }

  InfoWidget _tile(String title, String text, IconData icon, bool estimated,
      {bool current = false, String? note}) {
    String shown =
        current ? "$title · ${appLocalizations.currentSeason}" : title;
    // ✨ estimated by the AI, 📖 typical value of the plant group
    String mark = estimated
        ? " ✨"
        : note != null
            ? " 📖"
            : "";
    return InfoWidget(
      icon: icon,
      highlighted: current,
      title: "$shown$mark",
      value: text,
      onTap: onTapValue == null
          ? null
          : () => onTapValue!(title, text, estimated, note),
    );
  }

  @override
  List<InfoWidget> getInfoChildren() {
    List<CareField> fields = careFields;
    if (!fields.any((f) => isBasicCareField(f))) {
      // Care fields not loaded: show the basic care first, as before
      fields = [...basicCareFieldPlaceholders, ...careFields];
    }
    List<InfoWidget> result = [];
    for (CareField field in fields) {
      if (!field.enabled) continue;
      String title = careFieldName(appLocalizations, field);
      if (isBasicCareField(field)) {
        String? text = _basicValue(field.key!);
        if (text != null) {
          result.add(_tile(title, text, careFieldIcon(field), false));
        }
        continue;
      }
      CareValue? value = careValues[field.id];
      if (value == null) continue;
      String? text = formatCareValue(appLocalizations, field, value);
      if (text != null) {
        result.add(_tile(title, text, careFieldIcon(field), value.estimated,
            current: currentKeys.contains(field.key),
            note: typicalValueNote(appLocalizations, value.source)));
      }
    }
    return result;
  }
}

class PlantEventInfoGridWidget extends InfoGridWidget {
  final PlantViewModel viewModel;

  const PlantEventInfoGridWidget({
    super.key,
    required this.viewModel,
    required super.maxNum,
    required super.care,
    required super.appLocalizations,
  });

  @override
  List<InfoWidget> getInfoChildren() {
    List<InfoWidget> result = [];
    List<Event> events = viewModel.events;
    Map<int, EventType> eventTypes = {};
    for (EventType t in viewModel.eventType) {
      eventTypes.putIfAbsent(t.id, () => t);
    }

    result.addAll(events.map((e) {
      return InfoWidget(
          title: eventTypes[e.type]!.name,
          value: timeDiffStr(e.date, appLocalizations),
          icon: appIcons[eventTypes[e.type]!.icon]!);
    }));

    return result;
  }
}

class PlantReminderInfoGridWidget extends InfoGridWidget {
  final PlantViewModel viewModel;

  const PlantReminderInfoGridWidget({
    super.key,
    required this.viewModel,
    required super.maxNum,
    required super.care,
    required super.appLocalizations,
  });

  @override
  List<InfoWidget> getInfoChildren() {
    Map<int, EventType> eventTypes = {};
    for (EventType t in viewModel.eventType) {
      eventTypes.putIfAbsent(t.id, () => t);
    }

    List<ReminderOccurrence> plantReminders = viewModel.remindersOccurrences;

    return plantReminders
        .map((ro) => InfoWidget(
            title: eventTypes[ro.reminder.type]!.name,
            value: timeDiffStr(ro.nextOccurrence, appLocalizations),
            icon: appIcons[eventTypes[ro.reminder.type]!.icon]!))
        .toList();
  }
}
