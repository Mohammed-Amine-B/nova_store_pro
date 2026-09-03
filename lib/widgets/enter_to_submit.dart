import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a dialog's content so pressing Enter (or the numpad Enter) triggers
/// [onSubmit] — the same action its primary/confirm button performs. Pass
/// null (e.g. while a form is invalid or already saving) to make Enter a
/// no-op, matching a disabled confirm button.
///
/// Multi-line text fields (`maxLines` > 1) keep inserting a newline on Enter
/// as usual — Flutter only lets the key event bubble up to this shortcut
/// when the focused field doesn't already consume it itself.
///
/// [CallbackShortcuts] only sees the key press when some descendant of it
/// actually holds keyboard focus — its own node can't hold focus itself. A
/// dialog with no autofocused field (e.g. [ConfirmDialog], most numeric
/// quantity/price dialogs) would otherwise leave nothing focused, so the
/// event bubbles from the route's own focus scope — an ancestor of this
/// widget, never reached by it. The inner autofocus [Focus] node below
/// guarantees a descendant always holds focus on open; a field deeper in
/// [child] with its own `autofocus: true` still wins it back, since Flutter
/// resolves autofocus requests in registration order and descendants
/// register after ancestors.
class EnterToSubmit extends StatelessWidget {
  final VoidCallback? onSubmit;
  final Widget child;

  const EnterToSubmit({super.key, required this.onSubmit, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.enter): () => onSubmit?.call(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): () => onSubmit?.call(),
      },
      child: Focus(autofocus: true, skipTraversal: true, child: child),
    );
  }
}
