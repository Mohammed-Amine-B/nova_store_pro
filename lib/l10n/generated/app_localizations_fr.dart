// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Nova Store';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navProducts => 'Produits';

  @override
  String get navCategories => 'Catégories';

  @override
  String get navTodaySales => 'Ventes du jour';

  @override
  String get navArchive => 'Archives';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardSubtitle => 'Vue d\'ensemble du magasin';

  @override
  String get statProducts => 'Produits';

  @override
  String get statCategories => 'Catégories';

  @override
  String get statTodaySales => 'Ventes du jour';

  @override
  String get statLowStock => 'Stock faible';

  @override
  String salesCount(int count) {
    return '$count ventes';
  }

  @override
  String get lowStockPanelTitle => 'Produits en stock faible';

  @override
  String lowStockPanelDesc(int count) {
    return '$count produits à réapprovisionner';
  }

  @override
  String get noLowStockProducts => 'Aucun produit en stock faible';

  @override
  String unitsLeft(String count) {
    return '$count restants';
  }

  @override
  String get productsTitle => 'Produits';

  @override
  String get productsSubtitle => 'Votre catalogue complet';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get statTotalProducts => 'Total des produits';

  @override
  String get statTotalUnits => 'Unités en stock';

  @override
  String get statStockValue => 'Valeur du stock';

  @override
  String get atBuyPrice => 'Au prix d\'achat';

  @override
  String get allProductsPanel => 'Tous les produits';

  @override
  String shownOfTotal(int shown, int total) {
    return '$shown sur $total affichés';
  }

  @override
  String get searchProductsHint => 'Rechercher par nom, code ou code-barres';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterLowStock => 'Stock faible';

  @override
  String get filterOutOfStock => 'Rupture de stock';

  @override
  String get colProductName => 'Nom du produit';

  @override
  String get colBarcode => 'Code-barres';

  @override
  String get colCategory => 'Catégorie';

  @override
  String get colSellingPrice => 'Prix de vente';

  @override
  String get colCurrentStock => 'Stock actuel';

  @override
  String get colStatus => 'Statut';

  @override
  String get colActions => 'Actions';

  @override
  String get statusInStock => 'En stock';

  @override
  String get statusLowStock => 'Stock faible';

  @override
  String get statusOutOfStock => 'Rupture de stock';

  @override
  String get noProductsMatch => 'Aucun produit ne correspond aux filtres.';

  @override
  String get removeProductTitle => 'Retirer le produit ?';

  @override
  String removeProductMessage(String name) {
    return '\"$name\" sera archivé et masqué du catalogue.';
  }

  @override
  String get removeAction => 'Retirer';

  @override
  String get productNameLabel => 'Nom';

  @override
  String get productCodeLabel => 'Code';

  @override
  String get barcodeOptionalLabel => 'Code-barres (facultatif)';

  @override
  String get categoryOptionalLabel => 'Catégorie (facultatif)';

  @override
  String get noneOption => 'Aucune';

  @override
  String get lowStockThresholdLabel => 'Seuil de stock faible';

  @override
  String get variantSizeLabel => 'Taille (facultatif)';

  @override
  String get variantSizeHint => 'ex. 4mm, Grand, 1kg';

  @override
  String get variantsPanel => 'Autres tailles';

  @override
  String get variantsPanelDesc =>
      'Autres produits dans le même groupe de variantes';

  @override
  String get unitTypeLabel => 'Unité';

  @override
  String get unitTypePiece => 'Pièce';

  @override
  String get unitTypeKg => 'Kilogramme (kg)';

  @override
  String get unitTypeMeter => 'Mètre (m)';

  @override
  String get productInfoPanel => 'Informations du produit';

  @override
  String get minimumStockLabel => 'Stock minimum';

  @override
  String get batchesLabel => 'Lots';

  @override
  String get currentStockLabel => 'Stock actuel';

  @override
  String get sellingPriceLabel => 'Prix de vente';

  @override
  String get costPriceLabel => 'Prix de revient';

  @override
  String get notSet => 'Non défini';

  @override
  String get batchesPanelDesc =>
      'FIFO — le lot le plus ancien est vendu en premier';

  @override
  String get noBatchesYet =>
      'Aucun stock pour l\'instant. Utilisez « Ajouter du stock » pour enregistrer le premier lot.';

  @override
  String get colBatch => 'Lot';

  @override
  String get colBuyPrice => 'Prix d\'achat';

  @override
  String get colRemainingQuantity => 'Quantité restante';

  @override
  String get colPurchaseDate => 'Date d\'achat';

  @override
  String get nextOutTag => 'PROCHAIN À VENDRE';

  @override
  String get quickActionsPanel => 'Actions rapides';

  @override
  String get addStock => 'Ajouter du stock';

  @override
  String get viewStockMovements => 'Voir les mouvements de stock';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get buyPriceLabel => 'Prix d\'achat';

  @override
  String get sellingPriceFieldLabel => 'Prix de vente';

  @override
  String get purchaseDateLabel => 'Date d\'achat';

  @override
  String get stockMovementsTitle => 'Mouvements de stock';

  @override
  String get noMovementsRecorded => 'Aucun mouvement enregistré.';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String categoriesCount(int count) {
    return '$count catégories';
  }

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get allCategoriesPanel => 'Toutes les catégories';

  @override
  String get noCategoriesYet => 'Aucune catégorie pour l\'instant';

  @override
  String categoryProductsCount(int count) {
    return '$count produits';
  }

  @override
  String get categoryNameLabel => 'Nom de la catégorie';

  @override
  String get deleteCategoryTitle => 'Supprimer la catégorie ?';

  @override
  String deleteCategoryMessage(String name) {
    return 'Supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String get todaySalesTitle => 'Ventes du jour';

  @override
  String get addProductLabel => 'Ajouter un produit';

  @override
  String get searchToSellHint => 'Rechercher un produit à vendre...';

  @override
  String get salesTodayPanel => 'Ventes du jour';

  @override
  String get colProduct => 'Produit';

  @override
  String get colQuantity => 'Quantité';

  @override
  String get colUnitPrice => 'Prix unitaire';

  @override
  String get colTotal => 'Total';

  @override
  String get statRevenue => 'Revenus';

  @override
  String get statProfit => 'Profit';

  @override
  String get statSoldItems => 'Articles vendus';

  @override
  String get fifoHint => 'FIFO';

  @override
  String get totalLabel => 'Total';

  @override
  String inStockCount(String count) {
    return '$count en stock';
  }

  @override
  String get addSaleAction => 'Ajouter la vente';

  @override
  String get enterValidQuantityPrice =>
      'Entrez une quantité et un prix valides';

  @override
  String get archiveTitle => 'Archives';

  @override
  String get archiveSubtitle => 'Journées de vente passées';

  @override
  String get salesHistoryPanel => 'Historique des ventes';

  @override
  String daysRecorded(int count) {
    return '$count jours enregistrés';
  }

  @override
  String get noArchivedDaysYet => 'Aucune journée archivée pour l\'instant.';

  @override
  String get colDate => 'Date';

  @override
  String get colSalesCount => 'Nombre de ventes';

  @override
  String get openAction => 'Ouvrir';

  @override
  String transactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get noSalesRecordedToday => 'Aucune vente enregistrée ce jour-là.';

  @override
  String get editSaleTitle => 'Modifier la vente';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get deleteSaleTitle => 'Supprimer la vente';

  @override
  String get deleteSaleMessage =>
      'Cette vente sera supprimée et le stock sera restauré.';

  @override
  String salesForDate(String date) {
    return 'Ventes — $date';
  }

  @override
  String get salesPanel => 'Ventes';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Paramètres de l\'application et du magasin';

  @override
  String get shopNamePanel => 'Nom du magasin';

  @override
  String get shopNamePanelDesc =>
      'Affiché dans la barre latérale et sur les reçus';

  @override
  String get themePanel => 'Thème';

  @override
  String get themePanelDesc => 'Choisissez l\'apparence de Nova Store';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get fontSizePanel => 'Taille du texte';

  @override
  String get fontSizePanelDesc => 'Ajustez la taille du texte dans Nova Store';

  @override
  String get fontSizeSmall => 'Petit';

  @override
  String get fontSizeMedium => 'Moyen';

  @override
  String get fontSizeLarge => 'Grand';

  @override
  String get languagePanel => 'Langue';

  @override
  String get languagePanelDesc => 'Choisissez la langue de l\'application';

  @override
  String get savedLabel => 'Enregistré';

  @override
  String get viewArchived => 'Voir les archivés';

  @override
  String get viewActive => 'Voir les actifs';

  @override
  String get restoreAction => 'Restaurer';

  @override
  String get statusArchived => 'Archivé';

  @override
  String get suppliersTitle => 'Fournisseurs';

  @override
  String get suppliersSubtitle =>
      'Les fournisseurs auprès desquels vous achetez du stock';

  @override
  String get newPurchaseAction => 'Nouvel achat';

  @override
  String get addSupplier => 'Ajouter un fournisseur';

  @override
  String get editSupplier => 'Modifier le fournisseur';

  @override
  String get statTotalSuppliers => 'Total des fournisseurs';

  @override
  String get statTotalPurchased => 'Total des achats';

  @override
  String get allSuppliersPanel => 'Tous les fournisseurs';

  @override
  String get searchSuppliersHint => 'Rechercher par nom, lieu ou téléphone';

  @override
  String get noSuppliersMatch => 'Aucun fournisseur ne correspond aux filtres.';

  @override
  String get colName => 'Nom';

  @override
  String get colLocation => 'Lieu';

  @override
  String get colPhone => 'Téléphone';

  @override
  String get colOwed => 'Dû';

  @override
  String get statusActive => 'Actif';

  @override
  String get removeSupplierTitle => 'Retirer le fournisseur ?';

  @override
  String removeSupplierMessage(String name) {
    return '\"$name\" sera archivé et masqué de la liste.';
  }

  @override
  String get recordPaymentTitle => 'Enregistrer un paiement';

  @override
  String get amountLabel => 'Montant';

  @override
  String get paymentDateLabel => 'Date de paiement';

  @override
  String get noteOptionalLabel => 'Note (facultatif)';

  @override
  String get enterValidAmount => 'Entrez un montant valide';

  @override
  String get deletePurchaseTitle => 'Supprimer l\'achat';

  @override
  String get deletePurchaseMessage =>
      'Cet achat sera supprimé et son stock sera annulé.';

  @override
  String get supplierInfoPanel => 'Informations du fournisseur';

  @override
  String get purchaseHistoryPanel => 'Historique des achats';

  @override
  String get mostRecentFirst => 'Les plus récents en premier';

  @override
  String get noPurchasesYet =>
      'Aucun achat pour l\'instant auprès de ce fournisseur.';

  @override
  String get colItems => 'Articles';

  @override
  String get colPaid => 'Payé';

  @override
  String get colRemaining => 'Restant';

  @override
  String get editPurchaseTooltip => 'Modifier l\'achat';

  @override
  String get paymentsHistoryPanel => 'Historique des paiements';

  @override
  String paymentCountDesc(int count) {
    return '$count paiement(s)';
  }

  @override
  String get noPaymentsYet => 'Aucun paiement enregistré pour l\'instant.';

  @override
  String get supplierDetailFallbackTitle => 'Détail du fournisseur';

  @override
  String get supplierNoLongerExists => 'Ce fournisseur n\'existe plus.';

  @override
  String get selectSupplierTitle => 'Sélectionner un fournisseur';

  @override
  String get searchSuppliersEllipsis => 'Rechercher un fournisseur...';

  @override
  String get noSuppliersFound => 'Aucun fournisseur trouvé.';

  @override
  String get newSupplierAction => 'Nouveau fournisseur';

  @override
  String get locationOptionalLabel => 'Lieu (facultatif)';

  @override
  String get phoneOptionalLabel => 'Téléphone (facultatif)';

  @override
  String get supplierAddProductsPanel => 'Ajouter des produits';

  @override
  String get searchProductToPurchaseDesc => 'Recherchez un produit à acheter';

  @override
  String get searchProductToAddHint => 'Rechercher un produit à ajouter...';

  @override
  String get cartPanel => 'Panier';

  @override
  String cartLineCountDesc(int count) {
    return '$count ligne(s)';
  }

  @override
  String get noLinesAddedYet => 'Aucune ligne ajoutée pour l\'instant.';

  @override
  String get searchProductAboveToStartPurchase =>
      'Recherchez un produit ci-dessus pour démarrer cet achat.';

  @override
  String get addLineAction => 'Ajouter une ligne';

  @override
  String get summaryPanel => 'Résumé';

  @override
  String itemsUnitsCount(String count) {
    return '$count unités';
  }

  @override
  String get subtotalRow => 'Sous-total';

  @override
  String get previousDebtRow => 'Dette précédente envers ce fournisseur';

  @override
  String get totalDueRow => 'Total dû';

  @override
  String get paymentPanel => 'Paiement';

  @override
  String get toRecordPaymentHintSupplier =>
      'Pour enregistrer un paiement, utilisez « Enregistrer un paiement » sur la page du fournisseur.';

  @override
  String get amountPaidRow => 'Montant payé';

  @override
  String get payFullAction => 'Payer en totalité';

  @override
  String get halfNowAction => 'Moitié maintenant';

  @override
  String get confirmPurchaseAction => 'Confirmer l\'achat';

  @override
  String editingPurchaseNum(String id) {
    return 'Modification de l\'achat n°$id';
  }

  @override
  String get draftNotSaved => 'Brouillon · pas encore enregistré';

  @override
  String supplierOwedSuffix(String amount) {
    return ' · Dû $amount';
  }

  @override
  String get sellingPriceRequiredFirstBatch =>
      'Prix de vente (obligatoire — premier stock pour ce produit)';

  @override
  String get addAtLeastOneProduct => 'Ajoutez au moins un produit au panier.';

  @override
  String get amountPaidRangeError =>
      'Le montant payé doit être compris entre 0 et le total.';

  @override
  String get customersTitle => 'Clients';

  @override
  String get customersSubtitle => 'Les personnes à qui vous vendez à crédit';

  @override
  String get newSaleAction => 'Nouvelle vente';

  @override
  String get addCustomer => 'Ajouter un client';

  @override
  String get editCustomer => 'Modifier le client';

  @override
  String get statTotalCustomers => 'Total des clients';

  @override
  String get statTotalOwed => 'Total dû';

  @override
  String get allCustomersPanel => 'Tous les clients';

  @override
  String get searchCustomersHint => 'Rechercher par nom ou téléphone';

  @override
  String get noCustomersMatch => 'Aucun client ne correspond aux filtres.';

  @override
  String get colBalance => 'Solde';

  @override
  String get viewAction => 'Voir';

  @override
  String get removeCustomerTitle => 'Retirer le client ?';

  @override
  String removeCustomerMessage(String name) {
    return '\"$name\" sera archivé et masqué de la liste.';
  }

  @override
  String get newCustomerSaleTitle => 'Nouvelle vente client';

  @override
  String get customerInfoPanel => 'Informations du client';

  @override
  String get memberSinceLabel => 'Client depuis';

  @override
  String get remainingBalanceLabel => 'Solde restant';

  @override
  String salesHistoryCountDesc(int count) {
    return '$count vente(s)';
  }

  @override
  String get noSalesYetForCustomer =>
      'Aucune vente pour l\'instant pour ce client.';

  @override
  String get colMethod => 'Méthode';

  @override
  String get viewInvoiceTooltip => 'Voir la facture';

  @override
  String get customerDetailFallbackTitle => 'Détail du client';

  @override
  String get customerNoLongerExists => 'Ce client n\'existe plus.';

  @override
  String get selectCustomerTitle => 'Sélectionner un client';

  @override
  String get searchCustomersEllipsis => 'Rechercher un client...';

  @override
  String get noCustomersFound => 'Aucun client trouvé.';

  @override
  String get newCustomerAction => 'Nouveau client';

  @override
  String get chooseWhoSaleFor => 'Choisissez pour qui est cette vente';

  @override
  String get customerAddProductsPanel => 'Ajouter des produits';

  @override
  String get addProductsDesc => 'Recherchez, scannez ou touchez un favori';

  @override
  String get frequentlySoldLabel => 'SOUVENT VENDU';

  @override
  String lowStockLeftSuffix(String qty) {
    return 'Faible · $qty restant';
  }

  @override
  String get tapProductAboveToStartSale =>
      'Touchez un produit ci-dessus pour démarrer cette vente.';

  @override
  String get returnTooltip => 'Retour';

  @override
  String get previousBalanceRow => 'Solde précédent';

  @override
  String get toRecordPaymentHintCustomer =>
      'Pour enregistrer un paiement, utilisez « Enregistrer un paiement » sur la page du client.';

  @override
  String get confirmSaleAction => 'Confirmer la vente';

  @override
  String editingSaleNum(String id) {
    return 'Modification de la vente n°$id';
  }

  @override
  String balanceSuffix(String amount) {
    return ' · Solde $amount';
  }

  @override
  String get paymentUpdated => 'Paiement mis à jour.';

  @override
  String get amountPaidUpdateRangeError =>
      'Le montant payé doit être compris entre 0 et le total';

  @override
  String get returnsTitle => 'Retours';

  @override
  String get returnsSubtitle => 'Historique des articles retournés';

  @override
  String get allReturnsPanel => 'Tous les retours';

  @override
  String get noReturnsYet => 'Aucun retour enregistré pour l\'instant.';

  @override
  String get colSaleId => 'N° de vente';

  @override
  String get colReason => 'Raison';

  @override
  String get colRefunded => 'Remboursé';

  @override
  String get startReturnTitle => 'Démarrer un retour';

  @override
  String get startReturnSubtitle =>
      'Trouvez la vente d\'origine et retournez des articles';

  @override
  String get findSalePanel => 'Rechercher une vente';

  @override
  String get recentSalesHint => 'Ventes récentes affichées ci-dessous';

  @override
  String get showRecentSalesAction => 'Afficher les ventes récentes';

  @override
  String get returnItemsPanel => 'Retourner des articles';

  @override
  String get enterQtyToReturnDesc =>
      'Saisissez la quantité à retourner pour chaque article';

  @override
  String productHashLabel(String id, String qty, String price) {
    return 'Produit n°$id — $qty à $price DA';
  }

  @override
  String get returnQtyLabel => 'Qté à retourner';

  @override
  String get reasonLabel => 'Raison';

  @override
  String get reasonDamaged => 'Endommagé';

  @override
  String get reasonWrongItem => 'Mauvais article';

  @override
  String get reasonChangedMind => 'Changement d\'avis';

  @override
  String get reasonOther => 'Autre';

  @override
  String get enterQtyAtLeastOne =>
      'Saisissez une quantité pour au moins un article';

  @override
  String get backAction => 'Retour';

  @override
  String get confirmReturnAction => 'Confirmer le retour';

  @override
  String get unknownProductLabel => 'Inconnu';

  @override
  String returnLineDesc(String name, String qty, String price) {
    return '$name — $qty à $price DA';
  }

  @override
  String returnRecordedCashMsg(String amount) {
    return 'Retour enregistré. Remboursement de $amount DA en espèces.';
  }

  @override
  String returnRecordedDebtMsg(String amount) {
    return 'Retour enregistré. Dette réduite de $amount DA.';
  }

  @override
  String get reportsTitle => 'Rapports';

  @override
  String get reportsSubtitle => 'Performance des ventes et exports';

  @override
  String get csvExportAction => 'CSV';

  @override
  String get pdfExportAction => 'PDF';

  @override
  String get rangeToday => 'Aujourd\'hui';

  @override
  String get rangeWeek => 'Cette semaine';

  @override
  String get rangeMonth => 'Ce mois-ci';

  @override
  String get rangeCustom => 'Personnalisé';

  @override
  String get revenueTrendPanel => 'Tendance des revenus';

  @override
  String get noSalesInRange => 'Aucune vente sur cette période.';

  @override
  String get bestSellingProductsPanel => 'Meilleures ventes';

  @override
  String get colUnitsSold => 'Unités vendues';

  @override
  String get printSavePdfTooltip => 'Imprimer / Enregistrer en PDF';

  @override
  String invoiceHashTitle(String id) {
    return 'Facture n°$id';
  }

  @override
  String invoiceSubtitle(String id, String date) {
    return 'Vente n°$id — $date';
  }

  @override
  String invoiceSubtitleWithCustomer(String id, String date, String customer) {
    return 'Vente n°$id — $date — $customer';
  }

  @override
  String invoiceTotalLine(String amount) {
    return 'Total : $amount';
  }

  @override
  String invoicePaidLine(String amount) {
    return 'Payé : $amount';
  }

  @override
  String invoiceRemainingLine(String amount) {
    return 'Restant : $amount';
  }

  @override
  String get activityLogTitle => 'Journal d\'activité';

  @override
  String get activityLogSubtitle =>
      'Un historique des actions commerciales importantes';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get catAll => 'Tous';

  @override
  String get catSale => 'Vente';

  @override
  String get catPurchase => 'Achat';

  @override
  String get catReturn => 'Retour';

  @override
  String get catProduct => 'Produit';

  @override
  String get catCategory => 'Catégorie';

  @override
  String get catCustomer => 'Client';

  @override
  String get catSupplier => 'Fournisseur';

  @override
  String get catPayment => 'Paiement';

  @override
  String get entriesPanel => 'Entrées';

  @override
  String recordsCountDesc(int count) {
    return '$count enregistrement(s)';
  }

  @override
  String get noActivityInRange => 'Aucune activité sur cette période.';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get incorrectPassword => 'Mot de passe incorrect';

  @override
  String get unlockAction => 'Déverrouiller';

  @override
  String get amountPaidHintLabel =>
      'Montant payé (laisser vide pour le prix total)';

  @override
  String get enterValidAmountPaid => 'Entrez un montant payé valide';

  @override
  String get amountPaidExceedsTotal =>
      'Le montant payé ne peut pas dépasser le total';

  @override
  String get ctrlFHint => 'Ctrl+F';

  @override
  String get cropPhotoTitle => 'Recadrer la photo';

  @override
  String get croppingEllipsis => 'Recadrage...';

  @override
  String get cropSaveAction => 'Recadrer et enregistrer';

  @override
  String couldNotCropImage(String cause) {
    return 'Impossible de recadrer l\'image : $cause';
  }

  @override
  String get productDetailFallbackTitle => 'Détail du produit';

  @override
  String get productNoLongerExists => 'Ce produit n\'existe plus.';

  @override
  String get removePhotoTitle => 'Retirer la photo ?';

  @override
  String get removePhotoMessage =>
      'La photo du produit sera définitivement supprimée.';

  @override
  String get noPhotoLabel => 'Aucune photo';

  @override
  String get changePhotoAction => 'Changer la photo';

  @override
  String get removePhotoAction => 'Retirer la photo';

  @override
  String batchHashLabel(int n) {
    return 'Lot n°$n';
  }

  @override
  String get deletePermanentlyTitle => 'Supprimer définitivement ?';

  @override
  String deletePermanentlyMessage(String name) {
    return 'Supprimer définitivement \"$name\" ? Cette action est irréversible.';
  }

  @override
  String get deletePermanentlyAction => 'Supprimer définitivement';

  @override
  String get securityPanel => 'Sécurité';

  @override
  String get securityPanelDesc =>
      'Protégez l\'application avec un mot de passe';

  @override
  String get passwordIsSet => 'Mot de passe défini';

  @override
  String get noPasswordSet => 'Aucun mot de passe défini';

  @override
  String get changeAction => 'Modifier';

  @override
  String get setPasswordAction => 'Définir un mot de passe';

  @override
  String get setPasswordDialogTitle => 'Définir un mot de passe';

  @override
  String get changePasswordDialogTitle => 'Modifier le mot de passe';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmNewPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get enterNewPassword => 'Entrez un nouveau mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get currentPasswordIncorrect => 'Le mot de passe actuel est incorrect';

  @override
  String get removePasswordDialogTitle => 'Retirer le mot de passe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get customerSalesLabel => 'Ventes clients';

  @override
  String invoiceCountDesc(int count) {
    return '$count facture(s)';
  }

  @override
  String get noCustomerSalesYet =>
      'Aucune vente client enregistrée pour l\'instant.';

  @override
  String get supplierPurchasesLabel => 'Achats fournisseurs';

  @override
  String purchaseCountDesc(int count) {
    return '$count achat(s)';
  }

  @override
  String get noSupplierPurchasesYet =>
      'Aucun achat fournisseur enregistré pour l\'instant.';

  @override
  String get colCustomer => 'Client';

  @override
  String get invoiceAction => 'Facture';

  @override
  String get colNote => 'Note';

  @override
  String get colAmount => 'Montant';

  @override
  String get remainingOwedLabel => 'Reste dû';

  @override
  String get purchasesLabel => 'Achats';

  @override
  String get zeroFullyOnCreditHint => '0 = entièrement à crédit';

  @override
  String saleItemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String get addAction => 'Ajouter';

  @override
  String csvSavedMessage(String path) {
    return 'Enregistré : $path';
  }

  @override
  String activityLogSaleCreated(String amount) {
    return 'Vente de $amount enregistrée';
  }

  @override
  String activityLogSaleUpdated(int refId) {
    return 'Vente n°$refId modifiée';
  }

  @override
  String activityLogSaleDeleted(int refId) {
    return 'Vente n°$refId supprimée, stock restauré';
  }

  @override
  String activityLogPurchaseCreated(String amount, String entityName) {
    return 'Achat de $amount enregistré auprès de $entityName';
  }

  @override
  String activityLogPurchaseUpdated(int refId) {
    return 'Achat n°$refId modifié';
  }

  @override
  String activityLogReturnCreated(int refId, String amount) {
    return 'Retour enregistré pour la vente n°$refId, $amount remboursés';
  }

  @override
  String activityLogProductCreated(String entityName) {
    return 'Produit « $entityName » créé';
  }

  @override
  String activityLogProductUpdated(String entityName) {
    return 'Produit « $entityName » modifié';
  }

  @override
  String activityLogProductDeleted(String entityName) {
    return 'Produit « $entityName » supprimé définitivement';
  }

  @override
  String activityLogProductArchived(String entityName) {
    return 'Produit « $entityName » archivé';
  }

  @override
  String activityLogProductRestored(String entityName) {
    return 'Produit « $entityName » restauré';
  }

  @override
  String activityLogCategoryCreated(String entityName) {
    return 'Catégorie « $entityName » créée';
  }

  @override
  String activityLogCategoryUpdated(String entityName) {
    return 'Catégorie « $entityName » modifiée';
  }

  @override
  String activityLogCategoryDeleted(String entityName) {
    return 'Catégorie « $entityName » supprimée';
  }

  @override
  String activityLogCustomerCreated(String entityName) {
    return 'Client « $entityName » créé';
  }

  @override
  String activityLogCustomerUpdated(String entityName) {
    return 'Client « $entityName » modifié';
  }

  @override
  String activityLogCustomerArchived(String entityName) {
    return 'Client « $entityName » archivé';
  }

  @override
  String activityLogCustomerRestored(String entityName) {
    return 'Client « $entityName » restauré';
  }

  @override
  String activityLogSupplierCreated(String entityName) {
    return 'Fournisseur « $entityName » créé';
  }

  @override
  String activityLogSupplierUpdated(String entityName) {
    return 'Fournisseur « $entityName » modifié';
  }

  @override
  String activityLogSupplierArchived(String entityName) {
    return 'Fournisseur « $entityName » archivé';
  }

  @override
  String activityLogSupplierRestored(String entityName) {
    return 'Fournisseur « $entityName » restauré';
  }

  @override
  String activityLogPaymentReceived(String amount, String entityName) {
    return 'Paiement de $amount enregistré — $entityName';
  }

  @override
  String activityLogSaleCreatedFor(String amount, String entityName) {
    return 'Vente de $amount enregistrée pour $entityName';
  }

  @override
  String get priceModePerUnit => 'Par unité';

  @override
  String get priceModeTotal => 'Prix total';

  @override
  String get totalPricePaidLabel => 'Prix total payé';

  @override
  String perUnitPreview(String price, String unit) {
    return '≈ $price par $unit';
  }

  @override
  String get statCustomersOwe => 'Les clients vous doivent';

  @override
  String get statOwedToSuppliers => 'Vous devez aux fournisseurs';

  @override
  String get recentActivityPanel => 'Activité récente';

  @override
  String get viewAllAction => 'Voir tout';

  @override
  String get noRecentActivity => 'Aucune activité pour l\'instant.';

  @override
  String get navSectionOverview => 'APERÇU';

  @override
  String get navSectionInventory => 'INVENTAIRE';

  @override
  String get navSectionSales => 'VENTES';

  @override
  String get navSectionAdmin => 'ADMIN';

  @override
  String get securityQuestionLabel => 'Question de sécurité';

  @override
  String get securityAnswerLabel => 'Réponse de sécurité';

  @override
  String get securityQuestionRequired => 'Entrez une question de sécurité';

  @override
  String get securityAnswerRequired => 'Entrez une réponse';

  @override
  String get forgotPasswordAction => 'Mot de passe oublié ?';

  @override
  String get recoveryCodeDialogTitle => 'Votre code de récupération';

  @override
  String get recoveryCodeSaveWarning =>
      'Enregistrez ce code en lieu sûr — vous en aurez besoin si vous oubliez à nouveau votre mot de passe :';

  @override
  String get recoveryCodeAckCheckbox => 'J\'ai enregistré ce code';

  @override
  String get continueAction => 'Continuer';

  @override
  String get recoveryChooseMethodTitle => 'Récupérer l\'accès';

  @override
  String get recoveryMethodQuestion => 'Répondre à la question de sécurité';

  @override
  String get recoveryMethodCode => 'Entrer le code de récupération';

  @override
  String get recoveryCodeFieldLabel => 'Code de récupération';

  @override
  String get recoveryIncorrectAnswer => 'Cette réponse ne correspond pas';

  @override
  String get recoveryIncorrectCode => 'Ce code ne correspond pas';

  @override
  String get recoveryNewPasswordTitle => 'Définir un nouveau mot de passe';

  @override
  String get recoveryNotAvailableTitle => 'Récupération non disponible';

  @override
  String get recoveryNotAvailableMessage =>
      'Aucune question de sécurité ni code de récupération n\'a été configuré pour cette installation. Contactez le support technique pour réinitialiser votre mot de passe.';

  @override
  String get verifyAction => 'Vérifier';

  @override
  String get securityQuestionShopName =>
      'Quel était le nom de votre premier magasin ou commerce ?';

  @override
  String get securityQuestionMotherName => 'Quel est le prénom de votre mère ?';

  @override
  String get securityQuestionBirthCity => 'Dans quelle ville êtes-vous né(e) ?';

  @override
  String get securityQuestionFirstPet =>
      'Quel était le nom de votre premier animal de compagnie ?';

  @override
  String get securityQuestionFavoriteProduct =>
      'Quel est votre produit préféré à vendre ?';

  @override
  String get copyCodeAction => 'Copier le code';

  @override
  String get codeCopiedMessage => 'Code copié dans le presse-papiers';

  @override
  String get insightsTitle => 'Analyses intelligentes';

  @override
  String get insightsSubtitle =>
      'Des suggestions basées sur les données d\'activité de votre magasin';

  @override
  String get statNextWeekEstimate => 'Estimation semaine prochaine';

  @override
  String get statNextMonthEstimate => 'Estimation mois prochain';

  @override
  String todayAnomalyLowMessage(String today, String avg) {
    return 'Le chiffre d\'affaires d\'aujourd\'hui ($today) est anormalement bas par rapport à votre moyenne récente ($avg).';
  }

  @override
  String todayAnomalyHighMessage(String today, String avg) {
    return 'Le chiffre d\'affaires d\'aujourd\'hui ($today) est anormalement élevé par rapport à votre moyenne récente ($avg).';
  }

  @override
  String get reorderSuggestionsPanel => 'Suggestions de réapprovisionnement';

  @override
  String get reorderSuggestionsDesc =>
      'Produits susceptibles de s\'épuiser bientôt, selon le rythme de ventes récent';

  @override
  String get colDaysLeft => 'Jours restants';

  @override
  String get colSuggestedQty => 'Qté suggérée';

  @override
  String get colSupplier => 'Fournisseur';

  @override
  String get noReorderSuggestions => 'Rien à réapprovisionner pour l\'instant.';

  @override
  String get stagnantProductsPanel => 'Stock à rotation lente';

  @override
  String get stagnantProductsDesc =>
      'En stock mais aucune vente depuis 30 jours';

  @override
  String get noStagnantProducts =>
      'Aucun stock à rotation lente pour l\'instant.';

  @override
  String reorderNoticeMessage(int count) {
    return '$count produits à réapprovisionner bientôt';
  }

  @override
  String suggestedPriceHint(String price) {
    return 'Suggéré : $price (basé sur des produits similaires)';
  }

  @override
  String get useSuggestionAction => 'Utiliser';
}
