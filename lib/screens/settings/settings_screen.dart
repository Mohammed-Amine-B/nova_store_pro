import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../../data/database/database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/backup.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

List<String> securityQuestionOptions(AppLocalizations l10n) => [
  l10n.securityQuestionShopName,
  l10n.securityQuestionMotherName,
  l10n.securityQuestionBirthCity,
  l10n.securityQuestionFirstPet,
  l10n.securityQuestionFavoriteProduct,
];

class SettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final ValueChanged<String> onThemeModeChanged; // 'light' | 'dark' | 'system'
  final ValueChanged<String> onShopNameChanged;
  final ValueChanged<String> onLanguageChanged; // 'en' | 'ar' | 'fr'
  final String fontSize; // 'small' | 'medium' | 'large'
  final ValueChanged<String> onFontSizeChanged;

  const SettingsScreen({
    super.key,
    required this.db,
    required this.onThemeModeChanged,
    required this.onShopNameChanged,
    required this.onLanguageChanged,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsRepository _repo = SettingsRepository(widget.db);
  final _shopNameController = TextEditingController();
  String _themeMode = 'system';
  String _language = 'en';
  String _fontSize = 'medium';
  bool _loading = true;
  bool _saved = false;
  bool _hasPassword = false;
  bool _backingUp = false;

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
      _fontSize = settings.fontSize;
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
    final securityAnswerController = TextEditingController();
    String? selectedSecurityQuestion;
    String? error;

    final result = await showDialog<SetPasswordResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(
              _hasPassword
                  ? l10n.changePasswordDialogTitle
                  : l10n.setPasswordDialogTitle,
            ),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasPassword)
                      TextField(
                        controller: currentController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.currentPasswordLabel,
                        ),
                      ),
                    if (_hasPassword) const SizedBox(height: 12),
                    TextField(
                      controller: newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.newPasswordLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.confirmNewPasswordLabel,
                      ),
                    ),
                    if (!_hasPassword) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSecurityQuestion,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.securityQuestionLabel,
                        ),
                        items: securityQuestionOptions(l10n)
                            .map(
                              (q) => DropdownMenuItem(
                                value: q,
                                child: Text(q, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedSecurityQuestion = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: securityAnswerController,
                        decoration: InputDecoration(
                          labelText: l10n.securityAnswerLabel,
                        ),
                      ),
                    ],
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
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
                  if (!_hasPassword) {
                    if (selectedSecurityQuestion == null) {
                      setDialogState(
                        () => error = l10n.securityQuestionRequired,
                      );
                      return;
                    }
                    if (securityAnswerController.text.trim().isEmpty) {
                      setDialogState(() => error = l10n.securityAnswerRequired);
                      return;
                    }
                  }
                  final setResult = await _repo.setPassword(
                    newController.text,
                    currentPassword: _hasPassword
                        ? currentController.text
                        : null,
                    securityQuestion: _hasPassword
                        ? null
                        : selectedSecurityQuestion,
                    securityAnswer: _hasPassword
                        ? null
                        : securityAnswerController.text,
                  );
                  if (setResult.success) {
                    if (context.mounted) Navigator.pop(context, setResult);
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

    if (result != null && result.success) {
      setState(() => _hasPassword = true);
      if (result.recoveryCode != null && mounted) {
        await _showRecoveryCodeDialog(result.recoveryCode!);
      }
    }
  }

  Future<void> _showRecoveryCodeDialog(String code) async {
    var acknowledged = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.recoveryCodeDialogTitle),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.recoveryCodeSaveWarning),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.codeCopiedMessage)),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined, size: 20),
                            tooltip: l10n.copyCodeAction,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: acknowledged,
                      onChanged: (v) =>
                          setDialogState(() => acknowledged = v ?? false),
                      title: Text(l10n.recoveryCodeAckCheckbox),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: acknowledged ? () => Navigator.pop(context) : null,
                child: Text(l10n.continueAction),
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
              child: SingleChildScrollView(
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

  Future<void> _onFontSizeSelected(String size) async {
    setState(() => _fontSize = size);
    await _repo.updateFontSize(size);
    widget.onFontSizeChanged(size);
    _flashSaved();
  }

  void _flashSaved() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _backupNow() async {
    setState(() => _backingUp = true);
    try {
      final zipPath = await createBackup();
      if (!mounted) return;
      setState(() => _backingUp = false);
      await _showBackupResultDialog(zipPath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _backingUp = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _openContainingFolder(String zipPath) async {
    try {
      final folder = File(zipPath).parent.path;
      if (Platform.isLinux) {
        await Process.run('xdg-open', [folder]);
      } else if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,$zipPath']);
      }
    } catch (_) {
      // Best-effort only — the path is already shown as selectable text either way.
    }
  }

  Future<void> _showBackupResultDialog(String zipPath) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Created'),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your backup was saved to:'),
                const SizedBox(height: 8),
                SelectableText(
                  zipPath,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Clipboard.setData(ClipboardData(text: zipPath)),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Path'),
          ),
          if (Platform.isLinux || Platform.isWindows)
            TextButton.icon(
              onPressed: () => _openContainingFolder(zipPath),
              icon: const Icon(Icons.folder_open, size: 16),
              label: const Text('Show in Folder'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
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
            title: l10n.fontSizePanel,
            description: l10n.fontSizePanelDesc,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'small',
                    label: Text(l10n.fontSizeSmall),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text(l10n.fontSizeMedium),
                  ),
                  ButtonSegment(
                    value: 'large',
                    label: Text(l10n.fontSizeLarge),
                  ),
                ],
                selected: {_fontSize},
                onSelectionChanged: (s) => _onFontSizeSelected(s.first),
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
                    child: Text(
                      _hasPassword ? l10n.changeAction : l10n.setPasswordAction,
                    ),
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
          const SizedBox(height: 20),
          Panel(
            title: 'Backup',
            description:
                'Save a copy of your database and product photos for safekeeping.',
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.backup_outlined, color: Color(0xFF0E7C7B)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Creates a dated .zip you can save to a USB drive or cloud folder.',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _backingUp ? null : _backupNow,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7C7B),
                    ),
                    icon: _backingUp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.backup_outlined, size: 18),
                    label: const Text('Backup Now'),
                  ),
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
