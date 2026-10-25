import 'dart:async';
import 'dart:io';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_it/data/service/identify/plantnet_identifier.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/species_searcher_result.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/core/ui/error_indicator.dart';
import 'package:plant_it/ui/search/view_models/search_viewmodel.dart';
import 'package:plant_it/ui/search/widgets/empty_search.dart';
import 'package:plant_it/ui/search/widgets/species_card.dart';
import 'package:plant_it/utils/stream_code.dart';

class SearchPage extends StatefulWidget {
  final SearchViewModel viewModel;
  final StreamController<StreamCode> streamController;

  const SearchPage({
    super.key,
    required this.viewModel,
    required this.streamController,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listening also makes the errors handled locally instead of globally
    widget.viewModel.identify.errors.addListener(_onIdentifyError);
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        widget.viewModel.search.execute(
          Query(
            term: "",
            offset: 0,
            limit: 10,
          ),
        );
      }
    });
    widget.streamController.stream.listen((_) {
      widget.viewModel.search.execute(
        Query(
          term: "",
          offset: 0,
          limit: 10,
        ),
      );
    });
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      widget.viewModel.search.execute(
        Query(
          term: value,
          offset: 0,
          limit: 10,
        ),
      );
    }
  }

  Future<void> _identifyByPhoto() async {
    ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(L.of(context).identifyByPhoto,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(L.of(context).camera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.images),
              title: Text(L.of(context).gallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    List<XFile> picked;
    if (source == ImageSource.camera) {
      XFile? photo = await _picker.pickImage(
          source: source, maxWidth: 1600, imageQuality: 85);
      picked = photo == null ? [] : [photo];
    } else {
      // Pl@ntNet accepts up to 5 photos of the same plant
      picked = await _picker.pickMultiImage(
          limit: 5, maxWidth: 1600, imageQuality: 85);
    }
    if (picked.isEmpty || !mounted) return;

    _searchController.clear();
    widget.viewModel.identify
        .execute(picked.take(5).map((f) => File(f.path)).toList());
  }

  void _onIdentifyError() {
    CommandError? error = widget.viewModel.identify.errors.value;
    if (error == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.error is MissingApiKeyException
            ? L.of(context).plantNetKeyMissing
            : L.of(context).errorWithMessage(error.error.toString())),
      ),
    );
  }

  @override
  void dispose() {
    widget.viewModel.identify.errors.removeListener(_onIdentifyError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: ListenableBuilder(
          listenable: Listenable.merge([
            widget.viewModel.search.results,
            widget.viewModel.identify.isExecuting,
          ]),
          builder: (context, _) {
            CommandResult<Query?, void> command =
                widget.viewModel.search.results.value;
            if (command.isExecuting ||
                widget.viewModel.identify.isExecuting.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (widget.viewModel.identify.isExecuting.value) ...[
                      const SizedBox(height: 16),
                      Text(L.of(context).identifying),
                    ],
                  ],
                ),
              );
            }

            if (command.hasError) {
              return ErrorIndicator(
                title: L.of(context).errorWithMessage(command.error.toString()),
                label: L.of(context).tryAgain,
                onPressed: widget.viewModel.search.execute,
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    child: SearchBar(
                        controller: _searchController,
                        hintText: L.of(context).searchGreenFriends,
                        leading: const Icon(Icons.search),
                        elevation: WidgetStatePropertyAll(0),
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onSubmitted: _onSearchSubmitted,
                        trailing: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            ),
                          IconButton(
                            icon: const Icon(LucideIcons.camera),
                            tooltip: L.of(context).identifyByPhoto,
                            onPressed: _identifyByPhoto,
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.plus),
                            onPressed: () => context.push(
                              Routes.species,
                              extra: _searchController.text,
                            ),
                          ),
                          // PopupMenuButton<String>(
                          //   icon: const Icon(Icons.more_vert, size: 25),
                          //   onSelected: (value) async {
                          //     if (value == 'add') {
                          //       context.push(Routes.species, extra: _searchController.text);
                          //     } else if (value == 'filter') {
                          //       // ...
                          //     }
                          //   },
                          //   itemBuilder: (BuildContext context) => [
                          //     const PopupMenuItem(
                          //       value: 'add',
                          //       child: Row(
                          //         crossAxisAlignment: CrossAxisAlignment.center,
                          //         children: [
                          //           Icon(LucideIcons.plus),
                          //           SizedBox(width: 10),
                          //           Text('Create'),
                          //         ],
                          //       ),
                          //     ),
                          //     const PopupMenuItem(
                          //       value: 'filter',
                          //       child: Row(
                          //         crossAxisAlignment: CrossAxisAlignment.center,
                          //         children: [
                          //           Icon(LucideIcons.filter),
                          //           SizedBox(width: 10),
                          //           Text('Filter'),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ]),
                  ),
                  if (widget.viewModel.isPhotoResult)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        widget.viewModel.result.isEmpty
                            ? L.of(context).noPlantIdentified
                            : L.of(context).photoIdentificationResults,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  widget.viewModel.result.isEmpty &&
                          !widget.viewModel.isPhotoResult
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: Center(
                              child: EmptySearch(
                                  searchedSpecies: _searchController.text),
                            ),
                          ),
                        )
                      : SizedBox(),
                  ...List.generate(widget.viewModel.result.length, (index) {
                    SpeciesSearcherPartialResult species =
                        widget.viewModel.result[index];
                    dynamic idOrExternal =
                        species.speciesCompanion.dataSource.value ==
                                SpeciesDataSource.custom
                            ? species.speciesCompanion.id.value
                            : species;
                    return GestureDetector(
                      onTap: () => context.push(Routes.speciesWithIdOrExternal,
                          extra: idOrExternal),
                      child: SpeciesCard(
                        key: UniqueKey(),
                        speciesSearcherResult: species,
                        viewModel: widget.viewModel,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
    );
  }
}
