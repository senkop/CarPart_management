import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
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
            title: Text(
              'Monthly Gains',
              style: Theme.of(context).textTheme.titleLarge, // ✅ Theme
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).iconTheme.color), // ✅ Theme
                color: Theme.of(context).cardColor, // ✅ Theme
                onSelected: (value) async {
                  if (value == 'clear') {
                    await _clearAllData(context);
                  } else if (value == 'recalculate') {
                    await _recalculateRealData(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Clear All Data',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium), // ✅ Theme
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'recalculate',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Recalculate Real Data',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium), // ✅ Theme
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
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary, // ✅ Theme
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error), // ✅ Theme
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey, // ✅ Theme
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No monthly gains found.',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey, // ✅ Theme
                        ),
                      ),
                    ],
                  ),
                );
              }

              final monthlyGains = snapshot.data!;
              final currentMonth = DateTime.now().month;
              final currentYear = DateTime.now().year;

              // Filter valid gains
              final validGains = monthlyGains.where((gain) {
                if (gain.year < currentYear) return true;
                if (gain.year > currentYear) return false;
                return gain.month <= currentMonth;
              }).toList()
                ..sort((a, b) {
                  if (a.year != b.year) return b.year.compareTo(a.year);
                  return b.month.compareTo(a.month);
                });

              final totalGain =
                  validGains.fold(0.0, (sum, gain) => sum + gain.netGain);

              return Column(
                children: [
                  // ✅ Summary Card with Theme
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.green.shade700, Colors.green.shade900]
                            : [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(isDark ? 0.2 : 0.3),
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

                  // ✅ Monthly List with Theme
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: validGains.length,
                      itemBuilder: (context, index) {
                        final gain = validGains[index];
                        final isCurrentMonth = gain.month == currentMonth &&
                            gain.year == currentYear;
                        final monthName =
                            DateFormat.MMMM().format(DateTime(0, gain.month));
                        final isPastMonth = !isCurrentMonth;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? (isDark
                                    ? Colors.green.shade900.withOpacity(0.3)
                                    : Colors.green.shade50)
                                : (isDark
                                    ? Theme.of(context).cardColor
                                    : Colors.grey.shade50),
                            border: Border.all(
                              color: isCurrentMonth
                                  ? (isDark
                                      ? Colors.green.shade700
                                      : Colors.green)
                                  : (isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                              width: isCurrentMonth ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
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
                                color: isPastMonth
                                    ? (isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200)
                                    : (gain.netGain >= 0
                                        ? (isDark
                                            ? Colors.green.shade800
                                            : Colors.green.shade100)
                                        : (isDark
                                            ? Colors.red.shade800
                                            : Colors.red.shade100)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPastMonth
                                    ? Icons.lock
                                    : (gain.netGain >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down),
                                color: isPastMonth
                                    ? (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600)
                                    : (gain.netGain >= 0
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : (isDark
                                            ? Colors.red.shade300
                                            : Colors.red.shade700)),
                                size: 28,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  '$monthName ${gain.year}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isCurrentMonth
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : (isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700),
                                  ),
                                ),
                                if (isCurrentMonth) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.green.shade700
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Current',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isPastMonth) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '-',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
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
                                    ? (isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600)
                                    : (gain.netGain >= 0
                                        ? (isDark
                                            ? Colors.green.shade400
                                            : Colors.green.shade600)
                                        : (isDark
                                            ? Colors.red.shade400
                                            : Colors.red.shade600)),
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              '\$${gain.netGain.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isPastMonth
                                    ? (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700)
                                    : (gain.netGain >= 0
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : (isDark
                                            ? Colors.red.shade300
                                            : Colors.red.shade700)),
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
      },
    );
  }

  // ✅ Dialogs with Theme
  Future<void> _clearAllData(BuildContext context) async {
    final isDark = context.read<ThemeCubit>().isDarkMode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
        title: Text('⚠️ Clear All Data?',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'This will delete ALL monthly records from both collections.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blue)),
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data cleared!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _recalculateRealData(BuildContext context) async {
    final isDark = context.read<ThemeCubit>().isDarkMode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
        title: Text('🔄 Recalculate Real Data?',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'This will scan ALL sellers, transactions, payments, driver costs, and personal expenses.\n\n'
          'Then recalculate monthly gains based on REAL data.\n\n'
          'This will replace any existing data.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blue)),
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏳ Scanning all data...')),
        );

        await _performRecalculation(context);

        setState(() {});

        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Recalculation complete!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
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

    for (int year = earliestDate.year; year <= now.year; year++) {
      final startMonth = (year == earliestDate.year) ? earliestDate.month : 1;
      final endMonth = (year == now.year) ? now.month : 12;

      for (int month = startMonth; month <= endMonth; month++) {
        print('=' * 50);
        print('📅 Month: $month/$year');
        print('=' * 50);

        double totalActualGain = 0.0;

        for (var seller in sellerState.sellers) {
          final sellerGain = seller.getMonthlyGainForMonth(month, year);

          if (sellerGain != 0) {
            print('💰 ${seller.name}: \$${sellerGain.toStringAsFixed(2)}');

            final carPartsForMonth = seller.getCarPartsForMonth(month, year);
            for (var carPart in carPartsForMonth) {
              final gain = carPart.getActualGain();
              final totalCost = carPart.getTotalPurchasePrice();
              final totalPaid = carPart.getTotalPayments();
              print('   📦 ${carPart.name}:');
              print('      Cost: \$${totalCost.toStringAsFixed(2)}');
              print('      Paid: \$${totalPaid.toStringAsFixed(2)}');
              print('      Gain: \$${gain.toStringAsFixed(2)}');
            }

            totalActualGain += sellerGain;
          }
        }

        print(
            '\n✅ Total Seller Gain: \$${totalActualGain.toStringAsFixed(2)}\n');

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

        if (totalDriverCosts > 0) {
          print(
              '🚚 Total Driver Costs: \$${totalDriverCosts.toStringAsFixed(2)}\n');
        }

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

        final netProfit =
            totalActualGain - totalDriverCosts - totalPersonalExpenses;

        print('═' * 50);
        print('📊 MONTHLY SUMMARY:');
        print('   Seller Gain:       +\$${totalActualGain.toStringAsFixed(2)}');
        print(
            '   Driver Costs:      -\$${totalDriverCosts.toStringAsFixed(2)}');
        print(
            '   Personal Expenses: -\$${totalPersonalExpenses.toStringAsFixed(2)}');
        print('   ─────────────────────────────────────');
        print(
            '   NET PROFIT:        ${netProfit >= 0 ? "+" : ""}\$${netProfit.toStringAsFixed(2)}');
        print('═' * 50);
        print('\n');

        if (totalActualGain != 0 ||
            totalDriverCosts > 0 ||
            totalPersonalExpenses > 0) {
          await widget._monthlyGainsRepository.recalculatePastMonth(
            year,
            month,
            netProfit,
          );
          print('💾 Saved to Firebase\n');
        } else {
          print('⏭️  Skipped (no data for this month)\n');
        }
      }
    }

    print('🎉 Recalculation Complete!\n');
    print('📊 Summary:');
    print('   From: ${DateFormat.yMMM().format(earliestDate!)}');
    print('   To:   ${DateFormat.yMMM().format(now)}');
    print(
        '   Total months processed: ${(now.year - earliestDate.year) * 12 + (now.month - earliestDate.month) + 1}');
  }
}
