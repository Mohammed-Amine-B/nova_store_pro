import 'package:flutter/material.dart';

/// Wraps horizontally-scrollable content (typically a wide [DataTable]) with
/// an always-visible, draggable scrollbar.
///
/// Mouse users have no touchpad-style horizontal swipe gesture and a plain
/// scroll wheel doesn't pan sideways, so every wide table needs an explicit,
/// grabbable scrollbar thumb.
class HorizontalScrollTable extends StatefulWidget {
  final Widget child;
  const HorizontalScrollTable({super.key, required this.child});

  @override
  State<HorizontalScrollTable> createState() => _HorizontalScrollTableState();
}

class _HorizontalScrollTableState extends State<HorizontalScrollTable> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}
