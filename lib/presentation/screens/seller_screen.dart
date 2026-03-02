import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:elshaf3y_store/presentation/screens/login_screen.dart';
import 'package:elshaf3y_store/presentation/screens/monthly_gain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/language_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';

import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:elshaf3y_store/presentation/screens/seller_detail_screen.dart';
import 'package:elshaf3y_store/features/reports/services/report_service.dart';
import 'package:open_filex/open_filex.dart'; // ✅ Changed from open_file

class SellerScreen extends StatefulWidget {
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController carPartNameController = TextEditingController();
  final TextEditingController carPartPriceController = TextEditingController();
  final TextEditingController carPartDescriptionController =
      TextEditingController();
  final TextEditingController carPartQuantityController =
      TextEditingController();
  final String? selectedSellerId;
  final AuthService _authService = AuthService();
  final MonthlyGainsRepository _monthlyGainsRepository =
      MonthlyGainsRepository();

  SellerScreen({super.key, this.selectedSellerId});

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  bool isGridView = false;

  // Add these variables for month/year selection
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final ReportService _reportService = ReportService();

  List<Map<String, dynamic>> calculateMonthlyGains(
      SellerState sellerState, BuildContext context) {
    if (sellerState is! SellerLoaded) return [];

    // ONLY calculate and save the CURRENT month
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    List<Map<String, dynamic>> monthlyGains = [];

    // Calculate ACTUAL gain from payments received in CURRENT month ONLY
    final totalGainFromPayments = sellerState.sellers.fold(0.0, (sum, seller) {
      return sum +
          seller.getActualMonthlyGain(month: currentMonth, year: currentYear);
    });

    final totalDriverCost = context.read<DriverCubit>().state is DriverLoaded
        ? (context.read<DriverCubit>().state as DriverLoaded).drivers.fold(0.0,
            (sum, driver) {
            final monthlyCost = driver.trips
                .where((trip) =>
                    trip.date.month == currentMonth &&
                    trip.date.year == currentYear)
                .fold(0.0, (sum, trip) => sum + trip.cost);
            return sum + monthlyCost;
          })
        : 0.0;

    final totalPersonalPaid =
        context.read<PersonalSpendCubit>().state is PersonalSpendLoaded
            ? (context.read<PersonalSpendCubit>().state as PersonalSpendLoaded)
                .personalSpends
                .fold(0.0, (sum, personalSpend) {
                final monthlyCost = personalSpend.date.month == currentMonth &&
                        personalSpend.date.year == currentYear
                    ? personalSpend.amount
                    : 0.0;
                return sum + monthlyCost;
              })
            : 0.0;

    final netGain = totalGainFromPayments - totalDriverCost - totalPersonalPaid;

    // ONLY save the CURRENT month
    // Past months are already locked in Firebase
    final monthlyGainsData =
        MonthlyGains(month: currentMonth, year: currentYear, netGain: netGain);

    // This will UPDATE current month or CREATE if it doesn't exist
    // The repository will SKIP updating past months
    widget._monthlyGainsRepository.saveMonthlyGains(monthlyGainsData);

    print(
        '💰 Current month gain: $currentMonth/$currentYear = \$${netGain.toStringAsFixed(2)}');

    monthlyGains
        .add({'month': currentMonth, 'year': currentYear, 'netGain': netGain});

    return monthlyGains;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: BlocBuilder<SellerCubit, SellerState>(
            builder: (context, sellerState) {
              if (sellerState is SellerLoaded) {
                final monthlyGains =
                    calculateMonthlyGains(sellerState, context);
                final currentMonth = DateTime.now().month;
                final currentMonthGain = monthlyGains.firstWhere(
                    (gain) => gain['month'] == currentMonth)['netGain'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyGainsScreen(),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Net Monthly Gain:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${DateFormat.MMMM().format(DateTime(0, currentMonth))} ${DateTime.now().year}: \$${currentMonthGain.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return const Text('Sellers');
            },
          ),
        ),
        actions: [
          BlocBuilder<SellerCubit, SellerState>(
            builder: (context, state) {
              if (state is SellerLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.table_chart),
                      tooltip: 'Export All to Excel',
                      onPressed: () => _exportAllSellersToExcel(state.sellers),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'Export All to PDF',
                      onPressed: () => _exportAllSellersToPDF(state.sellers),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // ✅ ADD THIS: Calculate Monthly Gain Button
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Calculate Monthly Gain',
            onPressed: () {
              _showMonthlyGainCalculatorDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget._authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ ADD THIS: Month/Year Selector
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text('Filter by: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                // Month Dropdown
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child:
                            Text(DateFormat.MMMM().format(DateTime(0, month))),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Year Dropdown
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showAddSellerDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Seller'),
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Grid View'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<SellerCubit, SellerState>(
              listener: (context, state) {
                if (state is SellerLoaded) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: const Text('Sellers updated') ),
                  // );
                }
              },
              builder: (context, state) {
                if (state is SellerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SellerLoaded) {
                  return isGridView
                      ? Padding(
                          padding: EdgeInsets.all(20.sp),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: state.sellers.length,
                            itemBuilder: (context, index) {
                              final seller = state.sellers[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SellerDetailScreen(seller: seller),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Hero(
                                          tag: 'seller_${seller.id}',
                                          child: const Icon(Icons.person,
                                              size: 50, color: Colors.blue),
                                        ),
                                        const SizedBox(height: 30),
                                        Text(
                                          seller.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}'),
                                        Text(
                                            'Monthly Gain: \$${seller.getActualMonthlyGain(month: selectedMonth, year: selectedYear).toStringAsFixed(2)}'),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                seller.isPinned
                                                    ? Icons.push_pin
                                                    : Icons.push_pin_outlined,
                                                color: seller.isPinned
                                                    ? Colors.orange
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<SellerCubit>()
                                                    .togglePinSeller(seller);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.orange),
                                              onPressed: () {
                                                _showEditSellerDialog(
                                                    context, seller);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _showDeleteSellerDialog(
                                                    context, seller.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.sellers.length,
                          itemBuilder: (context, index) {
                            final seller = state.sellers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: Hero(
                                  tag: 'seller_${seller.id}',
                                  child: const Icon(Icons.person,
                                      color: Colors.blue),
                                ),
                                title: Text(seller.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}'),
                                    Text(
                                        'Monthly Gain: \$${seller.getActualMonthlyGain(month: selectedMonth, year: selectedYear).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        seller.isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                        color: seller.isPinned
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<SellerCubit>()
                                            .togglePinSeller(seller);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orange),
                                      onPressed: () {
                                        _showEditSellerDialog(context, seller);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _showDeleteSellerDialog(
                                            context, seller.id);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SellerDetailScreen(seller: seller),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                } else if (state is SellerError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Center(child: const Text('No sellers found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSellerDialog(BuildContext context, String sellerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Seller'),
          content: const Text('Are you sure you want to delete this seller?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SellerCubit>().deleteSeller(sellerId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSellerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Add New Seller'),
          content: TextField(
            controller: widget.sellerNameController,
            decoration: InputDecoration(labelText: 'Seller Name'),
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
                final sellerId = const Uuid().v4();
                final sellerName = widget.sellerNameController.text;

                final seller = Seller(
                    id: sellerId,
                    name: sellerName,
                    carParts: [],
                    monthlyGain: 0.0,
                    phone: '');

                context.read<SellerCubit>().addSeller(seller);

                widget.sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSellerDialog(BuildContext context, Seller seller) {
    widget.sellerNameController.text = seller.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Seller'),
          content: TextField(
            controller: widget.sellerNameController,
            decoration: InputDecoration(labelText: 'Seller Name'),
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
                final sellerName = widget.sellerNameController.text;

                final updatedSeller = Seller(
                    id: seller.id,
                    name: sellerName,
                    carParts: seller.carParts,
                    pin: seller.pin,
                    isPinned: seller.isPinned,
                    monthlyGain: seller.monthlyGain,
                    phone: seller.phone);
                context.read<SellerCubit>().updateSeller(updatedSeller);

                widget.sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('By Amount Owed'),
                onTap: () {
                  _sortByAmountOwed();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('By Gains'),
                onTap: () {
                  _sortByGains();
                  Navigator.of(context).pop();
                },
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
          ],
        );
      },
    );
  }

  void _sortByAmountOwed() {
    setState(() {
      context.read<SellerCubit>().sortSellersByAmountOwed();
    });
  }

  void _sortByGains() {
    setState(() {
      context.read<SellerCubit>().sortSellersByGains();
    });
  }

  // Add this new method to recalculate ALL months with real data
  Future<void> recalculateAllHistoricalMonths(BuildContext context) async {
    final sellerState = context.read<SellerCubit>().state;
    if (sellerState is! SellerLoaded) return;

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    print('🔄 Recalculating all historical months...');

    // Calculate for each month from January to current month
    for (int month = 1; month <= currentMonth; month++) {
      // Calculate ACTUAL gain from payments received in this specific month
      final totalGainFromPayments =
          sellerState.sellers.fold(0.0, (sum, seller) {
        return sum +
            seller.getActualMonthlyGain(month: month, year: currentYear);
      });

      final totalDriverCost = context.read<DriverCubit>().state is DriverLoaded
          ? (context.read<DriverCubit>().state as DriverLoaded)
              .drivers
              .fold(0.0, (sum, driver) {
              final monthlyCost = driver.trips
                  .where((trip) =>
                      trip.date.month == month && trip.date.year == currentYear)
                  .fold(0.0, (sum, trip) => sum + trip.cost);
              return sum + monthlyCost;
            })
          : 0.0;

      final totalPersonalPaid = context.read<PersonalSpendCubit>().state
              is PersonalSpendLoaded
          ? (context.read<PersonalSpendCubit>().state as PersonalSpendLoaded)
              .personalSpends
              .fold(0.0, (sum, personalSpend) {
              final monthlyCost = personalSpend.date.month == month &&
                      personalSpend.date.year == currentYear
                  ? personalSpend.amount
                  : 0.0;
              return sum + monthlyCost;
            })
          : 0.0;

      final netGain =
          totalGainFromPayments - totalDriverCost - totalPersonalPaid;

      // Force save this month (even if it's past)
      final monthlyGainsData = MonthlyGains(
        month: month,
        year: currentYear,
        netGain: netGain,
      );

      await widget._monthlyGainsRepository
          .recalculatePastMonth(currentYear, month, netGain);

      print(
          '✅ Recalculated $month/$currentYear: \$${netGain.toStringAsFixed(2)}');
    }

    print('🎉 All historical months recalculated!');
  }

  // ✅ REPLACE THIS METHOD
  void _showMonthlyGainCalculatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            // Changed 'context' to 'statefulContext'
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Calculate Monthly Gain'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Month Dropdown
                  DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child:
                            Text(DateFormat.MMMM().format(DateTime(0, month))),
                      );
                    }),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Year Dropdown
                  DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Use dialogContext
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Calculate and save the selected month
                    await _calculateAndSaveSpecificMonth(context, selectedMonth,
                        selectedYear); // Use parent context
                    Navigator.of(dialogContext).pop(); // Use dialogContext

                    // Show success message
                    if (mounted) {
                      // Add mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '✅ Calculated gain for ${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Calculate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ ADD THIS NEW METHOD
  Future<void> _calculateAndSaveSpecificMonth(
      BuildContext context, int month, int year) async {
    final sellerState = context.read<SellerCubit>().state;
    if (sellerState is! SellerLoaded) return;

    print('🔄 Calculating gain for $month/$year...');

    // Calculate ACTUAL gain from payments received in this specific month
    final totalGainFromPayments = sellerState.sellers.fold(0.0, (sum, seller) {
      return sum + seller.getActualMonthlyGain(month: month, year: year);
    });

    final totalDriverCost = context.read<DriverCubit>().state is DriverLoaded
        ? (context.read<DriverCubit>().state as DriverLoaded).drivers.fold(0.0,
            (sum, driver) {
            final monthlyCost = driver.trips
                .where((trip) =>
                    trip.date.month == month && trip.date.year == year)
                .fold(0.0, (sum, trip) => sum + trip.cost);
            return sum + monthlyCost;
          })
        : 0.0;

    final totalPersonalPaid =
        context.read<PersonalSpendCubit>().state is PersonalSpendLoaded
            ? (context.read<PersonalSpendCubit>().state as PersonalSpendLoaded)
                .personalSpends
                .fold(0.0, (sum, personalSpend) {
                final monthlyCost = personalSpend.date.month == month &&
                        personalSpend.date.year == year
                    ? personalSpend.amount
                    : 0.0;
                return sum + monthlyCost;
              })
            : 0.0;

    final netGain = totalGainFromPayments - totalDriverCost - totalPersonalPaid;

    print(
        '💰 Total Gain from Payments: \$${totalGainFromPayments.toStringAsFixed(2)}');
    print('🚗 Total Driver Costs: \$${totalDriverCost.toStringAsFixed(2)}');
    print(
        '💳 Total Personal Expenses: \$${totalPersonalPaid.toStringAsFixed(2)}');
    print('✅ Net Gain: \$${netGain.toStringAsFixed(2)}');

    // Save to Firebase
    await widget._monthlyGainsRepository
        .recalculatePastMonth(year, month, netGain);

    print('✅ Saved $month/$year to Firebase\n');
  }

  Future<void> _exportAllSellersToExcel(List<Seller> sellers) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Generating Excel report for all sellers...')),
      );

      final file = await _reportService.generateAllSellersExcelReport(
        sellers,
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

  Future<void> _exportAllSellersToPDF(List<Seller> sellers) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Generating PDF report for all sellers...')),
      );

      final file = await _reportService.generateAllSellersPDFReport(
        sellers,
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
