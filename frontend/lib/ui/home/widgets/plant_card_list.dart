import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/database/database.dart' show Collection;
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/home/view_models/home_viewmodel.dart';
import 'package:plant_it/ui/home/widgets/collection_actions.dart';

/// The plants of the collection: one section per group, then the plants
/// in no group, when there are groups; else all of them.
class PlantCardList extends StatelessWidget {
  final HomeViewModel viewModel;
  final String filter;

  const PlantCardList({
    super.key,
    required this.viewModel,
    required this.filter,
  });

  List<int> _matching(Iterable<int> ids) => ids
      .where((id) =>
          viewModel.plantMap[id] != null &&
          viewModel.plantMap[id]!.name
              .toLowerCase()
              .contains(filter.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    if (viewModel.collections.isEmpty) {
      return PlantGrid(
          viewModel: viewModel, plantIds: _matching(viewModel.plantMap.keys));
    }

    // One section per group, then the plants in no group
    List<(Collection?, int, String, List<int>)> sections = [
      for (Collection c in viewModel.collections)
        (c, c.id, c.name, _matching(viewModel.plantsOf(c.id))),
      (
        null,
        HomeViewModel.ungroupedSection,
        l.ungroupedPlants,
        _matching(viewModel.ungroupedPlants)
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for ((Collection?, int, String, List<int>) section in sections)
          // An empty group shows, without search, to choose its plants
          if (section.$4.isNotEmpty ||
              (section.$1 != null && filter.isEmpty)) ...[
            _SectionHeader(
              title: section.$3,
              count: section.$4.length,
              collapsed: viewModel.isCollapsed(section.$2),
              onTap: () => viewModel.toggleCollapsed(section.$2),
              onLongPress: section.$1 == null
                  ? null
                  : () => CollectionActions(viewModel)
                      .showActions(context, section.$1!),
            ),
            if (!viewModel.isCollapsed(section.$2))
              section.$4.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(l.emptyCollection,
                          style: Theme.of(context).textTheme.bodySmall),
                    )
                  : PlantGrid(viewModel: viewModel, plantIds: section.$4),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

/// The title of a section of plants; tapping it folds or unfolds it, and
/// a long press shows what can be done with its group.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$title ($count)",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(collapsed ? LucideIcons.chevron_down : LucideIcons.chevron_up),
          ],
        ),
      ),
    );
  }
}

/// Plants as a grid of cards: two columns on a phone in portrait, and as
/// many columns of about the same size as fit in landscape or on bigger
/// screens.
class PlantGrid extends StatelessWidget {
  // Wide enough for two columns on any phone in portrait
  static const double maxCardWidth = 220;

  final HomeViewModel viewModel;
  final List<int> plantIds;

  const PlantGrid({
    super.key,
    required this.viewModel,
    required this.plantIds,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCardWidth,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: plantIds.length,
      itemBuilder: (context, index) {
        int plantId = plantIds[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            child: InkWell(
              onTap: () => context.push(Routes.plantWithId(plantId)),
              child: HeroLayoutCard(
                plantId: plantId,
                viewModel: viewModel,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  final HomeViewModel viewModel;
  final int plantId;

  const HeroLayoutCard({
    super.key,
    required this.viewModel,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image(
          fit: BoxFit.cover,
          image: viewModel.imagesBase64[plantId] == null
              ? const AssetImage("assets/images/generic-plant.jpg")
              : MemoryImage(base64Decode(viewModel.imagesBase64[plantId]!))
                  as ImageProvider,
        ),
        // Keeps the name readable on light photos
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              viewModel.plantMap[plantId]!.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
