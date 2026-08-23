import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../data/database/database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final AppDatabase db;
  final String shopName;
  final VoidCallback onUnlocked;

  const LoginScreen({
    super.key,
    required this.db,
    required this.shopName,
    required this.onUnlocked,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final SettingsRepository _repo = SettingsRepository(widget.db);
  final _passwordController = TextEditingController();
  String? _error;
  bool _checking = false;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _checking = true;
      _error = null;
    });

    final correct = await _repo.verifyPassword(_passwordController.text);
    if (!mounted) return;

    setState(() => _checking = false);

    if (correct) {
      widget.onUnlocked();
    } else {
      setState(() => _error = l10n.incorrectPassword);
      _passwordController.clear();
    }
  }

  Future<void> _openRecoveryFlow() async {
    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RecoveryDialog(repo: _repo),
    );
    if (unlocked == true) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.shopName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _checking ? null : _submit,
                    child: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.unlockAction),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _checking ? null : _openRecoveryFlow,
                  child: Text(l10n.forgotPasswordAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RecoveryStep { choose, question, code, newPassword, showNewCode, unavailable }

class _RecoveryDialog extends StatefulWidget {
  final SettingsRepository repo;
  const _RecoveryDialog({required this.repo});

  @override
  State<_RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends State<_RecoveryDialog> {
  _RecoveryStep _step = _RecoveryStep.choose;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _securityQuestion;
  String? _newCode;
  var _codeAcknowledged = false;

  final _answerController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final hasOptions = await widget.repo.hasRecoveryOptions();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _step = hasOptions ? _RecoveryStep.choose : _RecoveryStep.unavailable;
    });
  }

  Future<void> _chooseQuestion() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final question = await widget.repo.getSecurityQuestion();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _securityQuestion = question;
      _step = _RecoveryStep.question;
    });
  }

  void _chooseCode() {
    setState(() {
      _error = null;
      _step = _RecoveryStep.code;
    });
  }

  Future<void> _verifyAnswer() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.repo.verifySecurityAnswer(_answerController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        _step = _RecoveryStep.newPassword;
      } else {
        _error = l10n.recoveryIncorrectAnswer;
      }
    });
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.repo.verifyRecoveryCode(_codeController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        _step = _RecoveryStep.newPassword;
      } else {
        _error = l10n.recoveryIncorrectCode;
      }
    });
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_newPasswordController.text.isEmpty) {
      setState(() => _error = l10n.enterNewPassword);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = l10n.passwordsDoNotMatch);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final newCode = await widget.repo.resetPasswordAfterRecovery(_newPasswordController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _newCode = newCode;
      _step = _RecoveryStep.showNewCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const AlertDialog(
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      );
    }

    switch (_step) {
      case _RecoveryStep.choose:
        return AlertDialog(
          title: Text(l10n.recoveryChooseMethodTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.quiz_outlined),
                  title: Text(l10n.recoveryMethodQuestion),
                  onTap: _chooseQuestion,
                ),
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: Text(l10n.recoveryMethodCode),
                  onTap: _chooseCode,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ],
        );

      case _RecoveryStep.question:
        return AlertDialog(
          title: Text(l10n.recoveryMethodQuestion),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_securityQuestion ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(labelText: l10n.securityAnswerLabel),
                  onSubmitted: (_) => _verifyAnswer(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(onPressed: _busy ? null : _verifyAnswer, child: Text(l10n.verifyAction)),
          ],
        );

      case _RecoveryStep.code:
        return AlertDialog(
          title: Text(l10n.recoveryMethodCode),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.recoveryCodeFieldLabel),
                  onSubmitted: (_) => _verifyCode(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(onPressed: _busy ? null : _verifyCode, child: Text(l10n.verifyAction)),
          ],
        );

      case _RecoveryStep.newPassword:
        return AlertDialog(
          title: Text(l10n.recoveryNewPasswordTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.confirmNewPasswordLabel),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(onPressed: _busy ? null : _resetPassword, child: Text(l10n.save)),
          ],
        );

      case _RecoveryStep.showNewCode:
        return AlertDialog(
          title: Text(l10n.recoveryCodeDialogTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.recoveryCodeSaveWarning),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _newCode ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _newCode ?? ''));
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
                  value: _codeAcknowledged,
                  onChanged: (v) => setState(() => _codeAcknowledged = v ?? false),
                  title: Text(l10n.recoveryCodeAckCheckbox),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: _codeAcknowledged ? () => Navigator.pop(context, true) : null,
              child: Text(l10n.continueAction),
            ),
          ],
        );

      case _RecoveryStep.unavailable:
        return AlertDialog(
          title: Text(l10n.recoveryNotAvailableTitle),
          content: SizedBox(width: 320, child: Text(l10n.recoveryNotAvailableMessage)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
          ],
        );
    }
  }
}
