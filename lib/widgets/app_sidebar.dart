import 'package:flutter/material.dart';
import 'package:nova_pro/l10n/generated/app_localizations.dart';

class NavItem {
  final IconData icon;
  final String label;
  final int index;
  const NavItem(this.icon, this.label, this.index);
}

List<NavItem> navItemsFor(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [
    NavItem(Icons.dashboard_outlined, l10n.navDashboard, 0),
    NavItem(Icons.inventory_2_outlined, l10n.navProducts, 1),
    NavItem(Icons.local_shipping_outlined, l10n.suppliersTitle, 2),
    NavItem(Icons.people_outline, l10n.customersTitle, 3),
    NavItem(Icons.category_outlined, l10n.navCategories, 4),
    NavItem(Icons.point_of_sale_outlined, l10n.navTodaySales, 5),
    NavItem(Icons.archive_outlined, l10n.navArchive, 6),
    NavItem(Icons.history_toggle_off, l10n.returnsTitle, 7),
    NavItem(Icons.bar_chart_outlined, l10n.reportsTitle, 8),
    NavItem(Icons.history_edu_outlined, l10n.activityLogTitle, 9),
    NavItem(Icons.settings_outlined, l10n.navSettings, 10),
  ];
}


class AppSidebar extends StatelessWidget {
  final String shopName;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppSidebar({
    super.key,
    required this.shopName,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shopName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: navItemsFor(context).map((item) {
                final selected = item.index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: selected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(item.index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}