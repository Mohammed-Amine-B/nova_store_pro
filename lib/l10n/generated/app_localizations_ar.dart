// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نوفا ستور';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navCategories => 'التصنيفات';

  @override
  String get navTodaySales => 'مبيعات اليوم';

  @override
  String get navArchive => 'الأرشيف';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get exitConfirmTitle => 'الخروج من Nova Pro';

  @override
  String get exitConfirmMessage => 'هل أنت متأكد أنك تريد الخروج من Nova Pro؟';

  @override
  String get exitConfirmButton => 'خروج';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardSubtitle => 'نظرة عامة على المحل';

  @override
  String get statProducts => 'المنتجات';

  @override
  String get statCategories => 'التصنيفات';

  @override
  String get statTodaySales => 'مبيعات اليوم';

  @override
  String get statLowStock => 'مخزون منخفض';

  @override
  String salesCount(int count) {
    return '$count عملية بيع';
  }

  @override
  String get lowStockPanelTitle => 'منتجات ذات مخزون منخفض';

  @override
  String lowStockPanelDesc(int count) {
    return '$count منتج يحتاج إلى تزويد';
  }

  @override
  String get noLowStockProducts => 'لا توجد منتجات ذات مخزون منخفض';

  @override
  String unitsLeft(String count) {
    return 'متبقي $count';
  }

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productsSubtitle => 'كامل كتالوج المحل';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get statTotalProducts => 'إجمالي المنتجات';

  @override
  String get statTotalUnits => 'إجمالي الوحدات في المخزون';

  @override
  String get statStockValue => 'قيمة المخزون';

  @override
  String get atBuyPrice => 'بسعر الشراء';

  @override
  String get allProductsPanel => 'كل المنتجات';

  @override
  String shownOfTotal(int shown, int total) {
    return '$shown من $total معروض';
  }

  @override
  String get searchProductsHint => 'البحث بالاسم أو الرمز أو الباركود';

  @override
  String get allCategories => 'كل التصنيفات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterLowStock => 'مخزون منخفض';

  @override
  String get filterOutOfStock => 'نفذ من المخزون';

  @override
  String get colProductName => 'اسم المنتج';

  @override
  String get colBarcode => 'الباركود';

  @override
  String get colCategory => 'التصنيف';

  @override
  String get colSellingPrice => 'سعر البيع';

  @override
  String get colCurrentStock => 'المخزون الحالي';

  @override
  String get productDetailsAction => 'تفاصيل المنتج';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colActions => 'الإجراءات';

  @override
  String get statusInStock => 'متوفر';

  @override
  String get statusLowStock => 'مخزون منخفض';

  @override
  String get statusOutOfStock => 'نفذ من المخزون';

  @override
  String get noProductsMatch => 'لا توجد منتجات مطابقة للفلاتر.';

  @override
  String get removeProductTitle => 'إزالة المنتج؟';

  @override
  String removeProductMessage(String name) {
    return 'سيتم أرشفة \"$name\" وإخفاؤه من الكتالوج.';
  }

  @override
  String get removeAction => 'إزالة';

  @override
  String get productNameLabel => 'الاسم';

  @override
  String get productCodeLabel => 'الرمز';

  @override
  String get barcodeOptionalLabel => 'الباركود (اختياري)';

  @override
  String get categoryOptionalLabel => 'التصنيف (اختياري)';

  @override
  String get noneOption => 'بدون';

  @override
  String get lowStockThresholdLabel => 'حد المخزون المنخفض';

  @override
  String get variantSizeLabel => 'المقاس (اختياري)';

  @override
  String get variantSizeHint => 'مثال: 4 مم، كبير، 1 كجم';

  @override
  String get normalProductOption => 'منتج عادي';

  @override
  String get productWithSizesOption => 'منتج بأحجام متعددة';

  @override
  String get sizeLabelFieldLabel => 'الحجم';

  @override
  String get addAnotherSizeAction => 'إضافة حجم آخر';

  @override
  String get removeSizeTooltip => 'إزالة هذا الحجم';

  @override
  String get sizesSectionLabel => 'الأحجام';

  @override
  String get variantsPanel => 'مقاسات أخرى';

  @override
  String get variantsPanelDesc => 'منتجات أخرى في نفس مجموعة المقاسات';

  @override
  String get unitTypeLabel => 'نوع الوحدة';

  @override
  String get unitTypePiece => 'قطعة';

  @override
  String get unitTypeKg => 'كيلوغرام (kg)';

  @override
  String get unitTypeMeter => 'متر (m)';

  @override
  String get productInfoPanel => 'معلومات المنتج';

  @override
  String get minimumStockLabel => 'الحد الأدنى للمخزون';

  @override
  String get batchesLabel => 'الدفعات';

  @override
  String get currentStockLabel => 'المخزون الحالي';

  @override
  String get sellingPriceLabel => 'سعر البيع';

  @override
  String get costPriceLabel => 'سعر التكلفة';

  @override
  String get notSet => 'غير محدد';

  @override
  String get batchesPanelDesc => 'FIFO — الدفعة الأقدم تُباع أولًا';

  @override
  String get noBatchesYet =>
      'لا يوجد مخزون بعد. استخدم \"إضافة مخزون\" لتسجيل أول دفعة.';

  @override
  String get colBatch => 'الدفعة';

  @override
  String get colBuyPrice => 'سعر الشراء';

  @override
  String get colRemainingQuantity => 'الكمية المتبقية';

  @override
  String get colPurchaseDate => 'تاريخ الشراء';

  @override
  String get nextOutTag => 'التالي للبيع';

  @override
  String get quickActionsPanel => 'إجراءات سريعة';

  @override
  String get addStock => 'إضافة مخزون';

  @override
  String get viewStockMovements => 'عرض حركات المخزون';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get buyPriceLabel => 'سعر الشراء';

  @override
  String get estimatedCostOptionalLabel => 'التكلفة التقديرية (اختياري)';

  @override
  String get openingStockToggleLabel =>
      'هذا مخزون كان لدي بالفعل (وليس شراءً جديدًا)';

  @override
  String get addOpeningStockAction => 'إضافة مخزون افتتاحي';

  @override
  String get sellingPriceFieldLabel => 'سعر البيع';

  @override
  String get purchaseDateLabel => 'تاريخ الشراء';

  @override
  String get stockMovementsTitle => 'حركات المخزون';

  @override
  String get noMovementsRecorded => 'لا توجد حركات مسجلة.';

  @override
  String get colProductId => 'رقم المنتج';

  @override
  String get sizeVariantLabel => 'الحجم / الصنف';

  @override
  String get profitMarginLabel => 'هامش الربح';

  @override
  String get stockStatusLabel => 'حالة المخزون';

  @override
  String get bestSupplierPanel => 'أفضل مورد';

  @override
  String avgPriceAcrossPurchases(int count) {
    return 'متوسط السعر عبر $count عملية شراء';
  }

  @override
  String alsoBoughtFromNote(String list) {
    return 'تم الشراء أيضًا من: $list';
  }

  @override
  String get viewAllAction => 'عرض الكل';

  @override
  String get perUnitNote => 'لكل وحدة';

  @override
  String get latestBatchAverageNote => 'متوسط آخر دفعة';

  @override
  String get colTotalValue => 'القيمة الإجمالية';

  @override
  String get printBarcodeAction => 'طباعة الباركود';

  @override
  String get barcodePrintComingSoon => 'طباعة الباركود قريباً.';

  @override
  String stockValueFormulaNote(String qty, String cost) {
    return '$qty × $cost تكلفة';
  }

  @override
  String aboveMinimumNote(String qty) {
    return '$qty فوق الحد الأدنى';
  }

  @override
  String belowMinimumNote(String qty) {
    return '$qty تحت الحد الأدنى';
  }

  @override
  String get atMinimumNote => 'عند الحد الأدنى';

  @override
  String percentOfSellingPriceNote(String percent) {
    return '$percent% من سعر البيع';
  }

  @override
  String get weeksSuffix => 'أسابيع';

  @override
  String stockWillLastNote(String weeks) {
    return 'سيدوم المخزون حوالي $weeks بناءً على المبيعات الأخيرة';
  }

  @override
  String get categoriesTitle => 'التصنيفات';

  @override
  String categoriesCount(int count) {
    return '$count تصنيف';
  }

  @override
  String get addCategory => 'إضافة تصنيف';

  @override
  String get editCategory => 'تعديل التصنيف';

  @override
  String get allCategoriesPanel => 'كل التصنيفات';

  @override
  String get noCategoriesYet => 'لا توجد تصنيفات بعد';

  @override
  String categoryProductsCount(int count) {
    return '$count منتج';
  }

  @override
  String get categoryNameLabel => 'اسم التصنيف';

  @override
  String get deleteCategoryTitle => 'حذف التصنيف؟';

  @override
  String deleteCategoryMessage(String name) {
    return 'حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get todaySalesTitle => 'مبيعات اليوم';

  @override
  String get addProductLabel => 'إضافة منتج';

  @override
  String get searchToSellHint => 'ابحث عن منتج للبيع...';

  @override
  String get salesTodayPanel => 'مبيعات اليوم';

  @override
  String get colTime => 'الوقت';

  @override
  String get colProduct => 'المنتج';

  @override
  String get colQuantity => 'الكمية';

  @override
  String get colUnitPrice => 'سعر الوحدة';

  @override
  String get colTotal => 'الإجمالي';

  @override
  String get statRevenue => 'الإيرادات';

  @override
  String get statProfit => 'الربح';

  @override
  String get statSoldItems => 'الوحدات المباعة';

  @override
  String get statTransactions => 'العمليات';

  @override
  String get fifoHint => 'FIFO';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String inStockCount(String count) {
    return '$count في المخزون';
  }

  @override
  String get addSaleAction => 'إضافة عملية بيع';

  @override
  String get enterValidQuantityPrice => 'أدخل كمية وسعرًا صحيحين';

  @override
  String get archiveTitle => 'الأرشيف';

  @override
  String get archiveSubtitle => 'أيام البيع السابقة';

  @override
  String get salesHistoryPanel => 'سجل المبيعات';

  @override
  String daysRecorded(int count) {
    return '$count يوم مسجل';
  }

  @override
  String get noArchivedDaysYet => 'لا توجد أيام مؤرشفة بعد.';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colSalesCount => 'عدد المبيعات';

  @override
  String get openAction => 'فتح';

  @override
  String transactionsCount(int count) {
    return '$count معاملة';
  }

  @override
  String get noSalesRecordedToday => 'لا توجد مبيعات مسجلة في هذا اليوم.';

  @override
  String get editSaleTitle => 'تعديل عملية البيع';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get deleteSaleTitle => 'حذف عملية البيع';

  @override
  String get deleteSaleMessage => 'سيتم حذف عملية البيع هذه واسترجاع المخزون.';

  @override
  String salesForDate(String date) {
    return 'المبيعات — $date';
  }

  @override
  String get salesPanel => 'المبيعات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'إعدادات التطبيق والمحل';

  @override
  String get shopNamePanel => 'اسم المحل';

  @override
  String get shopNamePanelDesc =>
      'يظهر في الشريط الجانبي ويُستخدم في الإيصالات';

  @override
  String get themePanel => 'المظهر';

  @override
  String get themePanelDesc => 'اختر شكل نوفا ستور';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get fontSizePanel => 'حجم الخط';

  @override
  String get fontSizePanelDesc => 'اضبط حجم النص في نوفا ستور';

  @override
  String get fontSizeSmall => 'صغير';

  @override
  String get fontSizeMedium => 'متوسط';

  @override
  String get fontSizeLarge => 'كبير';

  @override
  String get languagePanel => 'اللغة';

  @override
  String get languagePanelDesc => 'اختر لغة التطبيق';

  @override
  String get savedLabel => 'تم الحفظ';

  @override
  String get viewArchived => 'عرض المؤرشف';

  @override
  String get viewActive => 'عرض النشط';

  @override
  String get restoreAction => 'استعادة';

  @override
  String get statusArchived => 'مؤرشف';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String get suppliersSubtitle => 'الجهات التي تشتري منها البضاعة';

  @override
  String get newPurchaseAction => 'شراء جديد';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get editSupplier => 'تعديل المورد';

  @override
  String get statTotalSuppliers => 'إجمالي الموردين';

  @override
  String get statTotalPurchased => 'إجمالي المشتريات';

  @override
  String get allSuppliersPanel => 'كل الموردين';

  @override
  String get searchSuppliersHint => 'البحث بالاسم أو الموقع أو الهاتف';

  @override
  String get noSuppliersMatch => 'لا يوجد موردون مطابقون للفلاتر.';

  @override
  String get colName => 'الاسم';

  @override
  String get colLocation => 'الموقع';

  @override
  String get colPhone => 'الهاتف';

  @override
  String get colOwed => 'المستحق';

  @override
  String get statusActive => 'نشط';

  @override
  String get removeSupplierTitle => 'إزالة المورد؟';

  @override
  String removeSupplierMessage(String name) {
    return 'سيتم أرشفة \"$name\" وإخفاؤه من القائمة.';
  }

  @override
  String get recordPaymentTitle => 'تسجيل دفعة';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get paymentDateLabel => 'تاريخ الدفع';

  @override
  String get noteOptionalLabel => 'ملاحظة (اختياري)';

  @override
  String get enterValidAmount => 'أدخل مبلغًا صحيحًا';

  @override
  String get deletePurchaseTitle => 'حذف الشراء';

  @override
  String get deletePurchaseMessage =>
      'سيتم حذف هذا الشراء وعكس أثره على المخزون.';

  @override
  String get supplierInfoPanel => 'معلومات المورد';

  @override
  String get purchaseHistoryPanel => 'سجل المشتريات';

  @override
  String get mostRecentFirst => 'الأحدث أولاً';

  @override
  String get noPurchasesYet => 'لا توجد مشتريات بعد من هذا المورد.';

  @override
  String get colItems => 'العناصر';

  @override
  String get colPaid => 'المدفوع';

  @override
  String get colRemaining => 'المتبقي';

  @override
  String get editPurchaseTooltip => 'تعديل الشراء';

  @override
  String get paymentsHistoryPanel => 'سجل الدفعات';

  @override
  String paymentCountDesc(int count) {
    return '$count دفعة';
  }

  @override
  String get noPaymentsYet => 'لا توجد دفعات مسجلة بعد.';

  @override
  String get historyPanel => 'السجل';

  @override
  String historyCountDesc(int count) {
    return '$count عنصر';
  }

  @override
  String get noHistoryYet => 'لا يوجد سجل بعد لهذا العميل.';

  @override
  String get debtAddedLabel => 'دين مضاف';

  @override
  String get addDebtAction => 'إضافة دين';

  @override
  String get debtNoteHint => 'مثال: رصيد افتتاحي قبل استخدام هذا التطبيق';

  @override
  String get supplierDetailFallbackTitle => 'تفاصيل المورد';

  @override
  String get supplierNoLongerExists => 'هذا المورد لم يعد موجودًا.';

  @override
  String get selectSupplierTitle => 'اختيار المورد';

  @override
  String get searchSuppliersEllipsis => 'البحث عن مورد...';

  @override
  String get noSuppliersFound => 'لا يوجد موردون.';

  @override
  String get newSupplierAction => 'مورد جديد';

  @override
  String get locationOptionalLabel => 'الموقع (اختياري)';

  @override
  String get phoneOptionalLabel => 'الهاتف (اختياري)';

  @override
  String get supplierAddProductsPanel => 'إضافة منتجات';

  @override
  String get searchProductToPurchaseDesc => 'ابحث عن منتج للشراء';

  @override
  String get searchProductToAddHint => 'ابحث عن منتج لإضافته...';

  @override
  String get cartPanel => 'السلة';

  @override
  String cartLineCountDesc(int count) {
    return '$count سطر';
  }

  @override
  String get noLinesAddedYet => 'لم تتم إضافة أي سطر بعد.';

  @override
  String get searchProductAboveToStartPurchase =>
      'ابحث عن منتج أعلاه لبدء هذا الشراء.';

  @override
  String get addLineAction => 'إضافة سطر';

  @override
  String get summaryPanel => 'الملخص';

  @override
  String itemsUnitsCount(String count) {
    return '$count وحدة';
  }

  @override
  String get subtotalRow => 'المجموع الفرعي';

  @override
  String get previousDebtRow => 'الدين السابق لهذا المورد';

  @override
  String get totalDueRow => 'الإجمالي المستحق';

  @override
  String get paymentPanel => 'الدفع';

  @override
  String get toRecordPaymentHintSupplier =>
      'لتسجيل دفعة، استخدم \"تسجيل دفعة\" في صفحة المورد.';

  @override
  String get amountPaidRow => 'المبلغ المدفوع';

  @override
  String get payFullAction => 'دفع كامل';

  @override
  String get halfNowAction => 'نصف الآن';

  @override
  String get confirmPurchaseAction => 'تأكيد الشراء';

  @override
  String editingPurchaseNum(String id) {
    return 'تعديل الشراء رقم $id';
  }

  @override
  String get draftNotSaved => 'مسودة · لم تُحفظ بعد';

  @override
  String supplierOwedSuffix(String amount) {
    return ' · مستحق $amount';
  }

  @override
  String get sellingPriceRequiredFirstBatch =>
      'سعر البيع (مطلوب — أول مخزون لهذا المنتج)';

  @override
  String get addAtLeastOneProduct => 'أضف منتجًا واحدًا على الأقل إلى السلة.';

  @override
  String get amountPaidRangeError =>
      'يجب أن يكون المبلغ المدفوع بين 0 والإجمالي.';

  @override
  String get customersTitle => 'الزبائن';

  @override
  String get customersSubtitle => 'الأشخاص الذين تبيع لهم بالدين';

  @override
  String get newSaleAction => 'بيع جديد';

  @override
  String get addCustomer => 'إضافة زبون';

  @override
  String get editCustomer => 'تعديل الزبون';

  @override
  String get statTotalCustomers => 'إجمالي الزبائن';

  @override
  String get statTotalOwed => 'إجمالي المستحق';

  @override
  String get allCustomersPanel => 'كل الزبائن';

  @override
  String get searchCustomersHint => 'البحث بالاسم أو الهاتف';

  @override
  String get noCustomersMatch => 'لا يوجد زبائن مطابقون للفلاتر.';

  @override
  String get colBalance => 'الرصيد';

  @override
  String get viewAction => 'عرض';

  @override
  String get removeCustomerTitle => 'إزالة الزبون؟';

  @override
  String removeCustomerMessage(String name) {
    return 'سيتم أرشفة \"$name\" وإخفاؤه من القائمة.';
  }

  @override
  String get newCustomerSaleTitle => 'بيع جديد لزبون';

  @override
  String get customerInfoPanel => 'معلومات الزبون';

  @override
  String get memberSinceLabel => 'عضو منذ';

  @override
  String get remainingBalanceLabel => 'الرصيد المتبقي';

  @override
  String salesHistoryCountDesc(int count) {
    return '$count عملية بيع';
  }

  @override
  String get noSalesYetForCustomer => 'لا توجد مبيعات بعد لهذا الزبون.';

  @override
  String get colMethod => 'الطريقة';

  @override
  String get viewInvoiceTooltip => 'عرض الفاتورة';

  @override
  String get customerDetailFallbackTitle => 'تفاصيل الزبون';

  @override
  String get customerNoLongerExists => 'هذا الزبون لم يعد موجودًا.';

  @override
  String get selectCustomerTitle => 'اختيار الزبون';

  @override
  String get searchCustomersEllipsis => 'البحث عن زبون...';

  @override
  String get noCustomersFound => 'لا يوجد زبائن.';

  @override
  String get newCustomerAction => 'زبون جديد';

  @override
  String get chooseWhoSaleFor => 'اختر لمن هذا البيع';

  @override
  String get customerAddProductsPanel => 'إضافة منتجات';

  @override
  String get addProductsDesc => 'ابحث، امسح، أو اختر منتجًا مفضلاً';

  @override
  String get frequentlySoldLabel => 'الأكثر مبيعًا';

  @override
  String lowStockLeftSuffix(String qty) {
    return 'منخفض · متبقي $qty';
  }

  @override
  String get tapProductAboveToStartSale => 'اختر منتجًا أعلاه لبدء هذا البيع.';

  @override
  String get returnTooltip => 'إرجاع';

  @override
  String get previousBalanceRow => 'الرصيد السابق';

  @override
  String get toRecordPaymentHintCustomer =>
      'لتسجيل دفعة، استخدم \"تسجيل دفعة\" في صفحة الزبون.';

  @override
  String get confirmSaleAction => 'تأكيد البيع';

  @override
  String editingSaleNum(String id) {
    return 'تعديل عملية البيع رقم $id';
  }

  @override
  String balanceSuffix(String amount) {
    return ' · الرصيد $amount';
  }

  @override
  String get paymentUpdated => 'تم تحديث الدفعة.';

  @override
  String get amountPaidUpdateRangeError =>
      'يجب أن يكون المبلغ المدفوع بين 0 والإجمالي';

  @override
  String get returnsTitle => 'المرتجعات';

  @override
  String get returnsSubtitle => 'سجل العناصر المرتجعة';

  @override
  String get allReturnsPanel => 'كل المرتجعات';

  @override
  String get noReturnsYet => 'لا توجد مرتجعات مسجلة بعد.';

  @override
  String get colSaleId => 'رقم البيع';

  @override
  String get colReason => 'السبب';

  @override
  String get colRefunded => 'المسترجع';

  @override
  String get startReturnTitle => 'بدء إرجاع';

  @override
  String get startReturnSubtitle => 'ابحث عن عملية البيع الأصلية وأرجع العناصر';

  @override
  String get findSalePanel => 'البحث عن عملية بيع';

  @override
  String get recentSalesHint => 'المبيعات الأخيرة معروضة أدناه';

  @override
  String get showRecentSalesAction => 'عرض المبيعات الأخيرة';

  @override
  String get returnItemsPanel => 'إرجاع العناصر';

  @override
  String get enterQtyToReturnDesc => 'أدخل الكمية المراد إرجاعها لكل عنصر';

  @override
  String productHashLabel(String id, String qty, String price) {
    return 'المنتج #$id — $qty بسعر $price د.ج';
  }

  @override
  String get returnQtyLabel => 'كمية الإرجاع';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get reasonDamaged => 'تالف';

  @override
  String get reasonWrongItem => 'عنصر خاطئ';

  @override
  String get reasonChangedMind => 'تغيير الرأي';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get enterQtyAtLeastOne => 'أدخل كمية لعنصر واحد على الأقل';

  @override
  String get backAction => 'رجوع';

  @override
  String get confirmReturnAction => 'تأكيد الإرجاع';

  @override
  String get unknownProductLabel => 'غير معروف';

  @override
  String returnLineDesc(String name, String qty, String price) {
    return '$name — $qty بسعر $price د.ج';
  }

  @override
  String returnRecordedCashMsg(String amount) {
    return 'تم تسجيل الإرجاع. استرجاع $amount د.ج نقدًا.';
  }

  @override
  String returnRecordedDebtMsg(String amount) {
    return 'تم تسجيل الإرجاع. تم تخفيض الدين بمقدار $amount د.ج.';
  }

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get viewReportsAction => 'عرض التقارير';

  @override
  String get reportsSubtitle => 'أداء المبيعات والتصدير';

  @override
  String get csvExportAction => 'CSV';

  @override
  String get pdfExportAction => 'PDF';

  @override
  String get rangeToday => 'اليوم';

  @override
  String get rangeWeek => 'هذا الأسبوع';

  @override
  String get rangeMonth => 'هذا الشهر';

  @override
  String get rangeCustom => 'مخصص';

  @override
  String get revenueTrendPanel => 'اتجاه الإيرادات';

  @override
  String get noSalesInRange => 'لا توجد مبيعات في هذه الفترة.';

  @override
  String get bestSellingProductsPanel => 'أفضل المنتجات مبيعًا';

  @override
  String get colUnitsSold => 'الوحدات المباعة';

  @override
  String get printSavePdfTooltip => 'طباعة / حفظ PDF';

  @override
  String invoiceHashTitle(String id) {
    return 'الفاتورة #$id';
  }

  @override
  String invoiceSubtitle(String id, String date) {
    return 'البيع #$id — $date';
  }

  @override
  String invoiceSubtitleWithCustomer(String id, String date, String customer) {
    return 'البيع #$id — $date — $customer';
  }

  @override
  String invoiceTotalLine(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String invoicePaidLine(String amount) {
    return 'المدفوع: $amount';
  }

  @override
  String invoiceRemainingLine(String amount) {
    return 'المتبقي: $amount';
  }

  @override
  String get activityLogTitle => 'سجل النشاط';

  @override
  String get activityLogSubtitle => 'سجل الإجراءات المهمة في المحل';

  @override
  String get categoryLabel => 'التصنيف';

  @override
  String get catAll => 'الكل';

  @override
  String get catSale => 'بيع';

  @override
  String get catPurchase => 'شراء';

  @override
  String get catReturn => 'إرجاع';

  @override
  String get catProduct => 'منتج';

  @override
  String get catCategory => 'تصنيف';

  @override
  String get catCustomer => 'زبون';

  @override
  String get catSupplier => 'مورد';

  @override
  String get catPayment => 'دفعة';

  @override
  String get entriesPanel => 'السجلات';

  @override
  String recordsCountDesc(int count) {
    return '$count سجل';
  }

  @override
  String get noActivityInRange => 'لا يوجد نشاط في هذه الفترة.';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة';

  @override
  String get unlockAction => 'فتح';

  @override
  String get amountPaidHintLabel =>
      'المبلغ المدفوع (اتركه فارغًا للسعر الكامل)';

  @override
  String get enterValidAmountPaid => 'أدخل مبلغًا مدفوعًا صحيحًا';

  @override
  String get amountPaidExceedsTotal =>
      'لا يمكن أن يتجاوز المبلغ المدفوع الإجمالي';

  @override
  String get ctrlFHint => 'Ctrl+F';

  @override
  String get cropPhotoTitle => 'قص الصورة';

  @override
  String get croppingEllipsis => 'جارٍ القص...';

  @override
  String get cropSaveAction => 'قص وحفظ';

  @override
  String couldNotCropImage(String cause) {
    return 'تعذر قص الصورة: $cause';
  }

  @override
  String get productDetailFallbackTitle => 'تفاصيل المنتج';

  @override
  String get productNoLongerExists => 'هذا المنتج لم يعد موجودًا.';

  @override
  String get removePhotoTitle => 'إزالة الصورة؟';

  @override
  String get removePhotoMessage => 'سيتم حذف صورة المنتج نهائيًا.';

  @override
  String get noPhotoLabel => 'لا توجد صورة';

  @override
  String get changePhotoAction => 'تغيير الصورة';

  @override
  String get searchImagesOnlineAction => 'البحث عن صور عبر الإنترنت';

  @override
  String get searchImagesOnlineHint =>
      'يفتح متصفحك — انقر بزر الفأرة الأيمن واحفظ أي صورة تعجبك، ثم استخدم \"تغيير الصورة\" لإضافتها هنا.';

  @override
  String get searchImagesOnlineDisabledHint => 'أدخل اسم المنتج أولاً';

  @override
  String get removePhotoAction => 'إزالة الصورة';

  @override
  String batchHashLabel(int n) {
    return 'الدفعة #$n';
  }

  @override
  String get deletePermanentlyTitle => 'حذف نهائي؟';

  @override
  String deletePermanentlyMessage(String name) {
    return 'حذف \"$name\" نهائيًا؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deletePermanentlyAction => 'حذف نهائي';

  @override
  String get forceDeleteAction => 'حذف قسري';

  @override
  String get forceDeleteTitle => 'حذف المنتج قسريًا؟';

  @override
  String forceDeleteWarning(String name) {
    return 'سيؤدي هذا إلى حذف \"$name\" نهائيًا مع جميع مبيعاته ومشترياته وسجل مخزونه. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String forceDeleteTypeToConfirm(String name) {
    return 'اكتب \"$name\" للتأكيد';
  }

  @override
  String forceDeleteSuccessMessage(String name) {
    return 'تم حذف \"$name\" وكل سجله نهائيًا.';
  }

  @override
  String get securityPanel => 'الأمان';

  @override
  String get securityPanelDesc => 'احمِ التطبيق بكلمة مرور';

  @override
  String get passwordIsSet => 'تم تعيين كلمة المرور';

  @override
  String get noPasswordSet => 'لم يتم تعيين كلمة مرور';

  @override
  String get changeAction => 'تغيير';

  @override
  String get setPasswordAction => 'تعيين كلمة مرور';

  @override
  String get setPasswordDialogTitle => 'تعيين كلمة مرور';

  @override
  String get changePasswordDialogTitle => 'تغيير كلمة المرور';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة مرور جديدة';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get removePasswordDialogTitle => 'إزالة كلمة المرور';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get customerSalesLabel => 'مبيعات الزبائن';

  @override
  String invoiceCountDesc(int count) {
    return '$count فاتورة';
  }

  @override
  String get noCustomerSalesYet => 'لا توجد مبيعات زبائن مسجلة بعد.';

  @override
  String get supplierPurchasesLabel => 'مشتريات الموردين';

  @override
  String purchaseCountDesc(int count) {
    return '$count عملية شراء';
  }

  @override
  String get noSupplierPurchasesYet => 'لا توجد مشتريات موردين مسجلة بعد.';

  @override
  String get colCustomer => 'الزبون';

  @override
  String get invoiceAction => 'الفاتورة';

  @override
  String get colNote => 'ملاحظة';

  @override
  String get colAmount => 'المبلغ';

  @override
  String get remainingOwedLabel => 'المتبقي المستحق';

  @override
  String get purchasesLabel => 'المشتريات';

  @override
  String get zeroFullyOnCreditHint => '0 = بالكامل على الدين';

  @override
  String saleItemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String get addAction => 'إضافة';

  @override
  String csvSavedMessage(String path) {
    return 'تم الحفظ: $path';
  }

  @override
  String activityLogSaleCreated(String amount) {
    return 'تم تسجيل عملية بيع بقيمة $amount';
  }

  @override
  String activityLogSaleUpdated(int refId) {
    return 'تم تحديث عملية البيع #$refId';
  }

  @override
  String activityLogSaleDeleted(int refId) {
    return 'تم حذف عملية البيع #$refId واسترجاع المخزون';
  }

  @override
  String activityLogPurchaseCreated(String amount, String entityName) {
    return 'تم تسجيل عملية شراء بقيمة $amount من $entityName';
  }

  @override
  String activityLogPurchaseUpdated(int refId) {
    return 'تم تحديث عملية الشراء #$refId';
  }

  @override
  String activityLogReturnCreated(int refId, String amount) {
    return 'تم تسجيل إرجاع لعملية البيع #$refId، استرجاع $amount';
  }

  @override
  String activityLogProductCreated(String entityName) {
    return 'تم إنشاء المنتج \"$entityName\"';
  }

  @override
  String activityLogProductUpdated(String entityName) {
    return 'تم تعديل المنتج \"$entityName\"';
  }

  @override
  String activityLogProductDeleted(String entityName) {
    return 'تم حذف المنتج \"$entityName\" نهائيًا';
  }

  @override
  String activityLogProductArchived(String entityName) {
    return 'تمت أرشفة المنتج \"$entityName\"';
  }

  @override
  String activityLogProductRestored(String entityName) {
    return 'تمت استعادة المنتج \"$entityName\"';
  }

  @override
  String activityLogCategoryCreated(String entityName) {
    return 'تم إنشاء التصنيف \"$entityName\"';
  }

  @override
  String activityLogCategoryUpdated(String entityName) {
    return 'تم تعديل التصنيف \"$entityName\"';
  }

  @override
  String activityLogCategoryDeleted(String entityName) {
    return 'تم حذف التصنيف \"$entityName\"';
  }

  @override
  String activityLogCustomerCreated(String entityName) {
    return 'تم إنشاء الزبون \"$entityName\"';
  }

  @override
  String activityLogCustomerUpdated(String entityName) {
    return 'تم تعديل الزبون \"$entityName\"';
  }

  @override
  String activityLogCustomerArchived(String entityName) {
    return 'تمت أرشفة الزبون \"$entityName\"';
  }

  @override
  String activityLogCustomerRestored(String entityName) {
    return 'تمت استعادة الزبون \"$entityName\"';
  }

  @override
  String activityLogSupplierCreated(String entityName) {
    return 'تم إنشاء المورد \"$entityName\"';
  }

  @override
  String activityLogSupplierUpdated(String entityName) {
    return 'تم تعديل المورد \"$entityName\"';
  }

  @override
  String activityLogSupplierArchived(String entityName) {
    return 'تمت أرشفة المورد \"$entityName\"';
  }

  @override
  String activityLogSupplierRestored(String entityName) {
    return 'تمت استعادة المورد \"$entityName\"';
  }

  @override
  String activityLogPaymentReceived(String amount, String entityName) {
    return 'تم تسجيل دفعة بقيمة $amount — $entityName';
  }

  @override
  String activityLogSaleCreatedFor(String amount, String entityName) {
    return 'تم تسجيل عملية بيع بقيمة $amount لـ $entityName';
  }

  @override
  String get priceModePerUnit => 'بالوحدة';

  @override
  String get priceModeTotal => 'السعر الإجمالي';

  @override
  String get totalPricePaidLabel => 'السعر الإجمالي المدفوع';

  @override
  String perUnitPreview(String price, String unit) {
    return '≈ $price لكل $unit';
  }

  @override
  String get statCustomersOwe => 'الزبائن مدينون لك';

  @override
  String get statOwedToSuppliers => 'أنت مدين للموردين';

  @override
  String get recentActivityPanel => 'النشاط الأخير';

  @override
  String get noRecentActivity => 'لا يوجد نشاط بعد.';

  @override
  String get navSectionOverview => 'نظرة عامة';

  @override
  String get navSectionInventory => 'المخزون';

  @override
  String get navSectionSales => 'المبيعات';

  @override
  String get navSectionAdmin => 'الإدارة';

  @override
  String get securityQuestionLabel => 'سؤال الأمان';

  @override
  String get securityAnswerLabel => 'إجابة الأمان';

  @override
  String get securityQuestionRequired => 'أدخل سؤال أمان';

  @override
  String get securityAnswerRequired => 'أدخل إجابة';

  @override
  String get forgotPasswordAction => 'نسيت كلمة المرور؟';

  @override
  String get recoveryCodeDialogTitle => 'رمز الاسترجاع الخاص بك';

  @override
  String get recoveryCodeSaveWarning =>
      'احفظ هذا الرمز في مكان آمن — ستحتاجه إذا نسيت كلمة المرور مرة أخرى:';

  @override
  String get recoveryCodeAckCheckbox => 'لقد حفظت هذا الرمز';

  @override
  String get continueAction => 'متابعة';

  @override
  String get recoveryChooseMethodTitle => 'استرجاع الوصول';

  @override
  String get recoveryMethodQuestion => 'الإجابة عن سؤال الأمان';

  @override
  String get recoveryMethodCode => 'إدخال رمز الاسترجاع';

  @override
  String get recoveryCodeFieldLabel => 'رمز الاسترجاع';

  @override
  String get recoveryIncorrectAnswer => 'هذه الإجابة غير مطابقة';

  @override
  String get recoveryIncorrectCode => 'هذا الرمز غير مطابق';

  @override
  String get recoveryNewPasswordTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get recoveryNotAvailableTitle => 'الاسترجاع غير متاح';

  @override
  String get recoveryNotAvailableMessage =>
      'لم يتم إعداد سؤال أمان أو رمز استرجاع لهذا التثبيت. تواصل مع الدعم الفني للمساعدة في إعادة تعيين كلمة المرور.';

  @override
  String get verifyAction => 'تحقق';

  @override
  String get securityQuestionShopName => 'ما اسم أول محل أو مشروع تجاري لك؟';

  @override
  String get securityQuestionMotherName => 'ما هو الاسم الأول لوالدتك؟';

  @override
  String get securityQuestionBirthCity => 'في أي مدينة وُلدت؟';

  @override
  String get securityQuestionFirstPet => 'ما اسم أول حيوان أليف لك؟';

  @override
  String get securityQuestionFavoriteProduct => 'ما هو منتجك المفضل للبيع؟';

  @override
  String get copyCodeAction => 'نسخ الرمز';

  @override
  String get codeCopiedMessage => 'تم نسخ الرمز إلى الحافظة';

  @override
  String get insightsTitle => 'اقتراحات ذكية';

  @override
  String get insightsSubtitle => 'اقتراحات مبنية على بيانات نشاط محلك';

  @override
  String get statNextWeekEstimate => 'توقع الأسبوع القادم';

  @override
  String get statNextMonthEstimate => 'توقع الشهر القادم';

  @override
  String todayAnomalyLowMessage(String today, String avg) {
    return 'إيرادات اليوم ($today) منخفضة بشكل غير معتاد مقارنة بمتوسطك الأخير ($avg).';
  }

  @override
  String todayAnomalyHighMessage(String today, String avg) {
    return 'إيرادات اليوم ($today) مرتفعة بشكل غير معتاد مقارنة بمتوسطك الأخير ($avg).';
  }

  @override
  String get reorderSuggestionsPanel => 'اقتراحات إعادة الطلب';

  @override
  String get reorderSuggestionsDesc =>
      'منتجات قد تنفد قريبًا بناءً على وتيرة المبيعات الأخيرة';

  @override
  String get colDaysLeft => 'الأيام المتبقية';

  @override
  String get colSuggestedQty => 'الكمية المقترحة';

  @override
  String get colSupplier => 'المورد';

  @override
  String get noReorderSuggestions => 'لا شيء يحتاج إعادة طلب حاليًا.';

  @override
  String get stagnantProductsPanel => 'مخزون بطيء الحركة';

  @override
  String get stagnantProductsDesc =>
      'متوفر في المخزون لكن بدون مبيعات خلال 30 يومًا';

  @override
  String get noStagnantProducts => 'لا يوجد مخزون بطيء الحركة حاليًا.';

  @override
  String get oldDebtCustomersPanel => 'عملاء بديون قديمة';

  @override
  String get oldDebtCustomersDesc =>
      'أرصدة لم تشهد أي دفعة أو عملية شراء منذ أكثر من 30 يومًا';

  @override
  String get noOldDebtCustomers => 'لا توجد ديون عملاء متأخرة حاليًا.';

  @override
  String get lastActivityLabel => 'آخر نشاط';

  @override
  String get supplierPriorityPanel => 'الموردون الأولى بالدفع';

  @override
  String get supplierPriorityDesc =>
      'الموردون الذين يُدان لهم بأكبر المبالغ، مرتبين حسب المبلغ المستحق';

  @override
  String get noSupplierPriority => 'لا توجد مستحقات لأي مورد حاليًا.';

  @override
  String reorderNoticeMessage(int count) {
    return '$count منتج يحتاج إعادة طلب قريبًا';
  }

  @override
  String suggestedPriceHint(String price) {
    return 'مقترح: $price (بناءً على منتجات مشابهة)';
  }

  @override
  String get useSuggestionAction => 'استخدام';
}
