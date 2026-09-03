// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nova Store';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navCategories => 'Categories';

  @override
  String get navTodaySales => 'Today Sales';

  @override
  String get navArchive => 'Archive';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get exitConfirmTitle => 'Exit Nova Pro';

  @override
  String get exitConfirmMessage => 'Are you sure you want to exit Nova Pro?';

  @override
  String get exitConfirmButton => 'Exit';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Store overview';

  @override
  String get statProducts => 'Products';

  @override
  String get statCategories => 'Categories';

  @override
  String get statTodaySales => 'Today\'s Sales';

  @override
  String get statLowStock => 'Low Stock';

  @override
  String salesCount(int count) {
    return '$count sales';
  }

  @override
  String get lowStockPanelTitle => 'Low Stock Products';

  @override
  String lowStockPanelDesc(int count) {
    return '$count products need restocking';
  }

  @override
  String get noLowStockProducts => 'No low stock products';

  @override
  String unitsLeft(String count) {
    return '$count left';
  }

  @override
  String get productsTitle => 'Products';

  @override
  String get productsSubtitle => 'Your full shop catalogue';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get statTotalProducts => 'Total Products';

  @override
  String get statTotalUnits => 'Total Units In Stock';

  @override
  String get statStockValue => 'Stock Value';

  @override
  String get atBuyPrice => 'At buy price';

  @override
  String get allProductsPanel => 'All Products';

  @override
  String shownOfTotal(int shown, int total) {
    return '$shown of $total shown';
  }

  @override
  String get searchProductsHint => 'Search name, code, or barcode';

  @override
  String get allCategories => 'All categories';

  @override
  String get filterAll => 'All';

  @override
  String get filterLowStock => 'Low Stock';

  @override
  String get filterOutOfStock => 'Out of Stock';

  @override
  String get colProductName => 'Product Name';

  @override
  String get colBarcode => 'Barcode';

  @override
  String get colCategory => 'Category';

  @override
  String get colSellingPrice => 'Selling Price';

  @override
  String get colCurrentStock => 'Current Stock';

  @override
  String get productDetailsAction => 'Product Details';

  @override
  String get colStatus => 'Status';

  @override
  String get colActions => 'Actions';

  @override
  String get statusInStock => 'In Stock';

  @override
  String get statusLowStock => 'Low Stock';

  @override
  String get statusOutOfStock => 'Out of Stock';

  @override
  String get noProductsMatch => 'No products match your filters.';

  @override
  String get removeProductTitle => 'Remove product?';

  @override
  String removeProductMessage(String name) {
    return '\"$name\" will be archived and hidden from the catalogue.';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String get productNameLabel => 'Name';

  @override
  String get productCodeLabel => 'Code';

  @override
  String get barcodeOptionalLabel => 'Barcode (optional)';

  @override
  String get categoryOptionalLabel => 'Category (optional)';

  @override
  String get noneOption => 'None';

  @override
  String get lowStockThresholdLabel => 'Low stock threshold';

  @override
  String get variantSizeLabel => 'Size (optional)';

  @override
  String get variantSizeHint => 'e.g. 4mm, Large, 1kg';

  @override
  String get normalProductOption => 'Normal Product';

  @override
  String get productWithSizesOption => 'Product with Sizes';

  @override
  String get sizeLabelFieldLabel => 'Size';

  @override
  String get addAnotherSizeAction => 'Add Another Size';

  @override
  String get removeSizeTooltip => 'Remove this size';

  @override
  String get sizesSectionLabel => 'Sizes';

  @override
  String get variantsPanel => 'Other Sizes';

  @override
  String get variantsPanelDesc => 'Other products in the same variant group';

  @override
  String get unitTypeLabel => 'Unit Type';

  @override
  String get unitTypePiece => 'Piece';

  @override
  String get unitTypeKg => 'Kilogram (kg)';

  @override
  String get unitTypeMeter => 'Meter (m)';

  @override
  String get productInfoPanel => 'Product Information';

  @override
  String get minimumStockLabel => 'Minimum Stock';

  @override
  String get batchesLabel => 'Batches';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get sellingPriceLabel => 'Selling Price';

  @override
  String get costPriceLabel => 'Cost Price';

  @override
  String get notSet => 'Not set';

  @override
  String get batchesPanelDesc => 'FIFO — oldest batch is sold first';

  @override
  String get noBatchesYet =>
      'No inventory yet. Use \"Add Stock\" to record the first batch.';

  @override
  String get colBatch => 'Batch';

  @override
  String get colBuyPrice => 'Buy Price';

  @override
  String get colRemainingQuantity => 'Remaining Quantity';

  @override
  String get colPurchaseDate => 'Purchase Date';

  @override
  String get nextOutTag => 'NEXT OUT';

  @override
  String get quickActionsPanel => 'Quick Actions';

  @override
  String get addStock => 'Add Stock';

  @override
  String get viewStockMovements => 'View Stock Movements';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get buyPriceLabel => 'Buy Price';

  @override
  String get estimatedCostOptionalLabel => 'Estimated Cost (optional)';

  @override
  String get openingStockToggleLabel =>
      'This is stock I already had (not a new purchase)';

  @override
  String get addOpeningStockAction => 'Add Opening Stock';

  @override
  String get sellingPriceFieldLabel => 'Selling Price';

  @override
  String get purchaseDateLabel => 'Purchase Date';

  @override
  String get stockMovementsTitle => 'Stock Movements';

  @override
  String get noMovementsRecorded => 'No movements recorded.';

  @override
  String get colProductId => 'Product ID';

  @override
  String get sizeVariantLabel => 'Size / Variant';

  @override
  String get profitMarginLabel => 'Profit Margin';

  @override
  String get stockStatusLabel => 'Stock Status';

  @override
  String get bestSupplierPanel => 'Best Supplier';

  @override
  String avgPriceAcrossPurchases(int count) {
    return 'avg. price across $count purchases';
  }

  @override
  String alsoBoughtFromNote(String list) {
    return 'Also bought from: $list';
  }

  @override
  String get viewAllAction => 'View All';

  @override
  String get perUnitNote => 'per unit';

  @override
  String get latestBatchAverageNote => 'latest batch average';

  @override
  String get colTotalValue => 'Total Value';

  @override
  String get printBarcodeAction => 'Print Barcode';

  @override
  String get barcodePrintComingSoon => 'Barcode printing is coming soon.';

  @override
  String stockValueFormulaNote(String qty, String cost) {
    return '$qty × $cost cost';
  }

  @override
  String aboveMinimumNote(String qty) {
    return '$qty above minimum';
  }

  @override
  String belowMinimumNote(String qty) {
    return '$qty below minimum';
  }

  @override
  String get atMinimumNote => 'At minimum threshold';

  @override
  String percentOfSellingPriceNote(String percent) {
    return '$percent% of selling price';
  }

  @override
  String get weeksSuffix => 'weeks';

  @override
  String stockWillLastNote(String weeks) {
    return 'Stock will last about $weeks based on recent sales';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String categoriesCount(int count) {
    return '$count categories';
  }

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get allCategoriesPanel => 'All Categories';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String categoryProductsCount(int count) {
    return '$count products';
  }

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryMessage(String name) {
    return 'Delete \"$name\"? This can\'t be undone.';
  }

  @override
  String get todaySalesTitle => 'Today Sales';

  @override
  String get addProductLabel => 'Add Product';

  @override
  String get searchToSellHint => 'Search a product to sell...';

  @override
  String get salesTodayPanel => 'Sales Today';

  @override
  String get colTime => 'Time';

  @override
  String get colProduct => 'Product';

  @override
  String get colQuantity => 'Quantity';

  @override
  String get colUnitPrice => 'Unit Price';

  @override
  String get colTotal => 'Total';

  @override
  String get statRevenue => 'Revenue';

  @override
  String get statProfit => 'Profit';

  @override
  String get statSoldItems => 'Sold Items';

  @override
  String get statTransactions => 'Transactions';

  @override
  String get fifoHint => 'FIFO';

  @override
  String get totalLabel => 'Total';

  @override
  String inStockCount(String count) {
    return '$count in stock';
  }

  @override
  String get addSaleAction => 'Add Sale';

  @override
  String get enterValidQuantityPrice => 'Enter a valid quantity and price';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get archiveSubtitle => 'Past trading days';

  @override
  String get salesHistoryPanel => 'Sales History';

  @override
  String daysRecorded(int count) {
    return '$count days recorded';
  }

  @override
  String get noArchivedDaysYet => 'No archived days yet.';

  @override
  String get colDate => 'Date';

  @override
  String get colSalesCount => 'Sales Count';

  @override
  String get openAction => 'Open';

  @override
  String transactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get noSalesRecordedToday => 'No sales recorded on this day.';

  @override
  String get editSaleTitle => 'Edit Sale';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deleteSaleTitle => 'Delete sale';

  @override
  String get deleteSaleMessage =>
      'This sale will be removed and its stock restored.';

  @override
  String salesForDate(String date) {
    return 'Sales — $date';
  }

  @override
  String get salesPanel => 'Sales';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'App and store preferences';

  @override
  String get shopNamePanel => 'Shop Name';

  @override
  String get shopNamePanelDesc => 'Shown in the sidebar and used on receipts';

  @override
  String get themePanel => 'Theme';

  @override
  String get themePanelDesc => 'Choose how Nova Store looks';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get fontSizePanel => 'Font Size';

  @override
  String get fontSizePanelDesc => 'Adjust text size across Nova Store';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get languagePanel => 'Language';

  @override
  String get languagePanelDesc => 'Choose the app language';

  @override
  String get savedLabel => 'Saved';

  @override
  String get viewArchived => 'View Archived';

  @override
  String get viewActive => 'View Active';

  @override
  String get restoreAction => 'Restore';

  @override
  String get statusArchived => 'Archived';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get suppliersSubtitle => 'Vendors you purchase stock from';

  @override
  String get newPurchaseAction => 'New Purchase';

  @override
  String get addSupplier => 'Add Supplier';

  @override
  String get editSupplier => 'Edit Supplier';

  @override
  String get statTotalSuppliers => 'Total Suppliers';

  @override
  String get statTotalPurchased => 'Total Purchased';

  @override
  String get allSuppliersPanel => 'All Suppliers';

  @override
  String get searchSuppliersHint => 'Search name, location, or phone';

  @override
  String get noSuppliersMatch => 'No suppliers match your filters.';

  @override
  String get colName => 'Name';

  @override
  String get colLocation => 'Location';

  @override
  String get colPhone => 'Phone';

  @override
  String get colOwed => 'Owed';

  @override
  String get statusActive => 'Active';

  @override
  String get removeSupplierTitle => 'Remove supplier?';

  @override
  String removeSupplierMessage(String name) {
    return '\"$name\" will be archived and hidden from the list.';
  }

  @override
  String get recordPaymentTitle => 'Record Payment';

  @override
  String get amountLabel => 'Amount';

  @override
  String get paymentDateLabel => 'Payment Date';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get deletePurchaseTitle => 'Delete purchase';

  @override
  String get deletePurchaseMessage =>
      'This purchase will be removed and its stock reversed.';

  @override
  String get supplierInfoPanel => 'Supplier Information';

  @override
  String get purchaseHistoryPanel => 'Purchase History';

  @override
  String get mostRecentFirst => 'Most recent first';

  @override
  String get noPurchasesYet => 'No purchases yet from this supplier.';

  @override
  String get colItems => 'Items';

  @override
  String get colPaid => 'Paid';

  @override
  String get colRemaining => 'Remaining';

  @override
  String get editPurchaseTooltip => 'Edit Purchase';

  @override
  String get paymentsHistoryPanel => 'Payments History';

  @override
  String paymentCountDesc(int count) {
    return '$count payment(s)';
  }

  @override
  String get noPaymentsYet => 'No payments recorded yet.';

  @override
  String get historyPanel => 'History';

  @override
  String historyCountDesc(int count) {
    return '$count entries';
  }

  @override
  String get noHistoryYet => 'No history yet for this customer.';

  @override
  String get debtAddedLabel => 'Debt Added';

  @override
  String get addDebtAction => 'Add Debt';

  @override
  String get debtNoteHint => 'e.g. Opening balance before using this app';

  @override
  String get supplierDetailFallbackTitle => 'Supplier Detail';

  @override
  String get supplierNoLongerExists => 'This supplier no longer exists.';

  @override
  String get selectSupplierTitle => 'Select Supplier';

  @override
  String get searchSuppliersEllipsis => 'Search suppliers...';

  @override
  String get noSuppliersFound => 'No suppliers found.';

  @override
  String get newSupplierAction => 'New Supplier';

  @override
  String get locationOptionalLabel => 'Location (optional)';

  @override
  String get phoneOptionalLabel => 'Phone (optional)';

  @override
  String get supplierAddProductsPanel => 'Add Products';

  @override
  String get searchProductToPurchaseDesc => 'Search for a product to purchase';

  @override
  String get searchProductToAddHint => 'Search a product to add...';

  @override
  String get cartPanel => 'Cart';

  @override
  String cartLineCountDesc(int count) {
    return '$count line(s)';
  }

  @override
  String get noLinesAddedYet => 'No lines added yet.';

  @override
  String get searchProductAboveToStartPurchase =>
      'Search a product above to start this purchase.';

  @override
  String get addLineAction => 'Add Line';

  @override
  String get summaryPanel => 'Summary';

  @override
  String itemsUnitsCount(String count) {
    return '$count units';
  }

  @override
  String get subtotalRow => 'Subtotal';

  @override
  String get previousDebtRow => 'Previous debt to this supplier';

  @override
  String get totalDueRow => 'Total due';

  @override
  String get paymentPanel => 'Payment';

  @override
  String get toRecordPaymentHintSupplier =>
      'To record a payment, use \"Record Payment\" on the supplier\'s page.';

  @override
  String get amountPaidRow => 'Amount paid';

  @override
  String get payFullAction => 'Pay full';

  @override
  String get halfNowAction => 'Half now';

  @override
  String get confirmPurchaseAction => 'Confirm Purchase';

  @override
  String editingPurchaseNum(String id) {
    return 'Editing purchase #$id';
  }

  @override
  String get draftNotSaved => 'Draft · not saved yet';

  @override
  String supplierOwedSuffix(String amount) {
    return ' · Owed $amount';
  }

  @override
  String get sellingPriceRequiredFirstBatch =>
      'Selling Price (required — first stock for this product)';

  @override
  String get addAtLeastOneProduct => 'Add at least one product to the cart.';

  @override
  String get amountPaidRangeError =>
      'Amount paid must be between 0 and the total.';

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersSubtitle => 'People you sell to on credit';

  @override
  String get newSaleAction => 'New Sale';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get statTotalCustomers => 'Total Customers';

  @override
  String get statTotalOwed => 'Total Owed';

  @override
  String get allCustomersPanel => 'All Customers';

  @override
  String get searchCustomersHint => 'Search name or phone';

  @override
  String get noCustomersMatch => 'No customers match your filters.';

  @override
  String get colBalance => 'Balance';

  @override
  String get viewAction => 'View';

  @override
  String get removeCustomerTitle => 'Remove customer?';

  @override
  String removeCustomerMessage(String name) {
    return '\"$name\" will be archived and hidden from the list.';
  }

  @override
  String get newCustomerSaleTitle => 'New Customer Sale';

  @override
  String get customerInfoPanel => 'Customer Information';

  @override
  String get memberSinceLabel => 'Member Since';

  @override
  String get remainingBalanceLabel => 'Remaining Balance';

  @override
  String salesHistoryCountDesc(int count) {
    return '$count sale(s)';
  }

  @override
  String get noSalesYetForCustomer => 'No sales yet for this customer.';

  @override
  String get colMethod => 'Method';

  @override
  String get viewInvoiceTooltip => 'View Invoice';

  @override
  String get customerDetailFallbackTitle => 'Customer Detail';

  @override
  String get customerNoLongerExists => 'This customer no longer exists.';

  @override
  String get selectCustomerTitle => 'Select Customer';

  @override
  String get searchCustomersEllipsis => 'Search customers...';

  @override
  String get noCustomersFound => 'No customers found.';

  @override
  String get newCustomerAction => 'New Customer';

  @override
  String get chooseWhoSaleFor => 'Choose who this sale is for';

  @override
  String get customerAddProductsPanel => 'Add products';

  @override
  String get addProductsDesc => 'Search, scan, or tap a favourite';

  @override
  String get frequentlySoldLabel => 'FREQUENTLY SOLD';

  @override
  String lowStockLeftSuffix(String qty) {
    return 'Low · $qty left';
  }

  @override
  String get tapProductAboveToStartSale =>
      'Tap a product above to start this sale.';

  @override
  String get returnTooltip => 'Return';

  @override
  String get previousBalanceRow => 'Previous balance';

  @override
  String get toRecordPaymentHintCustomer =>
      'To record a payment, use \"Record Payment\" on the customer\'s page.';

  @override
  String get confirmSaleAction => 'Confirm sale';

  @override
  String editingSaleNum(String id) {
    return 'Editing sale #$id';
  }

  @override
  String balanceSuffix(String amount) {
    return ' · Balance $amount';
  }

  @override
  String get paymentUpdated => 'Payment updated.';

  @override
  String get amountPaidUpdateRangeError =>
      'Amount paid must be between 0 and the total';

  @override
  String get returnsTitle => 'Returns';

  @override
  String get returnsSubtitle => 'History of returned items';

  @override
  String get allReturnsPanel => 'All Returns';

  @override
  String get noReturnsYet => 'No returns recorded yet.';

  @override
  String get colSaleId => 'Sale ID';

  @override
  String get colReason => 'Reason';

  @override
  String get colRefunded => 'Refunded';

  @override
  String get startReturnTitle => 'Start Return';

  @override
  String get startReturnSubtitle => 'Find the original sale and return items';

  @override
  String get findSalePanel => 'Find Sale';

  @override
  String get recentSalesHint => 'Recent sales shown below';

  @override
  String get showRecentSalesAction => 'Show recent sales';

  @override
  String get returnItemsPanel => 'Return Items';

  @override
  String get enterQtyToReturnDesc => 'Enter quantity to return for each item';

  @override
  String productHashLabel(String id, String qty, String price) {
    return 'Product #$id — $qty @ $price DA';
  }

  @override
  String get returnQtyLabel => 'Return Qty';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reasonDamaged => 'Damaged';

  @override
  String get reasonWrongItem => 'Wrong Item';

  @override
  String get reasonChangedMind => 'Changed Mind';

  @override
  String get reasonOther => 'Other';

  @override
  String get enterQtyAtLeastOne => 'Enter a quantity for at least one item';

  @override
  String get backAction => 'Back';

  @override
  String get confirmReturnAction => 'Confirm Return';

  @override
  String get unknownProductLabel => 'Unknown';

  @override
  String returnLineDesc(String name, String qty, String price) {
    return '$name — $qty @ $price DA';
  }

  @override
  String returnRecordedCashMsg(String amount) {
    return 'Return recorded. Refund $amount DA in cash.';
  }

  @override
  String returnRecordedDebtMsg(String amount) {
    return 'Return recorded. Debt reduced by $amount DA.';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get viewReportsAction => 'View Reports';

  @override
  String get reportsSubtitle => 'Sales performance and exports';

  @override
  String get csvExportAction => 'CSV';

  @override
  String get pdfExportAction => 'PDF';

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeWeek => 'This Week';

  @override
  String get rangeMonth => 'This Month';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get revenueTrendPanel => 'Revenue Trend';

  @override
  String get noSalesInRange => 'No sales in this range.';

  @override
  String get bestSellingProductsPanel => 'Best Selling Products';

  @override
  String get colUnitsSold => 'Units Sold';

  @override
  String get printSavePdfTooltip => 'Print / Save PDF';

  @override
  String invoiceHashTitle(String id) {
    return 'Invoice #$id';
  }

  @override
  String invoiceSubtitle(String id, String date) {
    return 'Sale #$id — $date';
  }

  @override
  String invoiceSubtitleWithCustomer(String id, String date, String customer) {
    return 'Sale #$id — $date — $customer';
  }

  @override
  String invoiceTotalLine(String amount) {
    return 'Total: $amount';
  }

  @override
  String invoicePaidLine(String amount) {
    return 'Paid: $amount';
  }

  @override
  String invoiceRemainingLine(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get activityLogTitle => 'Activity Log';

  @override
  String get activityLogSubtitle => 'A history of important business actions';

  @override
  String get categoryLabel => 'Category';

  @override
  String get catAll => 'All';

  @override
  String get catSale => 'Sale';

  @override
  String get catPurchase => 'Purchase';

  @override
  String get catReturn => 'Return';

  @override
  String get catProduct => 'Product';

  @override
  String get catCategory => 'Category';

  @override
  String get catCustomer => 'Customer';

  @override
  String get catSupplier => 'Supplier';

  @override
  String get catPayment => 'Payment';

  @override
  String get entriesPanel => 'Entries';

  @override
  String recordsCountDesc(int count) {
    return '$count record(s)';
  }

  @override
  String get noActivityInRange => 'No activity in this range.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get amountPaidHintLabel => 'Amount Paid (leave empty for full price)';

  @override
  String get enterValidAmountPaid => 'Enter a valid amount paid';

  @override
  String get amountPaidExceedsTotal => 'Amount paid cannot exceed the total';

  @override
  String get ctrlFHint => 'Ctrl+F';

  @override
  String get cropPhotoTitle => 'Crop Photo';

  @override
  String get croppingEllipsis => 'Cropping...';

  @override
  String get cropSaveAction => 'Crop & Save';

  @override
  String couldNotCropImage(String cause) {
    return 'Could not crop image: $cause';
  }

  @override
  String get productDetailFallbackTitle => 'Product Detail';

  @override
  String get productNoLongerExists => 'This product no longer exists.';

  @override
  String get removePhotoTitle => 'Remove photo?';

  @override
  String get removePhotoMessage =>
      'The product photo will be permanently deleted.';

  @override
  String get noPhotoLabel => 'No photo';

  @override
  String get changePhotoAction => 'Change Photo';

  @override
  String get searchImagesOnlineAction => 'Search Images Online';

  @override
  String get searchImagesOnlineHint =>
      'Opens your browser — right-click and save any image you like, then use Choose Photo to add it here.';

  @override
  String get searchImagesOnlineDisabledHint => 'Enter a product name first';

  @override
  String get removePhotoAction => 'Remove Photo';

  @override
  String batchHashLabel(int n) {
    return 'Batch #$n';
  }

  @override
  String get deletePermanentlyTitle => 'Delete permanently?';

  @override
  String deletePermanentlyMessage(String name) {
    return 'Permanently delete \"$name\"? This cannot be undone.';
  }

  @override
  String get deletePermanentlyAction => 'Delete Permanently';

  @override
  String get forceDeleteAction => 'Force Delete';

  @override
  String get forceDeleteTitle => 'Force delete product?';

  @override
  String forceDeleteWarning(String name) {
    return 'This will permanently delete \"$name\" AND all its sales, purchases, and stock history. This cannot be undone.';
  }

  @override
  String forceDeleteTypeToConfirm(String name) {
    return 'Type \"$name\" to confirm';
  }

  @override
  String forceDeleteSuccessMessage(String name) {
    return '\"$name\" and all its history were permanently deleted.';
  }

  @override
  String get securityPanel => 'Security';

  @override
  String get securityPanelDesc => 'Protect the app with a password';

  @override
  String get passwordIsSet => 'Password is set';

  @override
  String get noPasswordSet => 'No password set';

  @override
  String get changeAction => 'Change';

  @override
  String get setPasswordAction => 'Set Password';

  @override
  String get setPasswordDialogTitle => 'Set Password';

  @override
  String get changePasswordDialogTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get enterNewPassword => 'Enter a new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get removePasswordDialogTitle => 'Remove Password';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get customerSalesLabel => 'Customer Sales';

  @override
  String invoiceCountDesc(int count) {
    return '$count invoice(s)';
  }

  @override
  String get noCustomerSalesYet => 'No customer sales recorded yet.';

  @override
  String get supplierPurchasesLabel => 'Supplier Purchases';

  @override
  String purchaseCountDesc(int count) {
    return '$count purchase(s)';
  }

  @override
  String get noSupplierPurchasesYet => 'No supplier purchases recorded yet.';

  @override
  String get colCustomer => 'Customer';

  @override
  String get invoiceAction => 'Invoice';

  @override
  String get colNote => 'Note';

  @override
  String get colAmount => 'Amount';

  @override
  String get remainingOwedLabel => 'Remaining Owed';

  @override
  String get purchasesLabel => 'Purchases';

  @override
  String get zeroFullyOnCreditHint => '0 = fully on credit';

  @override
  String saleItemsCount(int count) {
    return '$count item(s)';
  }

  @override
  String get addAction => 'Add';

  @override
  String csvSavedMessage(String path) {
    return 'Saved: $path';
  }

  @override
  String activityLogSaleCreated(String amount) {
    return 'Sale of $amount recorded';
  }

  @override
  String activityLogSaleUpdated(int refId) {
    return 'Sale #$refId updated';
  }

  @override
  String activityLogSaleDeleted(int refId) {
    return 'Sale #$refId deleted, stock restored';
  }

  @override
  String activityLogPurchaseCreated(String amount, String entityName) {
    return 'Purchase of $amount recorded from $entityName';
  }

  @override
  String activityLogPurchaseUpdated(int refId) {
    return 'Purchase #$refId updated';
  }

  @override
  String activityLogReturnCreated(int refId, String amount) {
    return 'Return recorded for sale #$refId, refunded $amount';
  }

  @override
  String activityLogProductCreated(String entityName) {
    return 'Product \"$entityName\" created';
  }

  @override
  String activityLogProductUpdated(String entityName) {
    return 'Product \"$entityName\" updated';
  }

  @override
  String activityLogProductDeleted(String entityName) {
    return 'Product \"$entityName\" permanently deleted';
  }

  @override
  String activityLogProductArchived(String entityName) {
    return 'Product \"$entityName\" archived';
  }

  @override
  String activityLogProductRestored(String entityName) {
    return 'Product \"$entityName\" restored';
  }

  @override
  String activityLogCategoryCreated(String entityName) {
    return 'Category \"$entityName\" created';
  }

  @override
  String activityLogCategoryUpdated(String entityName) {
    return 'Category \"$entityName\" updated';
  }

  @override
  String activityLogCategoryDeleted(String entityName) {
    return 'Category \"$entityName\" deleted';
  }

  @override
  String activityLogCustomerCreated(String entityName) {
    return 'Customer \"$entityName\" created';
  }

  @override
  String activityLogCustomerUpdated(String entityName) {
    return 'Customer \"$entityName\" updated';
  }

  @override
  String activityLogCustomerArchived(String entityName) {
    return 'Customer \"$entityName\" archived';
  }

  @override
  String activityLogCustomerRestored(String entityName) {
    return 'Customer \"$entityName\" restored';
  }

  @override
  String activityLogSupplierCreated(String entityName) {
    return 'Supplier \"$entityName\" created';
  }

  @override
  String activityLogSupplierUpdated(String entityName) {
    return 'Supplier \"$entityName\" updated';
  }

  @override
  String activityLogSupplierArchived(String entityName) {
    return 'Supplier \"$entityName\" archived';
  }

  @override
  String activityLogSupplierRestored(String entityName) {
    return 'Supplier \"$entityName\" restored';
  }

  @override
  String activityLogPaymentReceived(String amount, String entityName) {
    return 'Payment of $amount recorded — $entityName';
  }

  @override
  String activityLogSaleCreatedFor(String amount, String entityName) {
    return 'Sale of $amount recorded for $entityName';
  }

  @override
  String get priceModePerUnit => 'Per Unit';

  @override
  String get priceModeTotal => 'Total Price';

  @override
  String get totalPricePaidLabel => 'Total Price Paid';

  @override
  String perUnitPreview(String price, String unit) {
    return '≈ $price per $unit';
  }

  @override
  String get statCustomersOwe => 'Customers Owe You';

  @override
  String get statOwedToSuppliers => 'You Owe Suppliers';

  @override
  String get recentActivityPanel => 'Recent Activity';

  @override
  String get noRecentActivity => 'No activity yet.';

  @override
  String get navSectionOverview => 'OVERVIEW';

  @override
  String get navSectionInventory => 'INVENTORY';

  @override
  String get navSectionSales => 'SALES';

  @override
  String get navSectionAdmin => 'ADMIN';

  @override
  String get securityQuestionLabel => 'Security Question';

  @override
  String get securityAnswerLabel => 'Security Answer';

  @override
  String get securityQuestionRequired => 'Enter a security question';

  @override
  String get securityAnswerRequired => 'Enter an answer';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get recoveryCodeDialogTitle => 'Your Recovery Code';

  @override
  String get recoveryCodeSaveWarning =>
      'Save this code somewhere safe — you\'ll need it if you forget your password again:';

  @override
  String get recoveryCodeAckCheckbox => 'I\'ve saved this code';

  @override
  String get continueAction => 'Continue';

  @override
  String get recoveryChooseMethodTitle => 'Recover Access';

  @override
  String get recoveryMethodQuestion => 'Answer security question';

  @override
  String get recoveryMethodCode => 'Enter recovery code';

  @override
  String get recoveryCodeFieldLabel => 'Recovery Code';

  @override
  String get recoveryIncorrectAnswer => 'That answer doesn\'t match';

  @override
  String get recoveryIncorrectCode => 'That code doesn\'t match';

  @override
  String get recoveryNewPasswordTitle => 'Set New Password';

  @override
  String get recoveryNotAvailableTitle => 'Recovery Not Available';

  @override
  String get recoveryNotAvailableMessage =>
      'No security question or recovery code was set up for this installation. Contact technical support for help resetting your password.';

  @override
  String get verifyAction => 'Verify';

  @override
  String get securityQuestionShopName =>
      'What was the name of your first shop or business?';

  @override
  String get securityQuestionMotherName => 'What is your mother\'s first name?';

  @override
  String get securityQuestionBirthCity => 'What city were you born in?';

  @override
  String get securityQuestionFirstPet => 'What was the name of your first pet?';

  @override
  String get securityQuestionFavoriteProduct =>
      'What is your favorite product to sell?';

  @override
  String get copyCodeAction => 'Copy Code';

  @override
  String get codeCopiedMessage => 'Code copied to clipboard';

  @override
  String get insightsTitle => 'Smart Insights';

  @override
  String get insightsSubtitle =>
      'Data-driven suggestions based on your store\'s activity';

  @override
  String get statNextWeekEstimate => 'Next Week Estimate';

  @override
  String get statNextMonthEstimate => 'Next Month Estimate';

  @override
  String todayAnomalyLowMessage(String today, String avg) {
    return 'Today\'s revenue ($today) is unusually low compared to your recent average ($avg).';
  }

  @override
  String todayAnomalyHighMessage(String today, String avg) {
    return 'Today\'s revenue ($today) is unusually high compared to your recent average ($avg).';
  }

  @override
  String get reorderSuggestionsPanel => 'Reorder Suggestions';

  @override
  String get reorderSuggestionsDesc =>
      'Products likely to run out soon, based on recent sales pace';

  @override
  String get colDaysLeft => 'Days Left';

  @override
  String get colSuggestedQty => 'Suggested Qty';

  @override
  String get colSupplier => 'Supplier';

  @override
  String get noReorderSuggestions => 'Nothing needs reordering right now.';

  @override
  String get stagnantProductsPanel => 'Slow-Moving Stock';

  @override
  String get stagnantProductsDesc =>
      'In stock but no sales in the last 30 days';

  @override
  String get noStagnantProducts => 'No slow-moving stock right now.';

  @override
  String get oldDebtCustomersPanel => 'Customers with Old Debt';

  @override
  String get oldDebtCustomersDesc =>
      'Balances with no payment or purchase activity in over 30 days';

  @override
  String get noOldDebtCustomers => 'No overdue customer debt right now.';

  @override
  String get lastActivityLabel => 'Last Activity';

  @override
  String get supplierPriorityPanel => 'Suppliers to Pay First';

  @override
  String get supplierPriorityDesc =>
      'Suppliers you owe the most, ordered by amount owed';

  @override
  String get noSupplierPriority => 'You don\'t owe any suppliers right now.';

  @override
  String reorderNoticeMessage(int count) {
    return '$count products need reordering soon';
  }

  @override
  String suggestedPriceHint(String price) {
    return 'Suggested: $price (based on similar products)';
  }

  @override
  String get useSuggestionAction => 'Use';
}
