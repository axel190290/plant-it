import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/home/view_models/home_viewmodel.dart';

/// The plants of the collection as full-width cards, one below the other,
/// scrolling with the rest of the home page.
class PlantCardList extends StatelessWidget {
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
      return viewModel.plantMap[id]!.name
          .toLowerCase()
          .contains(filter.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: plantIds.map((int plantId) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Material(
                child: InkWell(
                  onTap: () => context.push(Routes.plantWithId(plantId)),
                  child: HeroLayoutCard(
                    plantId: plantId,
                    viewModel: viewModel,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
      alignment: AlignmentDirectional.bottomStart,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Image(
            fit: BoxFit.cover,
            image: viewModel.imagesBase64[plantId] == null
                ? const AssetImage("assets/images/generic-plant.jpg")
                : MemoryImage(base64Decode(viewModel.imagesBase64[plantId]!))
                    as ImageProvider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                viewModel.plantMap[plantId]!.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              // const SizedBox(height: 10),
              // Text(
              //   viewModel.plantMap[plantId]!.species.toString(),
              //   overflow: TextOverflow.clip,
              //   softWrap: false,
              //   style: Theme.of(context)
              //       .textTheme
              //       .bodyMedium
              //       ?.copyWith(color: Colors.white),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
