import 'package:flutter/material.dart';
import 'app_sidebar.dart';

class AppScaffold extends StatefulWidget {
  final String shopName;
  final List<Widget> pages; // one widget per nav item, same order as navItems

  const AppScaffold({
    super.key,
    required this.shopName,
    required this.pages,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      key: ValueKey(_selectedIndex), // resets the stack when switching tabs
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => widget.pages[_selectedIndex],
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}