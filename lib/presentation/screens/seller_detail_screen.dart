import 'package:elshaf3y_store/presentation/screens/payment_screen.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:elshaf3y_store/features/transaction_feature/data/models/transaction_model.dart';
import 'package:elshaf3y_store/features/transaction_feature/data/repositories/transaction_repository.dart';
import 'package:elshaf3y_store/features/reports/services/report_service.dart';
import 'package:open_filex/open_filex.dart';

class SellerDetailScreen extends StatefulWidget {
  final Seller seller;

  const SellerDetailScreen({super.key, required this.seller});

  @override
  _SellerDetailScreenState createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  final TextEditingController carPartNameController = TextEditingController();
  final TextEditingController carPartPriceController = TextEditingController();
  final TextEditingController carPartPurchasePriceController =
      TextEditingController();
  final TextEditingController carPartDescriptionController =
      TextEditingController();
  final TextEditingController carPartQuantityController =
      TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  List<SubItem> tempSubItems = [];

  final TransactionRepository _transactionRepository = TransactionRepository();
  final ReportService _reportService = ReportService();

  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) setState(() => _showFab = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) setState(() => _showFab = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Theme
          appBar: AppBar(
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor, // ✅ Theme
            elevation: Theme.of(context).appBarTheme.elevation,
            iconTheme: Theme.of(context).iconTheme, // ✅ Theme
            centerTitle: true,
            title: BlocBuilder<SellerCubit, SellerState>(
              builder: (context, state) {
                if (state is SellerLoaded) {
                  final updatedSeller =
                      state.sellers.firstWhere((s) => s.id == widget.seller.id);
                  final carPartsForSelectedMonth =
                      updatedSeller.carParts.where((carPart) {
                    return carPart.dateAdded.month == selectedMonth &&
                        carPart.dateAdded.year == selectedYear;
                  }).toList();

                  double monthlyActualGain = 0.0;
                  for (var carPart in carPartsForSelectedMonth) {
                    monthlyActualGain += carPart.getActualGain();
                  }

                  return Column(
                    children: [
                      Hero(
                        tag: 'seller_${widget.seller.id}',
                        child: Text(
                          widget.seller.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // ✅ Theme
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear Gain: \$${monthlyActualGain.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: monthlyActualGain >= 0
                              ? (isDark ? Colors.green.shade300 : Colors.green)
                              : (isDark
                                  ? Colors.red.shade300
                                  : Colors.red), // ✅ Theme
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return Text('Loading...',
                    style: Theme.of(context).textTheme.titleLarge);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.table_chart,
                    color: isDark
                        ? Colors.green.shade300
                        : Colors.green), // ✅ Theme
                tooltip: 'Export to Excel',
                onPressed: _exportSellerToExcel,
              ),
              IconButton(
                icon: Icon(Icons.picture_as_pdf,
                    color:
                        isDark ? Colors.red.shade300 : Colors.red), // ✅ Theme
                tooltip: 'Export to PDF',
                onPressed: _exportSellerToPDF,
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTopControls(isDark),
              Expanded(child: _buildCarPartsList(isDark)),
            ],
          ),
          floatingActionButton: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: _showFab ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showFab ? 1.0 : 0.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _clearCarPartControllers();
                  tempSubItems.clear();
                  _showAddSaleDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Sale'),
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // ✅ Theme
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimary, // ✅ Theme
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Theme.of(context).cardColor, // ✅ Theme
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showSortOptionsDialog(context),
            icon: const Icon(Icons.sort, size: 18),
            label: const Text('Sort'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor, // ✅ Theme
              foregroundColor:
                  Theme.of(context).textTheme.bodyLarge?.color, // ✅ Theme
              side: BorderSide(
                  color:
                      isDark ? Colors.grey.shade700 : Colors.grey), // ✅ Theme
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      isDark ? Colors.grey.shade700 : Colors.grey), // ✅ Theme
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor, // ✅ Theme
            ),
            child: DropdownButton<int>(
              value: selectedMonth,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor, // ✅ Theme
              style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
              items: List.generate(12, (index) => index + 1)
                  .map((month) => DropdownMenuItem(
                        value: month,
                        child:
                            Text(DateFormat.MMM().format(DateTime(0, month))),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedMonth = value!),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      isDark ? Colors.grey.shade700 : Colors.grey), // ✅ Theme
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor, // ✅ Theme
            ),
            child: DropdownButton<int>(
              value: selectedYear,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor, // ✅ Theme
              style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
              items: List.generate(5, (index) => DateTime.now().year - index)
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedYear = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarPartsList(bool isDark) {
    return BlocBuilder<SellerCubit, SellerState>(
      builder: (context, state) {
        if (state is SellerLoaded) {
          final updatedSeller =
              state.sellers.firstWhere((s) => s.id == widget.seller.id);
          final carPartsForSelectedMonth =
              updatedSeller.carParts.where((carPart) {
            return carPart.dateAdded.month == selectedMonth &&
                carPart.dateAdded.year == selectedYear;
          }).toList();

          if (carPartsForSelectedMonth.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 80,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey[300]), // ✅ Theme
                  const SizedBox(height: 16),
                  Text(
                    'No sales for ${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear',
                    style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey[600]), // ✅ Theme
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 90),
            itemCount: carPartsForSelectedMonth.length,
            itemBuilder: (context, index) {
              final carPart = carPartsForSelectedMonth[
                  carPartsForSelectedMonth.length - index - 1];
              return _buildCarPartCard(carPart, isDark);
            },
          );
        }
        return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary));
      },
    );
  }

  Widget _buildCarPartCard(CarPart carPart, bool isDark) {
    final totalSellingPrice = carPart.getTotalSellingPrice();

    // ✅ FIX: Multiply main item purchase price by quantity
    final mainItemCost = (carPart.purchasePrice ?? 0) * carPart.quantity;

    // ✅ FIX: Calculate sub-items cost with quantity
    final subItemsCost = carPart.subItems.fold(
      0.0,
      (sum, item) => sum + ((item.purchasePrice ?? 0) * item.quantity),
    );

    // ✅ Total purchase price = main item cost + sub-items cost
    final totalPurchasePrice = mainItemCost + subItemsCost;

    final totalPaid = carPart.getTotalPayments();
    final actualGain = carPart.getActualGain();
    final potentialGain = carPart.getPotentialGain();
    final paymentPercentage =
        totalSellingPrice > 0 ? (totalPaid / totalSellingPrice * 100) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Theme.of(context).cardColor, // ✅ Theme
      elevation: isDark ? 4 : 2, // ✅ Theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEditCarPartDialog(context, carPart),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.shade900.withOpacity(0.3)
                          : Colors.blue[50], // ✅ Theme
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_cart,
                        color: isDark
                            ? Colors.blue.shade300
                            : Colors.blue), // ✅ Theme
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          carPart.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold), // ✅ Theme
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(carPart.dateAdded),
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey[600]), // ✅ Theme
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: actualGain >= 0
                          ? (isDark
                              ? Colors.green.shade900.withOpacity(0.3)
                              : Colors.green[50])
                          : (isDark
                              ? Colors.red.shade900.withOpacity(0.3)
                              : Colors.red[50]), // ✅ Theme
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${actualGain >= 0 ? "+" : ""}\$${actualGain.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: actualGain >= 0
                            ? (isDark
                                ? Colors.green.shade300
                                : Colors.green[700])
                            : (isDark
                                ? Colors.red.shade300
                                : Colors.red[700]), // ✅ Theme
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main Item Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900.withOpacity(0.3)
                      : Colors.grey[50], // ✅ Theme
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey[200]!), // ✅ Theme
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                        'Main Item',
                        '${carPart.quantity}x @ \$${carPart.price.toStringAsFixed(2)}',
                        isDark,
                        bold: true),
                    if (carPart.purchasePrice != null)
                      _buildInfoRow(
                          'Cost',
                          '\$${carPart.purchasePrice!.toStringAsFixed(2)}',
                          isDark,
                          color:
                              isDark ? Colors.orange.shade300 : Colors.orange),
                  ],
                ),
              ),

              // Sub-Items
              if (carPart.subItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.shade900.withOpacity(0.2)
                        : Colors.blue[25], // ✅ Theme
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? Colors.blue.shade700
                            : Colors.blue[100]!), // ✅ Theme
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2,
                              size: 16,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue[700]), // ✅ Theme
                          const SizedBox(width: 6),
                          Text(
                            'Additional Items (${carPart.subItems.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue[700], // ✅ Theme
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      ...carPart.subItems.map((subItem) => Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${subItem.name} (${subItem.quantity}x)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall, // ✅ Theme
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontWeight:
                                                  FontWeight.bold), // ✅ Theme
                                    ),
                                    if (subItem.purchasePrice != null)
                                      Text(
                                        'Cost: \$${subItem.purchasePrice!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey[600]), // ✅ Theme
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Financial Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.grey.shade900.withOpacity(0.5),
                            Colors.grey.shade800.withOpacity(0.3)
                          ]
                        : [Colors.grey[50]!, Colors.white], // ✅ Theme
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey[300]!), // ✅ Theme
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Total Price',
                        '\$${totalSellingPrice.toStringAsFixed(2)}', isDark,
                        bold: true),
                    _buildInfoRow('Total Cost',
                        '\$${totalPurchasePrice.toStringAsFixed(2)}', isDark,
                        color: isDark ? Colors.orange.shade300 : Colors.orange),
                    const Divider(height: 16),
                    _buildInfoRow(
                        'Paid', '\$${totalPaid.toStringAsFixed(2)}', isDark,
                        color: isDark ? Colors.blue.shade300 : Colors.blue),
                    _buildInfoRow('Owed',
                        '\$${carPart.amountOwed.toStringAsFixed(2)}', isDark,
                        color: isDark ? Colors.red.shade300 : Colors.red),
                    const Divider(height: 16),
                    _buildInfoRow('Potential Gain',
                        '\$${potentialGain.toStringAsFixed(2)}', isDark,
                        color: isDark ? Colors.grey.shade400 : Colors.grey),
                    _buildInfoRow(
                      'Actual Gain',
                      '\$${actualGain.toStringAsFixed(2)}',
                      isDark,
                      color: actualGain >= 0
                          ? (isDark ? Colors.green.shade300 : Colors.green)
                          : (isDark ? Colors.red.shade300 : Colors.red),
                      bold: true,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),

              // Payment Progress
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Progress',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey[600])), // ✅ Theme
                      Text('${paymentPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey[700])), // ✅ Theme
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: paymentPercentage / 100,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey[200], // ✅ Theme
                      valueColor: AlwaysStoppedAnimation<Color>(
                        paymentPercentage >= 100
                            ? (isDark ? Colors.green.shade300 : Colors.green)
                            : (isDark
                                ? Colors.blue.shade300
                                : Colors.blue), // ✅ Theme
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (carPart.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  carPart.description,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey[700],
                      fontStyle: FontStyle.italic), // ✅ Theme
                ),
              ],

              // Action Buttons
              // Action Buttons
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaymentDetailsScreen(carPart: carPart)),
                    ),
                    icon: const Icon(Icons.history, size: 16),
                    label:
                        const Text('History', style: TextStyle(fontSize: 14)),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.blue.shade300 : Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _printInvoice(carPart),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label:
                        const Text('Invoice', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.purple.shade700 : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(context, carPart),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Pay', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.green.shade700 : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteCarPartDialog(context, carPart),
                    icon: Icon(Icons.delete_outline,
                        color: isDark ? Colors.red.shade300 : Colors.red,
                        size: 20),
                    tooltip: 'Delete',
                    padding: const EdgeInsets.all(6),
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {Color? color, bool bold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize - 1,
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey[700])), // ✅ Theme
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ??
                  (isDark ? Colors.grey.shade200 : Colors.black87), // ✅ Theme
            ),
          ),
        ],
      ),
    );
  }

  void _clearCarPartControllers() {
    carPartNameController.clear();
    carPartPriceController.clear();
    carPartPurchasePriceController.clear();
    carPartDescriptionController.clear();
    carPartQuantityController.clear();
  }

  // ✅ All dialogs now use Theme.of(context) for colors
  void _showAddSaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // Calculate totals
            double mainTotal =
                (double.tryParse(carPartPriceController.text) ?? 0) *
                    (int.tryParse(carPartQuantityController.text) ?? 1);
            double mainCost =
                double.tryParse(carPartPurchasePriceController.text) ?? 0;
            double subItemsTotal = tempSubItems.fold(
                0.0, (sum, item) => sum + (item.price * item.quantity));
            double subItemsCost = tempSubItems.fold(
                0.0, (sum, item) => sum + (item.purchasePrice ?? 0));
            double grandTotal = mainTotal + subItemsTotal;
            double grandCost = mainCost + subItemsCost;

            return Dialog(
              backgroundColor:
                  Theme.of(context).dialogBackgroundColor, // ✅ Theme
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 600, maxHeight: 700),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary, // ✅ Theme
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_shopping_cart,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Create New Sale',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              tempSubItems.clear();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Item Section
                            Text('Main Item',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight:
                                            FontWeight.bold)), // ✅ Theme
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartNameController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Car *',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.label),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: carPartPriceController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium, // ✅ Theme
                                    decoration: InputDecoration(
                                      labelText: 'Selling Price *',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium, // ✅ Theme
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      prefixIcon:
                                          const Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: carPartQuantityController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium, // ✅ Theme
                                    decoration: InputDecoration(
                                      labelText: 'Quantity *',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium, // ✅ Theme
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      prefixIcon: const Icon(Icons.numbers),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartPurchasePriceController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Purchase Cost',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.shopping_bag),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartDescriptionController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Item Name (Optional)',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 2,
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Sub-Items Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Additional Items',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.bold)), // ✅ Theme
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddSubItemDialog(context, setState),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Item'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary, // ✅ Theme
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (tempSubItems.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade900.withOpacity(0.3)
                                      : Colors.grey[100], // ✅ Theme
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey[300]!), // ✅ Theme
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 48,
                                          color: isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey[400]), // ✅ Theme
                                      const SizedBox(height: 8),
                                      Text('No additional items',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : Colors
                                                      .grey[600])), // ✅ Theme
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey[300]!), // ✅ Theme
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).cardColor, // ✅ Theme
                                ),
                                child: Column(
                                  children:
                                      tempSubItems.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    SubItem subItem = entry.value;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: idx > 0
                                            ? Border(
                                                top: BorderSide(
                                                    color: isDark
                                                        ? Colors.grey.shade800
                                                        : Colors.grey[200]!))
                                            : null, // ✅ Theme
                                      ),
                                      child: ListTile(
                                        isThreeLine: false, // ✅ Add this
                                        leading: CircleAvatar(
                                          backgroundColor: isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2)
                                              : Colors.blue[50], // ✅ Theme
                                          child: Text('${idx + 1}',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)), // ✅ Theme
                                        ),
                                        title: Text(subItem.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight: FontWeight
                                                        .w500)), // ✅ Theme
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${subItem.quantity}x @ \$${subItem.price.toStringAsFixed(2)} ${subItem.purchasePrice != null ? "(Cost: \$${subItem.purchasePrice!.toStringAsFixed(2)})" : ""}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        trailing: SizedBox(
                                          // ✅ Wrap in SizedBox to control width
                                          width:
                                              96, // ✅ Reduced width - just icons
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // ✅ Edit Button
                                              IconButton(
                                                icon: Icon(Icons.edit_outlined,
                                                    color: isDark
                                                        ? Colors.blue.shade300
                                                        : Colors.blue,
                                                    size: 18), // ✅ Smaller icon
                                                onPressed: () =>
                                                    _showEditSubItemDialog(
                                                        context,
                                                        setState,
                                                        idx,
                                                        subItem),
                                              ),
                                              // ✅ Delete Button
                                              IconButton(
                                                icon: Icon(Icons.delete_outline,
                                                    color: isDark
                                                        ? Colors.red.shade300
                                                        : Colors.red,
                                                    size: 18), // ✅ Smaller icon
                                                onPressed: () {
                                                  setState(() {
                                                    tempSubItems.removeAt(idx);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Colors.blue[50], // ✅ Theme
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: isDark
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3)
                                        : Colors.blue[200]!), // ✅ Theme
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                      'Main Item Total',
                                      '\$${mainTotal.toStringAsFixed(2)}',
                                      isDark),
                                  if (tempSubItems.isNotEmpty)
                                    _buildInfoRow(
                                        'Additional Items',
                                        '\$${subItemsTotal.toStringAsFixed(2)}',
                                        isDark),
                                  const Divider(),
                                  _buildInfoRow(
                                      'Grand Total',
                                      '\$${grandTotal.toStringAsFixed(2)}',
                                      isDark,
                                      bold: true,
                                      fontSize: 16),
                                  _buildInfoRow(
                                      'Total Cost',
                                      '\$${grandCost.toStringAsFixed(2)}',
                                      isDark,
                                      color: isDark
                                          ? Colors.orange.shade300
                                          : Colors.orange),
                                  _buildInfoRow(
                                    'Potential Gain',
                                    '\$${(grandTotal - grandCost).toStringAsFixed(2)}',
                                    isDark,
                                    color: (grandTotal - grandCost) >= 0
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green)
                                        : (isDark
                                            ? Colors.red.shade300
                                            : Colors.red),
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey[50], // ✅ Theme
                        border: Border(
                            top: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey[200]!)), // ✅ Theme
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                tempSubItems.clear();
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)), // ✅ Theme
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (carPartNameController.text.isEmpty ||
                                    carPartPriceController.text.isEmpty ||
                                    carPartQuantityController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all required fields'),
                                        backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                final carPart = CarPart(
                                  id: const Uuid().v4(),
                                  name: carPartNameController.text,
                                  price:
                                      double.parse(carPartPriceController.text),
                                  purchasePrice: double.tryParse(
                                      carPartPurchasePriceController.text),
                                  description:
                                      carPartDescriptionController.text,
                                  quantity:
                                      int.parse(carPartQuantityController.text),
                                  dateAdded: DateTime.now(),
                                  amountOwed: grandTotal,
                                  subItems: List.from(tempSubItems),
                                );

                                context.read<SellerCubit>().addCarPartToSeller(
                                    widget.seller.id, carPart);
                                _clearCarPartControllers();
                                tempSubItems.clear();
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('✅ Sale created successfully'),
                                      backgroundColor: Colors.green),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary, // ✅ Theme
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Create Sale',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSubItemDialog(BuildContext context, StateSetter parentSetState) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final costController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.blue[50], // ✅ Theme
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_box,
                    color: Theme.of(context).colorScheme.primary), // ✅ Theme
              ),
              const SizedBox(width: 12),
              Text('Add Item',
                  style: Theme.of(context).textTheme.titleLarge), // ✅ Theme
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                decoration: InputDecoration(
                  labelText: 'Car *',
                  labelStyle: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                      decoration: InputDecoration(
                        labelText: 'Price *',
                        labelStyle:
                            Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                      decoration: InputDecoration(
                        labelText: 'Qty *',
                        labelStyle:
                            Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                decoration: InputDecoration(
                  labelText: 'Cost (Optional)',
                  labelStyle: Theme.of(context).textTheme.bodyMedium, // ✅ Theme
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.price_change),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary)), // ✅ Theme
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    qtyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill required fields'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                final subItem = SubItem(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  purchasePrice: double.tryParse(costController.text),
                  quantity: int.parse(qtyController.text),
                );

                parentSetState(() {
                  tempSubItems.add(subItem);
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // ✅ Theme
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCarPartDialog(BuildContext context, CarPart carPart) {
    carPartNameController.text = carPart.name;
    carPartPriceController.text = carPart.price.toString();
    carPartPurchasePriceController.text =
        carPart.purchasePrice?.toString() ?? '';
    carPartDescriptionController.text = carPart.description;
    carPartQuantityController.text = carPart.quantity.toString();

    // ✅ Load existing sub-items
    tempSubItems = List.from(carPart.subItems);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // Calculate totals
            double mainTotal =
                (double.tryParse(carPartPriceController.text) ?? 0) *
                    (int.tryParse(carPartQuantityController.text) ?? 1);
            double mainCost =
                double.tryParse(carPartPurchasePriceController.text) ?? 0;
            double subItemsTotal = tempSubItems.fold(
                0.0, (sum, item) => sum + (item.price * item.quantity));
            double subItemsCost = tempSubItems.fold(
                0.0, (sum, item) => sum + (item.purchasePrice ?? 0));
            double grandTotal = mainTotal + subItemsTotal;
            double grandCost = mainCost + subItemsCost;

            return Dialog(
              backgroundColor:
                  Theme.of(context).dialogBackgroundColor, // ✅ Theme
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 600, maxHeight: 700),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Edit Sale',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              tempSubItems.clear();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Item Section
                            Text('Main Item',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight:
                                            FontWeight.bold)), // ✅ Theme
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartNameController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Car *',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.label),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: carPartPriceController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium, // ✅ Theme
                                    decoration: InputDecoration(
                                      labelText: 'Selling Price *',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium, // ✅ Theme
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      prefixIcon:
                                          const Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: carPartQuantityController,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium, // ✅ Theme
                                    decoration: InputDecoration(
                                      labelText: 'Quantity *',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium, // ✅ Theme
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      prefixIcon: const Icon(Icons.numbers),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartPurchasePriceController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Purchase Cost',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.shopping_bag),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: carPartDescriptionController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium, // ✅ Theme
                              decoration: InputDecoration(
                                labelText: 'Item Name (Optional)',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // ✅ Theme
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 2,
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Sub-Items Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Additional Items',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.bold)), // ✅ Theme
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddSubItemDialog(context, setState),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Item'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary, // ✅ Theme
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (tempSubItems.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade900.withOpacity(0.3)
                                      : Colors.grey[100], // ✅ Theme
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey[300]!), // ✅ Theme
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 48,
                                          color: isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey[400]), // ✅ Theme
                                      const SizedBox(height: 8),
                                      Text('No additional items',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : Colors
                                                      .grey[600])), // ✅ Theme
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey[300]!), // ✅ Theme
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).cardColor, // ✅ Theme
                                ),
                                child: Column(
                                  children:
                                      tempSubItems.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    SubItem subItem = entry.value;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: idx > 0
                                            ? Border(
                                                top: BorderSide(
                                                    color: isDark
                                                        ? Colors.grey.shade800
                                                        : Colors.grey[200]!))
                                            : null, // ✅ Theme
                                      ),
                                      child: ListTile(
                                        isThreeLine: false, // ✅ Add this
                                        leading: CircleAvatar(
                                          backgroundColor: isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2)
                                              : Colors.blue[50], // ✅ Theme
                                          child: Text('${idx + 1}',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)), // ✅ Theme
                                        ),
                                        title: Text(subItem.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight: FontWeight
                                                        .w500)), // ✅ Theme
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${subItem.quantity}x @ \$${subItem.price.toStringAsFixed(2)} ${subItem.purchasePrice != null ? "(Cost: \$${subItem.purchasePrice!.toStringAsFixed(2)})" : ""}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        trailing: SizedBox(
                                          // ✅ Wrap in SizedBox to control width
                                          width:
                                              96, // ✅ Reduced width - just icons
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // ✅ Edit Button
                                              IconButton(
                                                icon: Icon(Icons.edit_outlined,
                                                    color: isDark
                                                        ? Colors.blue.shade300
                                                        : Colors.blue,
                                                    size: 18), // ✅ Smaller icon
                                                onPressed: () =>
                                                    _showEditSubItemDialog(
                                                        context,
                                                        setState,
                                                        idx,
                                                        subItem),
                                              ),
                                              // ✅ Delete Button
                                              IconButton(
                                                icon: Icon(Icons.delete_outline,
                                                    color: isDark
                                                        ? Colors.red.shade300
                                                        : Colors.red,
                                                    size: 18), // ✅ Smaller icon
                                                onPressed: () {
                                                  setState(() {
                                                    tempSubItems.removeAt(idx);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Colors.blue[50], // ✅ Theme
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: isDark
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3)
                                        : Colors.blue[200]!), // ✅ Theme
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                      'Main Item Total',
                                      '\$${mainTotal.toStringAsFixed(2)}',
                                      isDark),
                                  if (tempSubItems.isNotEmpty)
                                    _buildInfoRow(
                                        'Additional Items',
                                        '\$${subItemsTotal.toStringAsFixed(2)}',
                                        isDark),
                                  const Divider(),
                                  _buildInfoRow(
                                      'Grand Total',
                                      '\$${grandTotal.toStringAsFixed(2)}',
                                      isDark,
                                      bold: true,
                                      fontSize: 16),
                                  _buildInfoRow(
                                      'Total Cost',
                                      '\$${grandCost.toStringAsFixed(2)}',
                                      isDark,
                                      color: isDark
                                          ? Colors.orange.shade300
                                          : Colors.orange),
                                  _buildInfoRow(
                                    'Potential Gain',
                                    '\$${(grandTotal - grandCost).toStringAsFixed(2)}',
                                    isDark,
                                    color: (grandTotal - grandCost) >= 0
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green)
                                        : (isDark
                                            ? Colors.red.shade300
                                            : Colors.red),
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey[50], // ✅ Theme
                        border: Border(
                            top: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey[200]!)), // ✅ Theme
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                tempSubItems.clear();
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)), // ✅ Theme
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (carPartNameController.text.isEmpty ||
                                    carPartPriceController.text.isEmpty ||
                                    carPartQuantityController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all required fields'),
                                        backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                final updatedCarPart = carPart.copyWith(
                                  name: carPartNameController.text,
                                  price:
                                      double.parse(carPartPriceController.text),
                                  purchasePrice: double.tryParse(
                                      carPartPurchasePriceController.text),
                                  description:
                                      carPartDescriptionController.text,
                                  quantity:
                                      int.parse(carPartQuantityController.text),
                                  amountOwed: carPart.amountOwed +
                                      (grandTotal -
                                          carPart
                                              .getTotalSellingPrice()), // ✅ Adjust owed amount
                                  subItems: List.from(
                                      tempSubItems), // ✅ Save edited sub-items
                                );

                                context.read<SellerCubit>().updateCarPart(
                                    widget.seller.id, updatedCarPart);
                                _clearCarPartControllers();
                                tempSubItems.clear();
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('✅ Sale updated successfully'),
                                      backgroundColor: Colors.green),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Save Changes',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSubItemDialog(BuildContext context, StateSetter parentSetState,
      int index, SubItem subItem) {
    final nameController = TextEditingController(text: subItem.name);
    final priceController =
        TextEditingController(text: subItem.price.toString());
    final costController =
        TextEditingController(text: subItem.purchasePrice?.toString() ?? '');
    final qtyController =
        TextEditingController(text: subItem.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              const Text('Edit Item'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price *',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      decoration: InputDecoration(
                        labelText: 'Qty *',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                decoration: InputDecoration(
                  labelText: 'Cost (Optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.price_change),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    qtyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill required fields'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                final updatedSubItem = SubItem(
                  id: subItem.id,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  purchasePrice: double.tryParse(costController.text),
                  quantity: int.parse(qtyController.text),
                );

                parentSetState(() {
                  tempSubItems[index] = updatedSubItem;
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, CarPart carPart) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment, color: Colors.green),
              ),
              const SizedBox(width: 12),
              const Text('Make Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount Owed:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '\$${carPart.amountOwed.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: paymentAmountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final paymentAmount =
                    double.tryParse(paymentAmountController.text);
                if (paymentAmount == null || paymentAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter valid amount'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                if (paymentAmount > carPart.amountOwed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Payment cannot exceed \$${carPart.amountOwed.toStringAsFixed(2)}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final payment =
                    Payment(amount: paymentAmount, date: DateTime.now());
                final transaction = Transaction(
                  id: const Uuid().v4(),
                  sellerId: widget.seller.id,
                  sellerName: widget.seller.name,
                  carPartId: carPart.id,
                  carPartName: carPart.name,
                  amount: paymentAmount,
                  date: DateTime.now(),
                  description: 'Payment for ${carPart.name}',
                );

                await _transactionRepository.saveTransaction(transaction);

                final updatedCarPart = carPart.copyWith(
                  amountOwed: carPart.amountOwed - paymentAmount,
                  payments: [...carPart.payments, payment],
                );

                context
                    .read<SellerCubit>()
                    .updateCarPart(widget.seller.id, updatedCarPart);

                paymentAmountController.clear();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ Payment recorded: \$${paymentAmount.toStringAsFixed(2)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Record Payment'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCarPartDialog(BuildContext context, CarPart carPart) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text('Delete Sale'),
            ],
          ),
          content: const Text(
              'Are you sure you want to delete this sale? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context
                    .read<SellerCubit>()
                    .deleteCarPart(widget.seller.id, carPart.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sale deleted'),
                      backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Sort Sales'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('By Date'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByDate(widget.seller.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('By Price'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByPrice(widget.seller.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('By Amount Owed'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByAmountOwed(widget.seller.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportSellerToExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating Excel report...')),
      );

      final file = await _reportService.generateSellerExcelReport(
          widget.seller, selectedMonth, selectedYear);

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel saved: ${file.path}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(file.path),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportSellerToPDF() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF report...')),
      );

      final file = await _reportService.generateSellerPDFReport(
          widget.seller, selectedMonth, selectedYear);

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved: ${file.path}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(file.path),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _printInvoice(CarPart carPart) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating invoice...')),
      );

      final file = await _reportService.generateInvoiceForCarPart(
        carPart: carPart,
        sellerName: widget.seller.name,
        sellerId: widget.seller.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice saved: ${file.path}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(file.path),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
