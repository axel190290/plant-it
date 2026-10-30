import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/home/view_models/home_viewmodel.dart';

/// The plants of the collection as a grid of cards: two columns on a phone
/// in portrait, and as many columns of about the same size as fit in
/// landscape or on bigger screens.
class PlantCardList extends StatelessWidget {
  // Wide enough for two columns on any phone in portrait
  static const double maxCardWidth = 220;

  final HomeViewModel viewModel;
  final String filter;

  const PlantCardList({
    super.key,
    required this.viewModel,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> plantIds = viewModel.plantMap.keys.where((id) {
      return viewModel.isShown(id) &&
          viewModel.plantMap[id]!.name
              .toLowerCase()
              .contains(filter.toLowerCase());
    }).toList();
    if (plantIds.isEmpty && viewModel.selectedCollection != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(L.of(context).emptyCollection,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

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
