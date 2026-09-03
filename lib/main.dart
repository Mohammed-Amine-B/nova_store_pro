import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nova_pro/l10n/generated/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/confirm_dialog.dart';
import 'data/database/database.dart';
import 'data/repositories/settings_repository.dart';
import 'utils/backup.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/customers/customers_screen.dart';
import 'screens/today_sales/today_sales_screen.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/returns/returns_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/activity_log/activity_log_screen.dart';

const _singleInstancePort = 48291; // arbitrary fixed local port, unlikely to collide with anything else
// ignore: unused_element
ServerSocket? _singleInstanceServer;

Future<bool> _acquireSingleInstanceLock() async {
  try {
    // Kept alive for the app's lifetime in the top-level variable so the port stays held.
    _singleInstanceServer = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      _singleInstancePort,
    );
    return true;
  } catch (_) {
    return false; // port already bound = another instance is already running
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final acquired = await _acquireSingleInstanceLock();
  if (!acquired) {
    exit(0); // another instance is already running — quit immediately, don't open a second window
  }
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  runApp(NovaStoreApp(db: AppDatabase()));
}

class NovaStoreApp extends StatefulWidget {
  final AppDatabase db;
  const NovaStoreApp({super.key, required this.db});

  @override
  State<NovaStoreApp> createState() => _NovaStoreAppState();
}

class _NovaStoreAppState extends State<NovaStoreApp> with WindowListener {
  late final SettingsRepository _settingsRepo = SettingsRepository(widget.db);
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  String _shopName = 'Nova Store';
  String _fontSize = 'medium';
  bool _loading = true;
  bool _unlocked = false;
  final _todaySalesSearchFocusNode = FocusNode();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appScaffoldKey = GlobalKey<AppScaffoldState>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadSettings();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _todaySalesSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context)!;
    final shouldExit = await ConfirmDialog.show(
      context,
      title: l10n.exitConfirmTitle,
      message: l10n.exitConfirmMessage,
      confirmLabel: l10n.exitConfirmButton,
      tone: ConfirmTone.destructive,
      icon: Icons.logout,
    );
    if (shouldExit) {
      await widget.db.close();
      await windowManager.destroy();
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepo.getSettings();
    if (!mounted) return;
    setState(() {
      _shopName = settings.shopName;
      _themeMode = _parseThemeMode(settings.themeMode);
      _locale = Locale(settings.language);
      _fontSize = settings.fontSize;
      _unlocked =
          settings.appPasswordHash == null || settings.appPasswordHash!.isEmpty;
      _loading = false;
    });
    // Fire-and-forget: never block or slow down startup, and stay silent on
    // success — it's a no-op unless a backup destination is set and due.
    runAutoBackupIfDue(widget.db, _settingsRepo);
  }

  ThemeMode _parseThemeMode(String mode) => switch (mode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  void _onThemeModeChanged(String mode) {
    setState(() => _themeMode = _parseThemeMode(mode));
  }

  void _onShopNameChanged(String name) {
    setState(() => _shopName = name);
  }

  void _onLanguageChanged(String languageCode) {
    setState(() => _locale = Locale(languageCode));
  }

  void _onFontSizeChanged(String size) {
    setState(() => _fontSize = size);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    final isArabic = _locale.languageCode == 'ar';
    final fontWeight = isArabic ? FontWeight.w400 : FontWeight.w700;
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: AppTheme.light.copyWith(
        textTheme: _withScale(
          _withWeight(AppTheme.light.textTheme, fontWeight),
          _scaleForFontSize(_fontSize),
        ),
      ),
      darkTheme: AppTheme.dark.copyWith(
        textTheme: _withScale(
          _withWeight(AppTheme.dark.textTheme, fontWeight),
          _scaleForFontSize(_fontSize),
        ),
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
      home: _unlocked
          ? AppScaffold(
              key: _appScaffoldKey,
              shopName: _shopName,
              newSaleTabIndex: 5, // TodaySalesScreen's index in `pages` below
              newSaleSearchFocusNode: _todaySalesSearchFocusNode,
              pages: [
                DashboardScreen(
                  db: widget.db,
                  onNewSale: () => _appScaffoldKey.currentState?.openNewSale(),
                  onViewReports: () =>
                      _appScaffoldKey.currentState?.switchToTab(8), // ReportsScreen's index in `pages` below
                ),
                ProductsScreen(db: widget.db),
                SuppliersScreen(db: widget.db),
                CustomersScreen(db: widget.db),
                CategoriesScreen(db: widget.db),
                TodaySalesScreen(
                  db: widget.db,
                  searchFocusNode: _todaySalesSearchFocusNode,
                ),
                ArchiveScreen(db: widget.db),
                ReturnsScreen(db: widget.db),
                ReportsScreen(db: widget.db),
                InsightsScreen(db: widget.db),
                ActivityLogScreen(db: widget.db),
                SettingsScreen(
                  db: widget.db,
                  onThemeModeChanged: _onThemeModeChanged,
                  onShopNameChanged: _onShopNameChanged,
                  onLanguageChanged: _onLanguageChanged,
                  fontSize: _fontSize,
                  onFontSizeChanged: _onFontSizeChanged,
                ),
              ],
            )
          : LoginScreen(
              db: widget.db,
              shopName: _shopName,
              onUnlocked: () => setState(() => _unlocked = true),
            ),
    );
  }
}

double _scaleForFontSize(String size) => switch (size) {
  'small' => 0.8,
  'large' => 1,
  _ => 0.9, // medium = current baseline, unchanged
};

TextTheme _withScale(TextTheme t, double scale) {
  TextStyle? s(TextStyle? style) =>
      style?.copyWith(fontSize: (style.fontSize ?? 14) * scale);
  return t.copyWith(
    displayLarge: s(t.displayLarge),
    displayMedium: s(t.displayMedium),
    displaySmall: s(t.displaySmall),
    headlineLarge: s(t.headlineLarge),
    headlineMedium: s(t.headlineMedium),
    headlineSmall: s(t.headlineSmall),
    titleLarge: s(t.titleLarge),
    titleMedium: s(t.titleMedium),
    titleSmall: s(t.titleSmall),
    bodyLarge: s(t.bodyLarge),
    bodyMedium: s(t.bodyMedium),
    bodySmall: s(t.bodySmall),
    labelLarge: s(t.labelLarge),
    labelMedium: s(t.labelMedium),
    labelSmall: s(t.labelSmall),
  );
}

TextTheme _withWeight(TextTheme t, FontWeight weight) {
  TextStyle? w(TextStyle? s) => s?.copyWith(fontWeight: weight);
  return t.copyWith(
    displayLarge: w(t.displayLarge),
    displayMedium: w(t.displayMedium),
    displaySmall: w(t.displaySmall),
    headlineLarge: w(t.headlineLarge),
    headlineMedium: w(t.headlineMedium),
    headlineSmall: w(t.headlineSmall),
    titleLarge: w(t.titleLarge),
    titleMedium: w(t.titleMedium),
    titleSmall: w(t.titleSmall),
    bodyLarge: w(t.bodyLarge),
    bodyMedium: w(t.bodyMedium),
    bodySmall: w(t.bodySmall),
    labelLarge: w(t.labelLarge),
    labelMedium: w(t.labelMedium),
    labelSmall: w(t.labelSmall),
  );
}
