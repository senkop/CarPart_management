// import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
// import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthlyGainsScreen extends StatelessWidget {
//   final MonthlyGainsRepository _monthlyGainsRepository =
//       MonthlyGainsRepository();

//   MonthlyGainsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('Monthly Gains'),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<MonthlyGains>>(
//         future: _monthlyGainsRepository.getAllMonthlyGains(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.info_outline, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No monthly gains found.',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final monthlyGains = snapshot.data!;
//           final currentMonth = DateTime.now().month;
//           final currentYear = DateTime.now().year;

//           // Filter and sort monthly gains (most recent first)
//           final filteredGains = monthlyGains
//               .where((gain) =>
//                   gain.year < currentYear ||
//                   (gain.year == currentYear && gain.month <= currentMonth))
//               .toList()
//             ..sort((a, b) {
//               if (a.year != b.year) return b.year.compareTo(a.year);
//               return b.month.compareTo(a.month);
//             });

//           // Calculate total gain across all months
//           final totalGain =
//               filteredGains.fold(0.0, (sum, gain) => sum + gain.netGain);

//           return Column(
//             children: [
//               // Summary Card
//               Container(
//                 margin: const EdgeInsets.all(16.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.green.shade400, Colors.green.shade600],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(15.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.green.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Total Accumulated Gain',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '\$${totalGain.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${filteredGains.length} months recorded',
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Monthly List
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   itemCount: filteredGains.length,
//                   itemBuilder: (context, index) {
//                     final gain = filteredGains[index];
//                     final isCurrentMonth =
//                         gain.month == currentMonth && gain.year == currentYear;
//                     final monthName =
//                         DateFormat.MMMM().format(DateTime(0, gain.month));

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12.0),
//                       decoration: BoxDecoration(
//                         color: isCurrentMonth
//                             ? Colors.green.shade50
//                             : Colors.white,
//                         border: Border.all(
//                           color: isCurrentMonth
//                               ? Colors.green
//                               : Colors.grey.shade300,
//                           width: isCurrentMonth ? 2 : 1,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 5,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                           vertical: 8.0,
//                         ),
//                         leading: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: gain.netGain >= 0
//                                 ? Colors.green.shade100
//                                 : Colors.red.shade100,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             gain.netGain >= 0
//                                 ? Icons.trending_up
//                                 : Icons.trending_down,
//                             color: gain.netGain >= 0
//                                 ? Colors.green.shade700
//                                 : Colors.red.shade700,
//                             size: 28,
//                           ),
//                         ),
//                         title: Row(
//                           children: [
//                             Text(
//                               '$monthName ${gain.year}',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                                 color: isCurrentMonth
//                                     ? Colors.green.shade700
//                                     : Colors.black87,
//                               ),
//                             ),
//                             if (isCurrentMonth) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   'Current',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         subtitle: Text(
//                           gain.netGain >= 0 ? 'Profit' : 'Loss',
//                           style: TextStyle(
//                             color: gain.netGain >= 0
//                                 ? Colors.green.shade600
//                                 : Colors.red.shade600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         trailing: Text(
//                           '\$${gain.netGain.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                             color: gain.netGain >= 0
//                                 ? Colors.green.shade700
//                                 : Colors.red.shade700,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyGainsScreen extends StatefulWidget {
  final MonthlyGainsRepository _monthlyGainsRepository =
      MonthlyGainsRepository();

  MonthlyGainsScreen({super.key});

  @override
  State<MonthlyGainsScreen> createState() => _MonthlyGainsScreenState();
}

class _MonthlyGainsScreenState extends State<MonthlyGainsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Monthly Gains'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'clear') {
                await _clearAllData(context);
              } else if (value == 'recalculate') {
                await _recalculateRealData(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recalculate',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Recalculate Real Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<MonthlyGains>>(
        future: widget._monthlyGainsRepository.getAllMonthlyGains(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No monthly gains found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final monthlyGains = snapshot.data!;
          final currentMonth = DateTime.now().month;
          final currentYear = DateTime.now().year;

          // FILTER OUT FUTURE MONTHS - ONLY show past and current month
          final validGains = monthlyGains.where((gain) {
            if (gain.year < currentYear) return true; // Past years
            if (gain.year > currentYear) return false; // Future years - EXCLUDE
            // Same year - only show if month is current or past
            return gain.month <= currentMonth;
          }).toList()
            ..sort((a, b) {
              if (a.year != b.year) return b.year.compareTo(a.year);
              return b.month.compareTo(a.month);
            });

          // Calculate total gain
          final totalGain =
              validGains.fold(0.0, (sum, gain) => sum + gain.netGain);

          print(
              '📊 Showing ${validGains.length} months (filtered out future months)');

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Accumulated Gain',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalGain.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${validGains.length} months recorded',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Monthly List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: validGains.length,
                  itemBuilder: (context, index) {
                    final gain = validGains[index];
                    final isCurrentMonth =
                        gain.month == currentMonth && gain.year == currentYear;
                    final monthName =
                        DateFormat.MMMM().format(DateTime(0, gain.month));

                    // All non-current months are past months (we already filtered future)
                    final isPastMonth = !isCurrentMonth;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: isCurrentMonth
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: isCurrentMonth
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: isCurrentMonth ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gain.netGain >= 0
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPastMonth
                                ? Icons.lock
                                : (gain.netGain >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down),
                            color: isPastMonth
                                ? Colors.grey.shade600
                                : (gain.netGain >= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700),
                            size: 28,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              '$monthName ${gain.year}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isCurrentMonth
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (isPastMonth) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '-',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          isPastMonth
                              ? 'Final - Cannot be changed'
                              : (gain.netGain >= 0 ? 'Profit' : 'Loss'),
                          style: TextStyle(
                            color: isPastMonth
                                ? Colors.grey.shade600
                                : (gain.netGain >= 0
                                    ? Colors.green.shade600
                                    : Colors.red.shade600),
                            fontSize: 14,
                          ),
                        ),
                        trailing: Text(
                          '\$${gain.netGain.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isPastMonth
                                ? Colors.grey.shade700
                                : (gain.netGain >= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Clear All Data?'),
        content: const Text(
            'This will delete ALL monthly records from both collections.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget._monthlyGainsRepository.clearAllMonthlyGains();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ All data cleared!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  Future<void> _recalculateRealData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔄 Recalculate Real Data?'),
        content: const Text(
          'This will scan ALL sellers, transactions, payments, driver costs, and personal expenses.\n\n'
          'Then recalculate monthly gains based on REAL data.\n\n'
          'This will replace any existing data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Recalculate',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏳ Scanning all data...')),
        );

        await _performRecalculation(context);

        setState(() {});

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Recalculation complete!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _performRecalculation(BuildContext context) async {
    final sellerState = context.read<SellerCubit>().state;
    final driverState = context.read<DriverCubit>().state;
    final personalState = context.read<PersonalSpendCubit>().state;

    if (sellerState is! SellerLoaded) {
      throw Exception('Sellers not loaded');
    }

    print('🔄 Starting Clean Recalculation...\n');

    // Step 1: Find date range from car parts dateAdded
    DateTime? earliestDate;
    final now = DateTime.now();

    for (var seller in sellerState.sellers) {
      for (var carPart in seller.carParts) {
        if (earliestDate == null || carPart.dateAdded.isBefore(earliestDate)) {
          earliestDate = carPart.dateAdded;
        }
      }
    }

    if (earliestDate == null) {
      print('⚠️ No car parts found');
      return;
    }

    print(
        '📅 Calculating from ${earliestDate.month}/${earliestDate.year} to ${now.month}/${now.year}\n');

    // Step 2: Loop through each month
    for (int year = earliestDate.year; year <= now.year; year++) {
      final startMonth = (year == earliestDate.year) ? earliestDate.month : 1;
      final endMonth = (year == now.year) ? now.month : 12;

      for (int month = startMonth; month <= endMonth; month++) {
        print('=' * 50);
        print('📅 Month: $month/$year');
        print('=' * 50);

        // ✅ A. Calculate gain from car parts ADDED in this month
        double totalActualGain = 0.0;

        for (var seller in sellerState.sellers) {
          // ✅ Filter car parts by dateAdded
          final carPartsForMonth = seller.carParts.where((carPart) {
            return carPart.dateAdded.month == month &&
                carPart.dateAdded.year == year;
          }).toList();

          double sellerGain = 0.0;

          for (var carPart in carPartsForMonth) {
            final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

            double totalPayments = carPart.payments
                .fold(0.0, (sum, payment) => sum + payment.amount);

            // ✅ SIMPLE: Gain = Payments - Cost
            final actualGain = totalPayments - totalPurchasePrice;
            sellerGain += actualGain;

            print('   📦 ${carPart.name}: \$${actualGain.toStringAsFixed(2)}');
          }

          if (sellerGain != 0) {
            print(
                '💰 ${seller.name} Total: \$${sellerGain.toStringAsFixed(2)}');
            totalActualGain += sellerGain;
          }
        }

        print('✅ Total Actual Gain: \$${totalActualGain.toStringAsFixed(2)}\n');

        // B. Calculate driver costs
        double totalDriverCosts = 0.0;
        if (driverState is DriverLoaded) {
          for (var driver in driverState.drivers) {
            final trips = driver.trips.where(
              (trip) => trip.date.month == month && trip.date.year == year,
            );

            final driverCost = trips.fold(0.0, (sum, trip) => sum + trip.cost);

            if (driverCost > 0) {
              print(
                  '🚗 Driver ${driver.name}: \$${driverCost.toStringAsFixed(2)}');
              totalDriverCosts += driverCost;
            }
          }
        }
        print(
            '🚚 Total Driver Costs: \$${totalDriverCosts.toStringAsFixed(2)}\n');

        // C. Calculate personal expenses
        double totalPersonalExpenses = 0.0;
        if (personalState is PersonalSpendLoaded) {
          final expenses = personalState.personalSpends.where(
            (expense) =>
                expense.date.month == month && expense.date.year == year,
          );

          totalPersonalExpenses =
              expenses.fold(0.0, (sum, e) => sum + e.amount);

          if (totalPersonalExpenses > 0) {
            print(
                '💳 Personal Expenses: \$${totalPersonalExpenses.toStringAsFixed(2)}\n');
          }
        }

        // D. Calculate net profit
        final netProfit =
            totalActualGain - totalDriverCosts - totalPersonalExpenses;

        print('═' * 50);
        print('📊 SUMMARY:');
        print('   Actual Gain:       +\$${totalActualGain.toStringAsFixed(2)}');
        print(
            '   Driver Costs:      -\$${totalDriverCosts.toStringAsFixed(2)}');
        print(
            '   Personal Expenses: -\$${totalPersonalExpenses.toStringAsFixed(2)}');
        print('   ─────────────────────────────────────');
        print('   NET PROFIT:        =\$${netProfit.toStringAsFixed(2)}');
        print('═' * 50);
        print('\n');

        // E. Save to Firebase
        if (totalActualGain != 0 ||
            totalDriverCosts > 0 ||
            totalPersonalExpenses > 0) {
          await widget._monthlyGainsRepository.recalculatePastMonth(
            year,
            month,
            netProfit,
          );
          print('✅ Saved to Firebase\n');
        }
      }
    }

    print('🎉 Recalculation Complete!\n');
  }
}
