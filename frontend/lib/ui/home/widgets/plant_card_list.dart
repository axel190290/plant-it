import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/database/database.dart' show Collection;
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/home/view_models/home_viewmodel.dart';

/// The plants of the collection: one section per group, then the plants
/// in no group, when there are groups and all plants are shown; else only
/// the plants of the chosen group, or all of them.
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
    int? selected = viewModel.selectedCollection;
    if (selected != null) {
      List<int> plantIds = _matching(viewModel.plantsOf(selected));
      if (plantIds.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.emptyCollection,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        );
      }
      return PlantGrid(viewModel: viewModel, plantIds: plantIds);
    }
    if (viewModel.collections.isEmpty) {
      return PlantGrid(
          viewModel: viewModel, plantIds: _matching(viewModel.plantMap.keys));
    }

    // One section per group, then the plants in no group
    List<(int, String, List<int>)> sections = [
      for (Collection c in viewModel.collections)
        (c.id, c.name, _matching(viewModel.plantsOf(c.id))),
      (
        HomeViewModel.ungroupedSection,
        l.ungroupedPlants,
        _matching(viewModel.ungroupedPlants)
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for ((int, String, List<int>) section in sections)
          if (section.$3.isNotEmpty) ...[
            _SectionHeader(
              title: section.$2,
              count: section.$3.length,
              collapsed: viewModel.isCollapsed(section.$1),
              onTap: () => viewModel.toggleCollapsed(section.$1),
            ),
            if (!viewModel.isCollapsed(section.$1))
              PlantGrid(viewModel: viewModel, plantIds: section.$3),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

/// The title of a section of plants; tapping it folds or unfolds it.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
