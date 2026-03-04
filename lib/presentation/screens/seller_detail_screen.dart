import 'package:elshaf3y_store/presentation/screens/payment_screen.dart';
import 'package:flutter/material.dart';
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
import 'package:open_filex/open_filex.dart'; // ✅ Changed from open_file

class SellerDetailScreen extends StatefulWidget {
  final Seller seller;

  SellerDetailScreen({super.key, required this.seller});

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
  bool isGridView = false;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final TransactionRepository _transactionRepository = TransactionRepository();
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: BlocBuilder<SellerCubit, SellerState>(
          builder: (context, state) {
            if (state is SellerLoaded) {
              final updatedSeller =
                  state.sellers.firstWhere((s) => s.id == widget.seller.id);

              // ✅ FILTER car parts by SELECTED MONTH first!
              final carPartsForSelectedMonth =
                  updatedSeller.carParts.where((carPart) {
                return carPart.dateAdded.month == selectedMonth &&
                    carPart.dateAdded.year == selectedYear;
              }).toList();

              // ✅ Calculate actual gain for SELECTED MONTH ONLY
              double monthlyActualGain = 0.0;

              // ✅ LOOP ONLY THROUGH FILTERED CAR PARTS
              for (var carPart in carPartsForSelectedMonth) {
                final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

                // Count ALL payments for this car part (not just this month)
                double totalPayments = carPart.payments
                    .fold(0.0, (sum, payment) => sum + payment.amount);

                // ✅ SIMPLE: Gain = Total Payments - Purchase Cost
                final actualGain = totalPayments - totalPurchasePrice;
                monthlyActualGain += actualGain;
              }

              return Column(
                children: [
                  Hero(
                    tag: 'seller_${widget.seller.id}',
                    child: Text(widget.seller.name),
                  ),
                  Text(
                    '${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear Gain: \$${monthlyActualGain.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: monthlyActualGain >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Export to Excel',
            onPressed: () => _exportSellerToExcel(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export to PDF',
            onPressed: () => _exportSellerToPDF(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _clearCarPartControllers(); // Clear the controllers before showing the dialog
                    _showAddCarPartDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Sale'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSortOptionsDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Sort'),
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(
                                DateFormat.MMMM().format(DateTime(0, month))),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  items:
                      List.generate(5, (index) => DateTime.now().year - index)
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<SellerCubit, SellerState>(
            builder: (context, state) {
              if (state is SellerLoaded) {
                final updatedSeller =
                    state.sellers.firstWhere((s) => s.id == widget.seller.id);
                final carPartsForSelectedMonth =
                    updatedSeller.carParts.where((carPart) {
                  return carPart.dateAdded.month == selectedMonth &&
                      carPart.dateAdded.year == selectedYear;
                }).toList();
                return Expanded(
                  child: ListView.builder(
                    key: ValueKey(
                        carPartsForSelectedMonth), // Add a key to force rebuild
                    itemCount: carPartsForSelectedMonth.length,
                    itemBuilder: (context, index) {
                      final carPart = carPartsForSelectedMonth[
                          carPartsForSelectedMonth.length - index - 1];

                      // Calculate TOTAL price for all units
                      final totalSellingPrice =
                          carPart.price * carPart.quantity;
                      final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

                      // Calculate how much has been paid so far (ALL payments)
                      double totalPaid = carPart.payments
                          .fold(0.0, (sum, payment) => sum + payment.amount);

                      // ✅ SIMPLE: Actual Gain = Total Paid - Purchase Cost
                      final actualGain = totalPaid - totalPurchasePrice;

                      // Calculate POTENTIAL gain (if fully paid)
                      final potentialGain =
                          totalSellingPrice - totalPurchasePrice;

                      // Calculate payment percentage (for display)
                      final paymentPercentage = totalSellingPrice > 0
                          ? totalPaid / totalSellingPrice
                          : 0.0;

                      print('🔍 Car Part: ${carPart.name}');
                      print(
                          '   Total Selling Price: \$${totalSellingPrice.toStringAsFixed(2)}');
                      print(
                          '   Total Purchase Price: \$${totalPurchasePrice.toStringAsFixed(2)}');
                      print('   Total Paid: \$${totalPaid.toStringAsFixed(2)}');
                      print(
                          '   ✅ Actual Gain: \$${actualGain.toStringAsFixed(2)}');
                      print(
                          '   💰 Potential Gain: \$${potentialGain.toStringAsFixed(2)}');

                      return GestureDetector(
                        onTap: () {
                          _showEditCarPartDialog(context, carPart);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.build, color: Colors.blue),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      carPart.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      const Text('Total Price:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(
                                          '\$${totalSellingPrice.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Purchase Price:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(
                                          '\$${totalPurchasePrice.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Unit Price:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(
                                          '\$${carPart.price.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Quantity:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text('${carPart.quantity}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Date:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(DateFormat('yyyy-MM-dd')
                                          .format(carPart.dateAdded)),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Total Paid:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                              color: Colors.blue)),
                                      Text('\$${totalPaid.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.blue)),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Amount Owed:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(
                                          '\$${carPart.amountOwed.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Potential Gain:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      Text(
                                          '\$${potentialGain.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Actual Gain:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                              color: Colors.green)),
                                      Text('\$${actualGain.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text('Payment %:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                              color: Colors.grey)),
                                      Text(
                                          '${(paymentPercentage * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Description: ${carPart.description}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.payment,
                                        color: Colors.green),
                                    onPressed: () {
                                      _showPaymentDialog(context, carPart);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.list,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PaymentDetailsScreen(
                                                  carPart: carPart),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _showDeleteCarPartDialog(
                                          context, carPart);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
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

  void _showAddCarPartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Car Part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carPartNameController,
                decoration: InputDecoration(labelText: 'Car Part Name'),
              ),
              TextField(
                controller: carPartPriceController,
                decoration: InputDecoration(labelText: 'Car Part Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: carPartPurchasePriceController,
                decoration:
                    InputDecoration(labelText: 'Car Part Purchase Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: carPartDescriptionController,
                decoration: InputDecoration(labelText: 'Car Part Description'),
              ),
              TextField(
                controller: carPartQuantityController,
                decoration: InputDecoration(labelText: 'Car Part Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final carPartName = carPartNameController.text;
                final carPartPrice = double.parse(carPartPriceController.text);
                final carPartPurchasePrice =
                    double.parse(carPartPurchasePriceController.text);
                final carPartDescription = carPartDescriptionController.text;
                final carPartQuantity =
                    int.parse(carPartQuantityController.text);

                final carPart = CarPart(
                  id: const Uuid().v4(),
                  name: carPartName,
                  price: carPartPrice,
                  purchasePrice: carPartPurchasePrice,
                  description: carPartDescription,
                  quantity: carPartQuantity,
                  dateAdded: DateTime.now(),
                  amountOwed: carPartPrice * carPartQuantity,
                );

                context
                    .read<SellerCubit>()
                    .addCarPartToSeller(widget.seller.id, carPart);

                _clearCarPartControllers(); // Clear the controllers after adding the car part

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCarPartDialog(BuildContext context, CarPart carPart) {
    carPartNameController.text = carPart.name;
    carPartPriceController.text = carPart.price.toString();
    carPartPurchasePriceController.text = carPart.purchasePrice.toString();
    carPartDescriptionController.text = carPart.description;
    carPartQuantityController.text = carPart.quantity.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Car Part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carPartNameController,
                decoration: InputDecoration(labelText: 'Car Part Name'),
              ),
              TextField(
                controller: carPartPriceController,
                decoration: InputDecoration(labelText: 'Car Part Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carPartPurchasePriceController,
                decoration:
                    InputDecoration(labelText: 'Car Part Purchase Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carPartDescriptionController,
                decoration: InputDecoration(labelText: 'Car Part Description'),
              ),
              TextField(
                controller: carPartQuantityController,
                decoration: InputDecoration(labelText: 'Car Part Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final carPartName = carPartNameController.text;
                final carPartPrice = double.parse(carPartPriceController.text);
                final carPartPurchasePrice =
                    double.parse(carPartPurchasePriceController.text);
                final carPartDescription = carPartDescriptionController.text;
                final carPartQuantity =
                    int.parse(carPartQuantityController.text);

                final updatedCarPart = CarPart(
                  id: carPart.id,
                  name: carPartName,
                  price: carPartPrice,
                  purchasePrice: carPartPurchasePrice,
                  description: carPartDescription,
                  quantity: carPartQuantity,
                  dateAdded: carPart.dateAdded,
                  amountOwed:
                      carPart.amountOwed, // Keep the current amount owed
                  payments: carPart.payments, // Preserve existing payments
                );

                context
                    .read<SellerCubit>()
                    .updateCarPart(widget.seller.id, updatedCarPart);

                _clearCarPartControllers();

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
          title: const Text('Make Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amount Owed: \$${carPart.amountOwed.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16.0),
              ),
              SizedBox(height: 8),
              TextField(
                controller: paymentAmountController,
                decoration: InputDecoration(labelText: 'Payment Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final paymentAmount =
                    double.parse(paymentAmountController.text);

                if (paymentAmount > carPart.amountOwed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Payment cannot exceed amount owed (\$${carPart.amountOwed.toStringAsFixed(2)})'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final remainingAmount = carPart.amountOwed - paymentAmount;
                final paymentDate = DateTime.now();
                final payment =
                    Payment(amount: paymentAmount, date: paymentDate);

                // ✅ CREATE TRANSACTION RECORD
                final transaction = Transaction(
                  id: const Uuid().v4(),
                  sellerId: widget.seller.id,
                  sellerName: widget.seller.name,
                  carPartId: carPart.id,
                  carPartName: carPart.name,
                  amount: paymentAmount,
                  date: paymentDate,
                  description: 'Payment for ${carPart.name}',
                );

                // ✅ SAVE TRANSACTION TO FIREBASE
                await _transactionRepository.saveTransaction(transaction);

                // Update car part
                final updatedCarPart = CarPart(
                  id: carPart.id,
                  name: carPart.name,
                  price: carPart.price,
                  purchasePrice: carPart.purchasePrice,
                  description: carPart.description,
                  quantity: carPart.quantity,
                  dateAdded: carPart.dateAdded,
                  amountOwed: remainingAmount,
                  payments: [...carPart.payments, payment],
                );

                context
                    .read<SellerCubit>()
                    .updateCarPart(widget.seller.id, updatedCarPart);

                paymentAmountController.clear();
                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ Payment recorded: \$${paymentAmount.toStringAsFixed(2)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Pay'),
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
          backgroundColor: Colors.white,
          title: const Text('Delete Car Part'),
          content: const Text('Are you sure you want to delete this car part?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Use the outer context (not dialog context) for ScaffoldMessenger
                if (!context.mounted) return;

                try {
                  print(
                      'Deleting car part: ${carPart.id} from seller: ${widget.seller.id}');

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleting...')),
                  );

                  // Delete the car part
                  await context
                      .read<SellerCubit>()
                      .deleteCarPart(widget.seller.id, carPart.id);

                  if (!context.mounted) return;

                  // Show success message
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Car part deleted successfully')),
                  );
                } catch (e) {
                  print('Error deleting car part: $e');

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting car part: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
          backgroundColor: Colors.white,
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Date'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByDate(widget.seller.id);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Sort by Price'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByPrice(widget.seller.id);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Sort by Amount Owed'),
                onTap: () {
                  context
                      .read<SellerCubit>()
                      .sortCarPartsByAmountOwed(widget.seller.id);
                  Navigator.of(context).pop();
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
        widget.seller,
        selectedMonth,
        selectedYear,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel saved: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () =>
                OpenFilex.open(file.path), // ✅ Changed to OpenFilex
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportSellerToPDF() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF report...')),
      );

      final file = await _reportService.generateSellerPDFReport(
        widget.seller,
        selectedMonth,
        selectedYear,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () =>
                OpenFilex.open(file.path), // ✅ Changed to OpenFilex
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
