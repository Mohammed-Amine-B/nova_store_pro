import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nova Store'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get navTodaySales;

  /// No description provided for @navArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get navArchive;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store overview'**
  String get dashboardSubtitle;

  /// No description provided for @statProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get statProducts;

  /// No description provided for @statCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statCategories;

  /// No description provided for @statTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get statTodaySales;

  /// No description provided for @statLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get statLowStock;

  /// No description provided for @salesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sales'**
  String salesCount(int count);

  /// No description provided for @lowStockPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Products'**
  String get lowStockPanelTitle;

  /// No description provided for @lowStockPanelDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} products need restocking'**
  String lowStockPanelDesc(int count);

  /// No description provided for @noLowStockProducts.
  ///
  /// In en, this message translates to:
  /// **'No low stock products'**
  String get noLowStockProducts;

  /// No description provided for @unitsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String unitsLeft(String count);

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your full shop catalogue'**
  String get productsSubtitle;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @statTotalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get statTotalProducts;

  /// No description provided for @statTotalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total Units In Stock'**
  String get statTotalUnits;

  /// No description provided for @statStockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get statStockValue;

  /// No description provided for @atBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'At buy price'**
  String get atBuyPrice;

  /// No description provided for @allProductsPanel.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProductsPanel;

  /// No description provided for @shownOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} shown'**
  String shownOfTotal(int shown, int total);

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, code, or barcode'**
  String get searchProductsHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get filterLowStock;

  /// No description provided for @filterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get filterOutOfStock;

  /// No description provided for @colProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get colProductName;

  /// No description provided for @colBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get colBarcode;

  /// No description provided for @colCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get colCategory;

  /// No description provided for @colSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get colSellingPrice;

  /// No description provided for @colCurrentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get colCurrentStock;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @statusInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get statusInStock;

  /// No description provided for @statusLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get statusLowStock;

  /// No description provided for @statusOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get statusOutOfStock;

  /// No description provided for @noProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your filters.'**
  String get noProductsMatch;

  /// No description provided for @removeProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove product?'**
  String get removeProductTitle;

  /// No description provided for @removeProductMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be archived and hidden from the catalogue.'**
  String removeProductMessage(String name);

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productNameLabel;

  /// No description provided for @productCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get productCodeLabel;

  /// No description provided for @barcodeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get barcodeOptionalLabel;

  /// No description provided for @categoryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptionalLabel;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @lowStockThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Low stock threshold'**
  String get lowStockThresholdLabel;

  /// No description provided for @variantSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size (optional)'**
  String get variantSizeLabel;

  /// No description provided for @variantSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 4mm, Large, 1kg'**
  String get variantSizeHint;

  /// No description provided for @variantsPanel.
  ///
  /// In en, this message translates to:
  /// **'Other Sizes'**
  String get variantsPanel;

  /// No description provided for @variantsPanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Other products in the same variant group'**
  String get variantsPanelDesc;

  /// No description provided for @unitTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Type'**
  String get unitTypeLabel;

  /// No description provided for @unitTypePiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitTypePiece;

  /// No description provided for @unitTypeKg.
  ///
  /// In en, this message translates to:
  /// **'Kilogram (kg)'**
  String get unitTypeKg;

  /// No description provided for @unitTypeMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter (m)'**
  String get unitTypeMeter;

  /// No description provided for @productInfoPanel.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInfoPanel;

  /// No description provided for @minimumStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock'**
  String get minimumStockLabel;

  /// No description provided for @batchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get batchesLabel;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @sellingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPriceLabel;

  /// No description provided for @costPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPriceLabel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @batchesPanelDesc.
  ///
  /// In en, this message translates to:
  /// **'FIFO — oldest batch is sold first'**
  String get batchesPanelDesc;

  /// No description provided for @noBatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No inventory yet. Use \"Add Stock\" to record the first batch.'**
  String get noBatchesYet;

  /// No description provided for @colBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get colBatch;

  /// No description provided for @colBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy Price'**
  String get colBuyPrice;

  /// No description provided for @colRemainingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Remaining Quantity'**
  String get colRemainingQuantity;

  /// No description provided for @colPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get colPurchaseDate;

  /// No description provided for @nextOutTag.
  ///
  /// In en, this message translates to:
  /// **'NEXT OUT'**
  String get nextOutTag;

  /// No description provided for @quickActionsPanel.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsPanel;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// No description provided for @viewStockMovements.
  ///
  /// In en, this message translates to:
  /// **'View Stock Movements'**
  String get viewStockMovements;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @buyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy Price'**
  String get buyPriceLabel;

  /// No description provided for @sellingPriceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPriceFieldLabel;

  /// No description provided for @purchaseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDateLabel;

  /// No description provided for @stockMovementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Movements'**
  String get stockMovementsTitle;

  /// No description provided for @noMovementsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No movements recorded.'**
  String get noMovementsRecorded;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String categoriesCount(int count);

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @allCategoriesPanel.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategoriesPanel;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @categoryProductsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String categoryProductsCount(int count);

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This can\'t be undone.'**
  String deleteCategoryMessage(String name);

  /// No description provided for @todaySalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get todaySalesTitle;

  /// No description provided for @addProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductLabel;

  /// No description provided for @searchToSellHint.
  ///
  /// In en, this message translates to:
  /// **'Search a product to sell...'**
  String get searchToSellHint;

  /// No description provided for @salesTodayPanel.
  ///
  /// In en, this message translates to:
  /// **'Sales Today'**
  String get salesTodayPanel;

  /// No description provided for @colProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get colProduct;

  /// No description provided for @colQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get colQuantity;

  /// No description provided for @colUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get colUnitPrice;

  /// No description provided for @colTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get colTotal;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get statRevenue;

  /// No description provided for @statProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get statProfit;

  /// No description provided for @statSoldItems.
  ///
  /// In en, this message translates to:
  /// **'Sold Items'**
  String get statSoldItems;

  /// No description provided for @fifoHint.
  ///
  /// In en, this message translates to:
  /// **'FIFO'**
  String get fifoHint;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @inStockCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String inStockCount(String count);

  /// No description provided for @addSaleAction.
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get addSaleAction;

  /// No description provided for @enterValidQuantityPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity and price'**
  String get enterValidQuantityPrice;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTitle;

  /// No description provided for @archiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past trading days'**
  String get archiveSubtitle;

  /// No description provided for @salesHistoryPanel.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get salesHistoryPanel;

  /// No description provided for @daysRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} days recorded'**
  String daysRecorded(int count);

  /// No description provided for @noArchivedDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No archived days yet.'**
  String get noArchivedDaysYet;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colSalesCount.
  ///
  /// In en, this message translates to:
  /// **'Sales Count'**
  String get colSalesCount;

  /// No description provided for @openAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAction;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(int count);

  /// No description provided for @noSalesRecordedToday.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded on this day.'**
  String get noSalesRecordedToday;

  /// No description provided for @editSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sale'**
  String get editSaleTitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete sale'**
  String get deleteSaleTitle;

  /// No description provided for @deleteSaleMessage.
  ///
  /// In en, this message translates to:
  /// **'This sale will be removed and its stock restored.'**
  String get deleteSaleMessage;

  /// No description provided for @salesForDate.
  ///
  /// In en, this message translates to:
  /// **'Sales — {date}'**
  String salesForDate(String date);

  /// No description provided for @salesPanel.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesPanel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App and store preferences'**
  String get settingsSubtitle;

  /// No description provided for @shopNamePanel.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopNamePanel;

  /// No description provided for @shopNamePanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Shown in the sidebar and used on receipts'**
  String get shopNamePanelDesc;

  /// No description provided for @themePanel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themePanel;

  /// No description provided for @themePanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how Nova Store looks'**
  String get themePanelDesc;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @fontSizePanel.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizePanel;

  /// No description provided for @fontSizePanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust text size across Nova Store'**
  String get fontSizePanelDesc;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @languagePanel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePanel;

  /// No description provided for @languagePanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languagePanelDesc;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel;

  /// No description provided for @viewArchived.
  ///
  /// In en, this message translates to:
  /// **'View Archived'**
  String get viewArchived;

  /// No description provided for @viewActive.
  ///
  /// In en, this message translates to:
  /// **'View Active'**
  String get viewActive;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTitle;

  /// No description provided for @suppliersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vendors you purchase stock from'**
  String get suppliersSubtitle;

  /// No description provided for @newPurchaseAction.
  ///
  /// In en, this message translates to:
  /// **'New Purchase'**
  String get newPurchaseAction;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplier;

  /// No description provided for @statTotalSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Total Suppliers'**
  String get statTotalSuppliers;

  /// No description provided for @statTotalPurchased.
  ///
  /// In en, this message translates to:
  /// **'Total Purchased'**
  String get statTotalPurchased;

  /// No description provided for @allSuppliersPanel.
  ///
  /// In en, this message translates to:
  /// **'All Suppliers'**
  String get allSuppliersPanel;

  /// No description provided for @searchSuppliersHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, location, or phone'**
  String get searchSuppliersHint;

  /// No description provided for @noSuppliersMatch.
  ///
  /// In en, this message translates to:
  /// **'No suppliers match your filters.'**
  String get noSuppliersMatch;

  /// No description provided for @colName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get colName;

  /// No description provided for @colLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get colLocation;

  /// No description provided for @colPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get colPhone;

  /// No description provided for @colOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get colOwed;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @removeSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove supplier?'**
  String get removeSupplierTitle;

  /// No description provided for @removeSupplierMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be archived and hidden from the list.'**
  String removeSupplierMessage(String name);

  /// No description provided for @recordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPaymentTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @paymentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDateLabel;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @deletePurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete purchase'**
  String get deletePurchaseTitle;

  /// No description provided for @deletePurchaseMessage.
  ///
  /// In en, this message translates to:
  /// **'This purchase will be removed and its stock reversed.'**
  String get deletePurchaseMessage;

  /// No description provided for @supplierInfoPanel.
  ///
  /// In en, this message translates to:
  /// **'Supplier Information'**
  String get supplierInfoPanel;

  /// No description provided for @purchaseHistoryPanel.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistoryPanel;

  /// No description provided for @mostRecentFirst.
  ///
  /// In en, this message translates to:
  /// **'Most recent first'**
  String get mostRecentFirst;

  /// No description provided for @noPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet from this supplier.'**
  String get noPurchasesYet;

  /// No description provided for @colItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get colItems;

  /// No description provided for @colPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get colPaid;

  /// No description provided for @colRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get colRemaining;

  /// No description provided for @editPurchaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Purchase'**
  String get editPurchaseTooltip;

  /// No description provided for @paymentsHistoryPanel.
  ///
  /// In en, this message translates to:
  /// **'Payments History'**
  String get paymentsHistoryPanel;

  /// No description provided for @paymentCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} payment(s)'**
  String paymentCountDesc(int count);

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPaymentsYet;

  /// No description provided for @supplierDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Detail'**
  String get supplierDetailFallbackTitle;

  /// No description provided for @supplierNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This supplier no longer exists.'**
  String get supplierNoLongerExists;

  /// No description provided for @selectSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get selectSupplierTitle;

  /// No description provided for @searchSuppliersEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get searchSuppliersEllipsis;

  /// No description provided for @noSuppliersFound.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found.'**
  String get noSuppliersFound;

  /// No description provided for @newSupplierAction.
  ///
  /// In en, this message translates to:
  /// **'New Supplier'**
  String get newSupplierAction;

  /// No description provided for @locationOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get locationOptionalLabel;

  /// No description provided for @phoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptionalLabel;

  /// No description provided for @supplierAddProductsPanel.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get supplierAddProductsPanel;

  /// No description provided for @searchProductToPurchaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for a product to purchase'**
  String get searchProductToPurchaseDesc;

  /// No description provided for @searchProductToAddHint.
  ///
  /// In en, this message translates to:
  /// **'Search a product to add...'**
  String get searchProductToAddHint;

  /// No description provided for @cartPanel.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartPanel;

  /// No description provided for @cartLineCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} line(s)'**
  String cartLineCountDesc(int count);

  /// No description provided for @noLinesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No lines added yet.'**
  String get noLinesAddedYet;

  /// No description provided for @searchProductAboveToStartPurchase.
  ///
  /// In en, this message translates to:
  /// **'Search a product above to start this purchase.'**
  String get searchProductAboveToStartPurchase;

  /// No description provided for @addLineAction.
  ///
  /// In en, this message translates to:
  /// **'Add Line'**
  String get addLineAction;

  /// No description provided for @summaryPanel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryPanel;

  /// No description provided for @itemsUnitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String itemsUnitsCount(String count);

  /// No description provided for @subtotalRow.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalRow;

  /// No description provided for @previousDebtRow.
  ///
  /// In en, this message translates to:
  /// **'Previous debt to this supplier'**
  String get previousDebtRow;

  /// No description provided for @totalDueRow.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get totalDueRow;

  /// No description provided for @paymentPanel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentPanel;

  /// No description provided for @toRecordPaymentHintSupplier.
  ///
  /// In en, this message translates to:
  /// **'To record a payment, use \"Record Payment\" on the supplier\'s page.'**
  String get toRecordPaymentHintSupplier;

  /// No description provided for @amountPaidRow.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaidRow;

  /// No description provided for @payFullAction.
  ///
  /// In en, this message translates to:
  /// **'Pay full'**
  String get payFullAction;

  /// No description provided for @halfNowAction.
  ///
  /// In en, this message translates to:
  /// **'Half now'**
  String get halfNowAction;

  /// No description provided for @confirmPurchaseAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchaseAction;

  /// No description provided for @editingPurchaseNum.
  ///
  /// In en, this message translates to:
  /// **'Editing purchase #{id}'**
  String editingPurchaseNum(String id);

  /// No description provided for @draftNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft · not saved yet'**
  String get draftNotSaved;

  /// No description provided for @supplierOwedSuffix.
  ///
  /// In en, this message translates to:
  /// **' · Owed {amount}'**
  String supplierOwedSuffix(String amount);

  /// No description provided for @sellingPriceRequiredFirstBatch.
  ///
  /// In en, this message translates to:
  /// **'Selling Price (required — first stock for this product)'**
  String get sellingPriceRequiredFirstBatch;

  /// No description provided for @addAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product to the cart.'**
  String get addAtLeastOneProduct;

  /// No description provided for @amountPaidRangeError.
  ///
  /// In en, this message translates to:
  /// **'Amount paid must be between 0 and the total.'**
  String get amountPaidRangeError;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @customersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People you sell to on credit'**
  String get customersSubtitle;

  /// No description provided for @newSaleAction.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSaleAction;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @statTotalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get statTotalCustomers;

  /// No description provided for @statTotalOwed.
  ///
  /// In en, this message translates to:
  /// **'Total Owed'**
  String get statTotalOwed;

  /// No description provided for @allCustomersPanel.
  ///
  /// In en, this message translates to:
  /// **'All Customers'**
  String get allCustomersPanel;

  /// No description provided for @searchCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or phone'**
  String get searchCustomersHint;

  /// No description provided for @noCustomersMatch.
  ///
  /// In en, this message translates to:
  /// **'No customers match your filters.'**
  String get noCustomersMatch;

  /// No description provided for @colBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get colBalance;

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @removeCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove customer?'**
  String get removeCustomerTitle;

  /// No description provided for @removeCustomerMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be archived and hidden from the list.'**
  String removeCustomerMessage(String name);

  /// No description provided for @newCustomerSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Customer Sale'**
  String get newCustomerSaleTitle;

  /// No description provided for @customerInfoPanel.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInfoPanel;

  /// No description provided for @memberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSinceLabel;

  /// No description provided for @remainingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalanceLabel;

  /// No description provided for @salesHistoryCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} sale(s)'**
  String salesHistoryCountDesc(int count);

  /// No description provided for @noSalesYetForCustomer.
  ///
  /// In en, this message translates to:
  /// **'No sales yet for this customer.'**
  String get noSalesYetForCustomer;

  /// No description provided for @colMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get colMethod;

  /// No description provided for @viewInvoiceTooltip.
  ///
  /// In en, this message translates to:
  /// **'View Invoice'**
  String get viewInvoiceTooltip;

  /// No description provided for @customerDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Detail'**
  String get customerDetailFallbackTitle;

  /// No description provided for @customerNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This customer no longer exists.'**
  String get customerNoLongerExists;

  /// No description provided for @selectCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomerTitle;

  /// No description provided for @searchCustomersEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomersEllipsis;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found.'**
  String get noCustomersFound;

  /// No description provided for @newCustomerAction.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomerAction;

  /// No description provided for @chooseWhoSaleFor.
  ///
  /// In en, this message translates to:
  /// **'Choose who this sale is for'**
  String get chooseWhoSaleFor;

  /// No description provided for @customerAddProductsPanel.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get customerAddProductsPanel;

  /// No description provided for @addProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'Search, scan, or tap a favourite'**
  String get addProductsDesc;

  /// No description provided for @frequentlySoldLabel.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY SOLD'**
  String get frequentlySoldLabel;

  /// No description provided for @lowStockLeftSuffix.
  ///
  /// In en, this message translates to:
  /// **'Low · {qty} left'**
  String lowStockLeftSuffix(String qty);

  /// No description provided for @tapProductAboveToStartSale.
  ///
  /// In en, this message translates to:
  /// **'Tap a product above to start this sale.'**
  String get tapProductAboveToStartSale;

  /// No description provided for @returnTooltip.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnTooltip;

  /// No description provided for @previousBalanceRow.
  ///
  /// In en, this message translates to:
  /// **'Previous balance'**
  String get previousBalanceRow;

  /// No description provided for @toRecordPaymentHintCustomer.
  ///
  /// In en, this message translates to:
  /// **'To record a payment, use \"Record Payment\" on the customer\'s page.'**
  String get toRecordPaymentHintCustomer;

  /// No description provided for @confirmSaleAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale'**
  String get confirmSaleAction;

  /// No description provided for @editingSaleNum.
  ///
  /// In en, this message translates to:
  /// **'Editing sale #{id}'**
  String editingSaleNum(String id);

  /// No description provided for @balanceSuffix.
  ///
  /// In en, this message translates to:
  /// **' · Balance {amount}'**
  String balanceSuffix(String amount);

  /// No description provided for @paymentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment updated.'**
  String get paymentUpdated;

  /// No description provided for @amountPaidUpdateRangeError.
  ///
  /// In en, this message translates to:
  /// **'Amount paid must be between 0 and the total'**
  String get amountPaidUpdateRangeError;

  /// No description provided for @returnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returnsTitle;

  /// No description provided for @returnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'History of returned items'**
  String get returnsSubtitle;

  /// No description provided for @allReturnsPanel.
  ///
  /// In en, this message translates to:
  /// **'All Returns'**
  String get allReturnsPanel;

  /// No description provided for @noReturnsYet.
  ///
  /// In en, this message translates to:
  /// **'No returns recorded yet.'**
  String get noReturnsYet;

  /// No description provided for @colSaleId.
  ///
  /// In en, this message translates to:
  /// **'Sale ID'**
  String get colSaleId;

  /// No description provided for @colReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get colReason;

  /// No description provided for @colRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get colRefunded;

  /// No description provided for @startReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Return'**
  String get startReturnTitle;

  /// No description provided for @startReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the original sale and return items'**
  String get startReturnSubtitle;

  /// No description provided for @findSalePanel.
  ///
  /// In en, this message translates to:
  /// **'Find Sale'**
  String get findSalePanel;

  /// No description provided for @recentSalesHint.
  ///
  /// In en, this message translates to:
  /// **'Recent sales shown below'**
  String get recentSalesHint;

  /// No description provided for @showRecentSalesAction.
  ///
  /// In en, this message translates to:
  /// **'Show recent sales'**
  String get showRecentSalesAction;

  /// No description provided for @returnItemsPanel.
  ///
  /// In en, this message translates to:
  /// **'Return Items'**
  String get returnItemsPanel;

  /// No description provided for @enterQtyToReturnDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity to return for each item'**
  String get enterQtyToReturnDesc;

  /// No description provided for @productHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Product #{id} — {qty} @ {price} DA'**
  String productHashLabel(String id, String qty, String price);

  /// No description provided for @returnQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Return Qty'**
  String get returnQtyLabel;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong Item'**
  String get reasonWrongItem;

  /// No description provided for @reasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed Mind'**
  String get reasonChangedMind;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @enterQtyAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity for at least one item'**
  String get enterQtyAtLeastOne;

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @confirmReturnAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get confirmReturnAction;

  /// No description provided for @unknownProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownProductLabel;

  /// No description provided for @returnLineDesc.
  ///
  /// In en, this message translates to:
  /// **'{name} — {qty} @ {price} DA'**
  String returnLineDesc(String name, String qty, String price);

  /// No description provided for @returnRecordedCashMsg.
  ///
  /// In en, this message translates to:
  /// **'Return recorded. Refund {amount} DA in cash.'**
  String returnRecordedCashMsg(String amount);

  /// No description provided for @returnRecordedDebtMsg.
  ///
  /// In en, this message translates to:
  /// **'Return recorded. Debt reduced by {amount} DA.'**
  String returnRecordedDebtMsg(String amount);

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales performance and exports'**
  String get reportsSubtitle;

  /// No description provided for @csvExportAction.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csvExportAction;

  /// No description provided for @pdfExportAction.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfExportAction;

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @rangeWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get rangeMonth;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rangeCustom;

  /// No description provided for @revenueTrendPanel.
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrendPanel;

  /// No description provided for @noSalesInRange.
  ///
  /// In en, this message translates to:
  /// **'No sales in this range.'**
  String get noSalesInRange;

  /// No description provided for @bestSellingProductsPanel.
  ///
  /// In en, this message translates to:
  /// **'Best Selling Products'**
  String get bestSellingProductsPanel;

  /// No description provided for @colUnitsSold.
  ///
  /// In en, this message translates to:
  /// **'Units Sold'**
  String get colUnitsSold;

  /// No description provided for @printSavePdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Print / Save PDF'**
  String get printSavePdfTooltip;

  /// No description provided for @invoiceHashTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice #{id}'**
  String invoiceHashTitle(String id);

  /// No description provided for @invoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sale #{id} — {date}'**
  String invoiceSubtitle(String id, String date);

  /// No description provided for @invoiceSubtitleWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'Sale #{id} — {date} — {customer}'**
  String invoiceSubtitleWithCustomer(String id, String date, String customer);

  /// No description provided for @invoiceTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String invoiceTotalLine(String amount);

  /// No description provided for @invoicePaidLine.
  ///
  /// In en, this message translates to:
  /// **'Paid: {amount}'**
  String invoicePaidLine(String amount);

  /// No description provided for @invoiceRemainingLine.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String invoiceRemainingLine(String amount);

  /// No description provided for @activityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get activityLogTitle;

  /// No description provided for @activityLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A history of important business actions'**
  String get activityLogSubtitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get catSale;

  /// No description provided for @catPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get catPurchase;

  /// No description provided for @catReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get catReturn;

  /// No description provided for @catProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catProduct;

  /// No description provided for @catCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catCategory;

  /// No description provided for @catCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get catCustomer;

  /// No description provided for @catSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get catSupplier;

  /// No description provided for @catPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get catPayment;

  /// No description provided for @entriesPanel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entriesPanel;

  /// No description provided for @recordsCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} record(s)'**
  String recordsCountDesc(int count);

  /// No description provided for @noActivityInRange.
  ///
  /// In en, this message translates to:
  /// **'No activity in this range.'**
  String get noActivityInRange;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @amountPaidHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid (leave empty for full price)'**
  String get amountPaidHintLabel;

  /// No description provided for @enterValidAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount paid'**
  String get enterValidAmountPaid;

  /// No description provided for @amountPaidExceedsTotal.
  ///
  /// In en, this message translates to:
  /// **'Amount paid cannot exceed the total'**
  String get amountPaidExceedsTotal;

  /// No description provided for @ctrlFHint.
  ///
  /// In en, this message translates to:
  /// **'Ctrl+F'**
  String get ctrlFHint;

  /// No description provided for @cropPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get cropPhotoTitle;

  /// No description provided for @croppingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Cropping...'**
  String get croppingEllipsis;

  /// No description provided for @cropSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Crop & Save'**
  String get cropSaveAction;

  /// No description provided for @couldNotCropImage.
  ///
  /// In en, this message translates to:
  /// **'Could not crop image: {cause}'**
  String couldNotCropImage(String cause);

  /// No description provided for @productDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Detail'**
  String get productDetailFallbackTitle;

  /// No description provided for @productNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This product no longer exists.'**
  String get productNoLongerExists;

  /// No description provided for @removePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get removePhotoTitle;

  /// No description provided for @removePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'The product photo will be permanently deleted.'**
  String get removePhotoMessage;

  /// No description provided for @noPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhotoLabel;

  /// No description provided for @changePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhotoAction;

  /// No description provided for @removePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhotoAction;

  /// No description provided for @batchHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch #{n}'**
  String batchHashLabel(int n);

  /// No description provided for @deletePermanentlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get deletePermanentlyTitle;

  /// No description provided for @deletePermanentlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete \"{name}\"? This cannot be undone.'**
  String deletePermanentlyMessage(String name);

  /// No description provided for @deletePermanentlyAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanentlyAction;

  /// No description provided for @securityPanel.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityPanel;

  /// No description provided for @securityPanelDesc.
  ///
  /// In en, this message translates to:
  /// **'Protect the app with a password'**
  String get securityPanelDesc;

  /// No description provided for @passwordIsSet.
  ///
  /// In en, this message translates to:
  /// **'Password is set'**
  String get passwordIsSet;

  /// No description provided for @noPasswordSet.
  ///
  /// In en, this message translates to:
  /// **'No password set'**
  String get noPasswordSet;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @setPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPasswordAction;

  /// No description provided for @setPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPasswordDialogTitle;

  /// No description provided for @changePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordDialogTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get enterNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @removePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Password'**
  String get removePasswordDialogTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @customerSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Sales'**
  String get customerSalesLabel;

  /// No description provided for @invoiceCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} invoice(s)'**
  String invoiceCountDesc(int count);

  /// No description provided for @noCustomerSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No customer sales recorded yet.'**
  String get noCustomerSalesYet;

  /// No description provided for @supplierPurchasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier Purchases'**
  String get supplierPurchasesLabel;

  /// No description provided for @purchaseCountDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} purchase(s)'**
  String purchaseCountDesc(int count);

  /// No description provided for @noSupplierPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No supplier purchases recorded yet.'**
  String get noSupplierPurchasesYet;

  /// No description provided for @colCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get colCustomer;

  /// No description provided for @invoiceAction.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceAction;

  /// No description provided for @colNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get colNote;

  /// No description provided for @colAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get colAmount;

  /// No description provided for @remainingOwedLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining Owed'**
  String get remainingOwedLabel;

  /// No description provided for @purchasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchasesLabel;

  /// No description provided for @zeroFullyOnCreditHint.
  ///
  /// In en, this message translates to:
  /// **'0 = fully on credit'**
  String get zeroFullyOnCreditHint;

  /// No description provided for @saleItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String saleItemsCount(int count);

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @csvSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String csvSavedMessage(String path);

  /// No description provided for @activityLogSaleCreated.
  ///
  /// In en, this message translates to:
  /// **'Sale of {amount} recorded'**
  String activityLogSaleCreated(String amount);

  /// No description provided for @activityLogSaleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sale #{refId} updated'**
  String activityLogSaleUpdated(int refId);

  /// No description provided for @activityLogSaleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sale #{refId} deleted, stock restored'**
  String activityLogSaleDeleted(int refId);

  /// No description provided for @activityLogPurchaseCreated.
  ///
  /// In en, this message translates to:
  /// **'Purchase of {amount} recorded from {entityName}'**
  String activityLogPurchaseCreated(String amount, String entityName);

  /// No description provided for @activityLogPurchaseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Purchase #{refId} updated'**
  String activityLogPurchaseUpdated(int refId);

  /// No description provided for @activityLogReturnCreated.
  ///
  /// In en, this message translates to:
  /// **'Return recorded for sale #{refId}, refunded {amount}'**
  String activityLogReturnCreated(int refId, String amount);

  /// No description provided for @activityLogProductCreated.
  ///
  /// In en, this message translates to:
  /// **'Product \"{entityName}\" created'**
  String activityLogProductCreated(String entityName);

  /// No description provided for @activityLogProductUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product \"{entityName}\" updated'**
  String activityLogProductUpdated(String entityName);

  /// No description provided for @activityLogProductDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product \"{entityName}\" permanently deleted'**
  String activityLogProductDeleted(String entityName);

  /// No description provided for @activityLogProductArchived.
  ///
  /// In en, this message translates to:
  /// **'Product \"{entityName}\" archived'**
  String activityLogProductArchived(String entityName);

  /// No description provided for @activityLogProductRestored.
  ///
  /// In en, this message translates to:
  /// **'Product \"{entityName}\" restored'**
  String activityLogProductRestored(String entityName);

  /// No description provided for @activityLogCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{entityName}\" created'**
  String activityLogCategoryCreated(String entityName);

  /// No description provided for @activityLogCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{entityName}\" updated'**
  String activityLogCategoryUpdated(String entityName);

  /// No description provided for @activityLogCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category \"{entityName}\" deleted'**
  String activityLogCategoryDeleted(String entityName);

  /// No description provided for @activityLogCustomerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer \"{entityName}\" created'**
  String activityLogCustomerCreated(String entityName);

  /// No description provided for @activityLogCustomerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer \"{entityName}\" updated'**
  String activityLogCustomerUpdated(String entityName);

  /// No description provided for @activityLogCustomerArchived.
  ///
  /// In en, this message translates to:
  /// **'Customer \"{entityName}\" archived'**
  String activityLogCustomerArchived(String entityName);

  /// No description provided for @activityLogCustomerRestored.
  ///
  /// In en, this message translates to:
  /// **'Customer \"{entityName}\" restored'**
  String activityLogCustomerRestored(String entityName);

  /// No description provided for @activityLogSupplierCreated.
  ///
  /// In en, this message translates to:
  /// **'Supplier \"{entityName}\" created'**
  String activityLogSupplierCreated(String entityName);

  /// No description provided for @activityLogSupplierUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplier \"{entityName}\" updated'**
  String activityLogSupplierUpdated(String entityName);

  /// No description provided for @activityLogSupplierArchived.
  ///
  /// In en, this message translates to:
  /// **'Supplier \"{entityName}\" archived'**
  String activityLogSupplierArchived(String entityName);

  /// No description provided for @activityLogSupplierRestored.
  ///
  /// In en, this message translates to:
  /// **'Supplier \"{entityName}\" restored'**
  String activityLogSupplierRestored(String entityName);

  /// No description provided for @activityLogPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment of {amount} recorded — {entityName}'**
  String activityLogPaymentReceived(String amount, String entityName);

  /// No description provided for @activityLogSaleCreatedFor.
  ///
  /// In en, this message translates to:
  /// **'Sale of {amount} recorded for {entityName}'**
  String activityLogSaleCreatedFor(String amount, String entityName);

  /// No description provided for @priceModePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per Unit'**
  String get priceModePerUnit;

  /// No description provided for @priceModeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get priceModeTotal;

  /// No description provided for @totalPricePaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Price Paid'**
  String get totalPricePaidLabel;

  /// No description provided for @perUnitPreview.
  ///
  /// In en, this message translates to:
  /// **'≈ {price} per {unit}'**
  String perUnitPreview(String price, String unit);

  /// No description provided for @statCustomersOwe.
  ///
  /// In en, this message translates to:
  /// **'Customers Owe You'**
  String get statCustomersOwe;

  /// No description provided for @statOwedToSuppliers.
  ///
  /// In en, this message translates to:
  /// **'You Owe Suppliers'**
  String get statOwedToSuppliers;

  /// No description provided for @recentActivityPanel.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityPanel;

  /// No description provided for @viewAllAction.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllAction;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get noRecentActivity;

  /// No description provided for @navSectionOverview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get navSectionOverview;

  /// No description provided for @navSectionInventory.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get navSectionInventory;

  /// No description provided for @navSectionSales.
  ///
  /// In en, this message translates to:
  /// **'SALES'**
  String get navSectionSales;

  /// No description provided for @navSectionAdmin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get navSectionAdmin;

  /// No description provided for @securityQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Question'**
  String get securityQuestionLabel;

  /// No description provided for @securityAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Answer'**
  String get securityAnswerLabel;

  /// No description provided for @securityQuestionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a security question'**
  String get securityQuestionRequired;

  /// No description provided for @securityAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an answer'**
  String get securityAnswerRequired;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @recoveryCodeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Code'**
  String get recoveryCodeDialogTitle;

  /// No description provided for @recoveryCodeSaveWarning.
  ///
  /// In en, this message translates to:
  /// **'Save this code somewhere safe — you\'ll need it if you forget your password again:'**
  String get recoveryCodeSaveWarning;

  /// No description provided for @recoveryCodeAckCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved this code'**
  String get recoveryCodeAckCheckbox;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @recoveryChooseMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover Access'**
  String get recoveryChooseMethodTitle;

  /// No description provided for @recoveryMethodQuestion.
  ///
  /// In en, this message translates to:
  /// **'Answer security question'**
  String get recoveryMethodQuestion;

  /// No description provided for @recoveryMethodCode.
  ///
  /// In en, this message translates to:
  /// **'Enter recovery code'**
  String get recoveryMethodCode;

  /// No description provided for @recoveryCodeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery Code'**
  String get recoveryCodeFieldLabel;

  /// No description provided for @recoveryIncorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'That answer doesn\'t match'**
  String get recoveryIncorrectAnswer;

  /// No description provided for @recoveryIncorrectCode.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t match'**
  String get recoveryIncorrectCode;

  /// No description provided for @recoveryNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get recoveryNewPasswordTitle;

  /// No description provided for @recoveryNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Not Available'**
  String get recoveryNotAvailableTitle;

  /// No description provided for @recoveryNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No security question or recovery code was set up for this installation. Contact technical support for help resetting your password.'**
  String get recoveryNotAvailableMessage;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @securityQuestionShopName.
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first shop or business?'**
  String get securityQuestionShopName;

  /// No description provided for @securityQuestionMotherName.
  ///
  /// In en, this message translates to:
  /// **'What is your mother\'s first name?'**
  String get securityQuestionMotherName;

  /// No description provided for @securityQuestionBirthCity.
  ///
  /// In en, this message translates to:
  /// **'What city were you born in?'**
  String get securityQuestionBirthCity;

  /// No description provided for @securityQuestionFirstPet.
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first pet?'**
  String get securityQuestionFirstPet;

  /// No description provided for @securityQuestionFavoriteProduct.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite product to sell?'**
  String get securityQuestionFavoriteProduct;

  /// No description provided for @copyCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCodeAction;

  /// No description provided for @codeCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedMessage;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get insightsTitle;

  /// No description provided for @insightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data-driven suggestions based on your store\'s activity'**
  String get insightsSubtitle;

  /// No description provided for @statNextWeekEstimate.
  ///
  /// In en, this message translates to:
  /// **'Next Week Estimate'**
  String get statNextWeekEstimate;

  /// No description provided for @statNextMonthEstimate.
  ///
  /// In en, this message translates to:
  /// **'Next Month Estimate'**
  String get statNextMonthEstimate;

  /// No description provided for @todayAnomalyLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue ({today}) is unusually low compared to your recent average ({avg}).'**
  String todayAnomalyLowMessage(String today, String avg);

  /// No description provided for @todayAnomalyHighMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue ({today}) is unusually high compared to your recent average ({avg}).'**
  String todayAnomalyHighMessage(String today, String avg);

  /// No description provided for @reorderSuggestionsPanel.
  ///
  /// In en, this message translates to:
  /// **'Reorder Suggestions'**
  String get reorderSuggestionsPanel;

  /// No description provided for @reorderSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Products likely to run out soon, based on recent sales pace'**
  String get reorderSuggestionsDesc;

  /// No description provided for @colDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get colDaysLeft;

  /// No description provided for @colSuggestedQty.
  ///
  /// In en, this message translates to:
  /// **'Suggested Qty'**
  String get colSuggestedQty;

  /// No description provided for @colSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get colSupplier;

  /// No description provided for @noReorderSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs reordering right now.'**
  String get noReorderSuggestions;

  /// No description provided for @stagnantProductsPanel.
  ///
  /// In en, this message translates to:
  /// **'Slow-Moving Stock'**
  String get stagnantProductsPanel;

  /// No description provided for @stagnantProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'In stock but no sales in the last 30 days'**
  String get stagnantProductsDesc;

  /// No description provided for @noStagnantProducts.
  ///
  /// In en, this message translates to:
  /// **'No slow-moving stock right now.'**
  String get noStagnantProducts;

  /// No description provided for @reorderNoticeMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} products need reordering soon'**
  String reorderNoticeMessage(int count);

  /// No description provided for @suggestedPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {price} (based on similar products)'**
  String suggestedPriceHint(String price);

  /// No description provided for @useSuggestionAction.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useSuggestionAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
