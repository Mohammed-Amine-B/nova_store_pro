import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final ValueChanged<String> onThemeModeChanged; // 'light' | 'dark' | 'system'
  final ValueChanged<String> onShopNameChanged;
  final ValueChanged<String> onLanguageChanged; // 'en' | 'ar' | 'fr'

  const SettingsScreen({
    super.key,
    required this.db,
    required this.onThemeModeChanged,
    required this.onShopNameChanged,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsRepository _repo = SettingsRepository(widget.db);
  final _shopNameController = TextEditingController();
  String _themeMode = 'system';
  String _language = 'en';
  bool _loading = true;
  bool _saved = false;
  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repo.getSettings();
    if (!mounted) return;
    setState(() {
      _shopNameController.text = settings.shopName;
      _themeMode = settings.themeMode;
      _language = settings.language;
      _hasPassword =
          settings.appPasswordHash != null &&
          settings.appPasswordHash!.isNotEmpty;
      _loading = false;
    });
  }

    Future<void> _openPasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
          title: Text(_hasPassword ? l10n.changePasswordDialogTitle : l10n.setPasswordDialogTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasPassword)
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.currentPasswordLabel),
                  ),
                if (_hasPassword) const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.confirmNewPasswordLabel),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (newController.text.isEmpty) {
                  setDialogState(() => error = l10n.enterNewPassword);
                  return;
                }
                if (newController.text != confirmController.text) {
                  setDialogState(() => error = l10n.passwordsDoNotMatch);
                  return;
                }
                final ok = await _repo.setPassword(
                  newController.text,
                  currentPassword: _hasPassword ? currentController.text : null,
                );
                if (ok) {
                  if (context.mounted) Navigator.pop(context);
                  setState(() => _hasPassword = true);
                } else {
                  setDialogState(() => error = l10n.currentPasswordIncorrect);
                }
              },
              child: Text(l10n.save),
            ),
          ],
          );
        },
      ),
    );
  }

  
  Future<void> _openRemovePasswordDialog() async {
    final currentController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
          title: Text(l10n.removePasswordDialogTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.currentPasswordLabel,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final ok = await _repo.removePassword(currentController.text);
                if (ok) {
                  if (context.mounted) Navigator.pop(context);
                  setState(() => _hasPassword = false);
                } else {
                  setDialogState(() => error = l10n.incorrectPassword);
                }
              },
              child: Text(l10n.removeAction),
            ),
          ],
          );
        },
      ),
    );
  }

  Future<void> _saveShopName() async {
    await _repo.updateShopName(_shopNameController.text);
    widget.onShopNameChanged(_shopNameController.text.trim());
    _flashSaved();
  }

  Future<void> _onThemeChanged(String mode) async {
    setState(() => _themeMode = mode);
    await _repo.updateThemeMode(mode);
    widget.onThemeModeChanged(mode);
    _flashSaved();
  }

  Future<void> _onLanguageChanged(String code) async {
    setState(() => _language = code);
    await _repo.updateLanguage(code);
    widget.onLanguageChanged(code);
    _flashSaved();
  }

  void _flashSaved() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.settingsTitle,
            subtitle: l10n.settingsSubtitle,
          ),
          Panel(
            title: l10n.shopNamePanel,
            description: l10n.shopNamePanelDesc,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saveShopName,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.themePanel,
            description: l10n.themePanelDesc,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'light',
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: 'dark',
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: 'system',
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                ],
                selected: {_themeMode},
                onSelectionChanged: (s) => _onThemeChanged(s.first),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.languagePanel,
            description: l10n.languagePanelDesc,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                  ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
                  ButtonSegment(value: 'fr', label: Text(l10n.languageFrench)),
                ],
                selected: {_language},
                onSelectionChanged: (s) => _onLanguageChanged(s.first),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.securityPanel,
            description: l10n.securityPanelDesc,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    _hasPassword
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                    color: _hasPassword
                        ? const Color(0xFF16A34A)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _hasPassword ? l10n.passwordIsSet : l10n.noPasswordSet,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _openPasswordDialog,
                    child: Text(_hasPassword ? l10n.changeAction : l10n.setPasswordAction),
                  ),
                  if (_hasPassword) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: _openRemovePasswordDialog,
                      child: Text(l10n.removeAction),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_saved) ...[
            const SizedBox(height: 12),
            Text(
              l10n.savedLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}
