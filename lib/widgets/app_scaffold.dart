import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'app_sidebar.dart';

class AppScaffold extends StatefulWidget {
  final String shopName;
  final List<Widget> pages; // one widget per nav item, same order as navItems
  final int?
  newSaleTabIndex; // index of Today Sales in [pages]; null disables Ctrl+N
  final FocusNode? newSaleSearchFocusNode; // focused once Today Sales is shown

  const AppScaffold({
    super.key,
    required this.shopName,
    required this.pages,
    this.newSaleTabIndex,
    this.newSaleSearchFocusNode,
  });

  @override
  State<AppScaffold> createState() => AppScaffoldState();
}

class AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  /// Switches to the Today Sales tab and focuses its search field — same
  /// action as the Ctrl+N shortcut. Public so other pages (e.g. a Dashboard
  /// "New Sale" quick action) can trigger it via a `GlobalKey<AppScaffoldState>`.
  void openNewSale() {
    final tabIndex = widget.newSaleTabIndex;
    final focusNode = widget.newSaleSearchFocusNode;
    if (tabIndex == null || focusNode == null) return;
    if (_selectedIndex == tabIndex) {
      focusNode.requestFocus();
      return;
    }
    setState(() => _selectedIndex = tabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  /// Switches to an arbitrary tab by its index in [AppScaffold.pages] — for
  /// quick-action shortcuts elsewhere that need to jump to a specific page
  /// (e.g. Reports) without going through the sidebar.
  void switchToTab(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            openNewSale,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSidebar(
                shopName: widget.shopName,
                selectedIndex: _selectedIndex,
                onSelect: (i) => setState(() => _selectedIndex = i),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(32),
                  child: Navigator(
                    key: ValueKey(
                      _selectedIndex,
                    ), // resets the stack when switching tabs
                    onGenerateRoute: (settings) => MaterialPageRoute(
                      // Escape pops whatever's pushed on THIS tab's own nested
                      // Navigator (e.g. a detail screen) — routeContext is a
                      // descendant of this Navigator, not the app's root one,
                      // so Navigator.of(routeContext) resolves to the right
                      // stack. Dialogs (showDialog) live on the root Navigator
                      // and already close on Escape via Flutter's own
                      // barrierDismissible handling — untouched here.
                      builder: (routeContext) => CallbackShortcuts(
                        bindings: {
                          LogicalKeySet(LogicalKeyboardKey.escape): () {
                            final nav = Navigator.of(routeContext);
                            if (nav.canPop()) nav.pop();
                          },
                        },
                        child: widget.pages[_selectedIndex],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
