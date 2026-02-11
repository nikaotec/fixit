import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/firestore_equipment_service.dart';
import 'add_edit_equipment_screen.dart';
import 'maintenance_execution_entry_screen.dart';
import '../widgets/equipment_qr_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _equipmentList = [];
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _loadEquipment();
    _searchController.addListener(_filterList);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No token check needed
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipment() async {
    setState(() => _isLoading = true);
    try {
      final list = await FirestoreEquipmentService.getAll();
      if (mounted) {
        setState(() {
          _equipmentList = list.map((e) {
            final map = e.toMap();
            map['id'] = e.id;
            return map;
          }).toList();
          _filterList();
        });
      }
    } catch (e) {
      print('Error loading equipment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading equipment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredList = List.from(_equipmentList);
      } else {
        _filteredList = _equipmentList.where((item) {
          final name = item['nome']?.toString().toLowerCase() ?? '';
          final serial = item['codigo']?.toString().toLowerCase() ?? '';
          return name.contains(query) || serial.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, isDark, l10n),

            // Search Bar (Sticky-like)
            _buildSearchBar(context, isDark, l10n),

            // Filter Chips
            _buildFilterChips(context, isDark, l10n),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.itemsFound(_filteredList.length).toUpperCase(),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: isDark
                                ? AppColors.slate600
                                : AppColors.slate300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noEquipmentYet,
                            style: AppTypography.subtitle1.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              l10n.noEquipmentMessage,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyTextSmall.copyWith(
                                color: isDark
                                    ? AppColors.slate400
                                    : AppColors.slate500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEquipment,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          100,
                        ), // Bottom padding for FAB
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildEquipmentCard(
                            context,
                            _filteredList[index],
                            isDark,
                            l10n,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scan FAB
          FloatingActionButton(
            heroTag: "scanFab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceExecutionEntryScreen(),
                ),
              );
            },
            backgroundColor: isDark ? AppColors.surfaceDarkTheme : Colors.white,
            foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
            elevation: 4,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 16),
          // Add FAB
          FloatingActionButton(
            heroTag: "addFab",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditEquipmentScreen(),
                ),
              );
              if (result == true) {
                _loadEquipment();
              }
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8, // Higher elevation + shadow as per design
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDarkTheme : Colors.white)
            .withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              l10n.equipmentInventory,
              style: AppTypography.headline3.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_horiz,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A37) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(Icons.search, color: Color(0xFF92ADC9)),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchEquipmentPlaceholder,
                  hintStyle: const TextStyle(color: Color(0xFF92ADC9)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip(l10n.byClient, isDark),
          const SizedBox(width: 12),
          _buildFilterChip(l10n.category, isDark),
          const SizedBox(width: 12),
          _buildFilterChip(l10n.status, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A37) : Colors.white,
        borderRadius: BorderRadius.circular(999), // Pill shape
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more,
            size: 18,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final status = 'Operational'; // Mock status if not in payload
    final statusColor = Colors.green;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditEquipmentScreen(equipment: item),
          ),
        );
        if (result == true) {
          // If changes were saved, reload the list
          _loadEquipment(); // Since we are in the State class, we can call this directly?
          // Wait, _loadEquipment is in _InventoryScreenState, and we are in _buildEquipmentCard which is in _InventoryScreenState. Yes.
          // Wait, _loadEquipment is defined in the state class. build method is in state class. _buildEquipmentCard is in state class. Correct.
          // Re-checking scope. Yes, it is fine.
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF192633) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Image / Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C3B4E) : AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.1,
                  ),
                ),
                image: item['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(item['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item['imageUrl'] == null
                  ? const Icon(
                      Icons.inventory_2,
                      color: Color(0xFF92ADC9),
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF92ADC9)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nome'] ?? 'Unnamed',
                            style: AppTypography.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item['codigo'] ?? 'No Serial'} • ${item['cliente']?['nome'] ?? 'Unknown Client'}',
                            style: const TextStyle(
                              color: Color(0xFF92ADC9),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => EquipmentQrDialog.show(context, item),
                        icon: const Icon(
                          Icons.qr_code,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        tooltip: l10n.generateQr,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
