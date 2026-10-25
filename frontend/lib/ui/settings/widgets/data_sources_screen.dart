import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/settings/view_models/settings_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

class DataSourcesScreen extends StatelessWidget {
  final SettingsViewModel viewModel;
  const DataSourcesScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).dataSources)),
      body: SafeArea(
          child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                context.push(Routes.settingsFloraCodex, extra: viewModel),
            child: ListTile(
              title: Text(L.of(context).floraCodex),
              subtitle: Text(L.of(context).configureTheFloraCodexSettings),
            ),
          ),
          ListTile(
            title: const Text("GBIF"),
            subtitle: Text(L.of(context).configureTheGbifSettings),
            onTap: () => context.push(Routes.settingsGbif, extra: viewModel),
          ),
          ListTile(
            title: const Text("Pl@ntNet"),
            subtitle: Text(L.of(context).configureThePlantNetSettings),
            onTap: () =>
                context.push(Routes.settingsPlantNet, extra: viewModel),
          ),
          ListTile(
            title: const Text("Open Plantbook"),
            subtitle: Text(L.of(context).configureTheOpenPlantbookSettings),
            onTap: () =>
                context.push(Routes.settingsOpenPlantbook, extra: viewModel),
          ),
          ListTile(
            title: Text(L.of(context).aiCare),
            subtitle: Text(L.of(context).configureTheAiCareSettings),
            onTap: () => context.push(Routes.settingsAiCare, extra: viewModel),
          ),
        ],
      )),
    );
  }
}

class FloraCodexScreen extends StatelessWidget {
  final SettingsViewModel viewModel;
  final Workmanager workmanager;

  const FloraCodexScreen({
    super.key,
    required this.workmanager,
    required this.viewModel,
  });

  Future<String?> _showApiKeyDialog(
      BuildContext context, String? initialValue) async {
    TextEditingController controller =
        TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(L.of(context).insertTheFloraCodexApiKey),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: L.of(context).enterApiKey),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(L.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                String apiKey = controller.text.trim();
                if (apiKey.isNotEmpty) {
                  viewModel.save.executeWithFuture({
                    UserSettingsKeys.floraCodexKey.key: apiKey,
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(L.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).floraCodex)),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: viewModel.save.results,
              builder: (context, value, child) {
                String? apiKey =
                    viewModel.get(UserSettingsKeys.floraCodexKey.key);
                bool useFloraCodex =
                    viewModel.get(UserSettingsKeys.useFloraCodex.key) == "true";
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          L.of(context).floraCodexDescription,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          launchUrl(
                              Uri.parse("https://floracodex.com/auth/sign-up"));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  L.of(context).floraCodexGetApiKey,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                LucideIcons.external_link,
                                color: Theme.of(context).colorScheme.primary,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(L.of(context).enableDataSource),
                        value: useFloraCodex,
                        onChanged: (bool value) {
                          viewModel.save.execute({
                            UserSettingsKeys.useFloraCodex.key:
                                (!useFloraCodex).toString()
                          });
                        },
                      ),
                      ListTile(
                        title: Text(L.of(context).apiKey),
                        subtitle: (apiKey ?? "").isEmpty
                            ? Text(L.of(context).notProvided)
                            : Text(
                                "${apiKey!.substring(0, min(5, apiKey.length))}..."),
                        trailing: const Icon(Icons.arrow_forward),
                        enabled: useFloraCodex,
                        onTap: () => _showApiKeyDialog(context, apiKey),
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}

/// Description of a data source followed by a link to get its credentials.
class _SourceDescription extends StatelessWidget {
  final String description;
  final String linkText;
  final String url;

  const _SourceDescription({
    required this.description,
    required this.linkText,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(description),
        ),
        const SizedBox(height: 8),
        _SourceLink(text: linkText, url: url),
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  final String text;
  final String url;

  const _SourceLink({required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              LucideIcons.external_link,
              color: Theme.of(context).colorScheme.primary,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

/// A setting edited with a text dialog. Secrets only show their first
/// characters.
class _TextSettingTile extends StatelessWidget {
  final SettingsViewModel viewModel;
  final String settingKey;
  final String title;
  final String dialogTitle;
  final String? emptySubtitle;
  final bool secret;

  const _TextSettingTile({
    required this.viewModel,
    required this.settingKey,
    required this.title,
    required this.dialogTitle,
    this.emptySubtitle,
    this.secret = true,
  });

  Future<void> _showDialog(BuildContext context, String? initialValue) {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: title),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await viewModel.save.executeWithFuture({
                  settingKey: controller.text.trim(),
                });
                // Cached species details were built with the old settings
                viewModel.clearCache.execute();
              },
              child: Text(L.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? value = viewModel.get(settingKey);
    String subtitle;
    if ((value ?? "").isEmpty) {
      subtitle = emptySubtitle ?? L.of(context).notProvided;
    } else if (secret) {
      subtitle = "${value!.substring(0, min(5, value.length))}...";
    } else {
      subtitle = value!;
    }
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => _showDialog(context, value),
    );
  }
}

class GbifScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const GbifScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GBIF")),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: viewModel.save.results,
              builder: (context, value, child) {
                bool useGbif =
                    viewModel.get(UserSettingsKeys.useGbif.key) != "false";
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SourceDescription(
                        description: L.of(context).gbifDescription,
                        linkText: "gbif.org",
                        url: "https://www.gbif.org",
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(L.of(context).enableDataSource),
                        value: useGbif,
                        onChanged: (bool value) {
                          viewModel.save.execute(
                              {UserSettingsKeys.useGbif.key: value.toString()});
                          viewModel.clearCache.execute();
                        },
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}

class PlantNetScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const PlantNetScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pl@ntNet")),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: viewModel.save.results,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SourceDescription(
                        description: L.of(context).plantNetDescription,
                        linkText: L.of(context).plantNetGetApiKey,
                        url: "https://my.plantnet.org/",
                      ),
                      const SizedBox(height: 16),
                      _TextSettingTile(
                        viewModel: viewModel,
                        settingKey: UserSettingsKeys.plantNetKey.key,
                        title: L.of(context).apiKey,
                        dialogTitle: L.of(context).insertThePlantNetApiKey,
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}

class OpenPlantbookScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const OpenPlantbookScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Open Plantbook")),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: viewModel.save.results,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SourceDescription(
                        description: L.of(context).openPlantbookDescription,
                        linkText: L.of(context).openPlantbookGetCredentials,
                        url: "https://open.plantbook.io/",
                      ),
                      const SizedBox(height: 16),
                      _TextSettingTile(
                        viewModel: viewModel,
                        settingKey: UserSettingsKeys.plantbookClientId.key,
                        title: L.of(context).clientId,
                        dialogTitle: L.of(context).clientId,
                        secret: false,
                      ),
                      _TextSettingTile(
                        viewModel: viewModel,
                        settingKey: UserSettingsKeys.plantbookClientSecret.key,
                        title: L.of(context).clientSecret,
                        dialogTitle: L.of(context).clientSecret,
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}

class AiCareScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const AiCareScreen({super.key, required this.viewModel});

  String _hint(BuildContext context, AiProvider provider) => switch (provider) {
        AiProvider.none => "",
        AiProvider.claude => L.of(context).aiProviderClaudeHint,
        AiProvider.gemini => L.of(context).aiProviderGeminiHint,
        AiProvider.githubModels => L.of(context).aiProviderGitHubModelsHint,
      };

  String _keyUrl(AiProvider provider) => switch (provider) {
        AiProvider.none => "",
        AiProvider.claude => "https://platform.claude.com/",
        AiProvider.gemini => "https://aistudio.google.com/apikey",
        AiProvider.githubModels =>
          "https://github.com/settings/personal-access-tokens/new",
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).aiCare)),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: viewModel.save.results,
              builder: (context, value, child) {
                AiProvider selected = AiProvider.fromKey(
                    viewModel.get(UserSettingsKeys.aiProvider.key));
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(L.of(context).aiCareDescription),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        L.of(context).aiProvider,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...AiProvider.values
                        .map((provider) => RadioListTile<AiProvider>(
                              value: provider,
                              groupValue: selected,
                              onChanged: (AiProvider? provider) {
                                if (provider == null) return;
                                viewModel.save.execute({
                                  UserSettingsKeys.aiProvider.key: provider.key,
                                });
                                viewModel.clearCache.execute();
                              },
                              title: Text(provider == AiProvider.none
                                  ? L.of(context).aiProviderNone
                                  : provider.displayName),
                              subtitle: provider == AiProvider.none
                                  ? null
                                  : Text(_hint(context, provider)),
                            )),
                    if (selected != AiProvider.none) ...[
                      const SizedBox(height: 8),
                      _TextSettingTile(
                        viewModel: viewModel,
                        settingKey: selected.keySetting!.key,
                        title: L.of(context).apiKey,
                        dialogTitle: L.of(context).enterApiKey,
                      ),
                      _TextSettingTile(
                        viewModel: viewModel,
                        settingKey: selected.modelSetting!.key,
                        title: L.of(context).aiModel,
                        dialogTitle: L.of(context).insertTheAiModel,
                        emptySubtitle:
                            L.of(context).aiModelDefault(selected.defaultModel),
                        secret: false,
                      ),
                      _SourceLink(
                        text: L.of(context).getApiKeyClickHere,
                        url: _keyUrl(selected),
                      ),
                    ],
                  ],
                );
              })),
    );
  }
}
