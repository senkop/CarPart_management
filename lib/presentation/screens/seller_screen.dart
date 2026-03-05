import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
import 'package:elshaf3y_store/presentation/screens/login_screen.dart';
import 'package:elshaf3y_store/presentation/screens/monthly_gain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:elshaf3y_store/presentation/screens/seller_detail_screen.dart';
import 'package:elshaf3y_store/features/reports/services/report_service.dart';
import 'package:open_filex/open_filex.dart';

class SellerScreen extends StatefulWidget {
  final TextEditingController sellerNameController = TextEditingController();
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
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final ReportService _reportService = ReportService();

  void _updateFilter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Listen to state changes for auto-save
    context.select<DriverCubit, DriverState>((cubit) {
      final state = cubit.state;
      if (state is DriverLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoSaveCurrentMonthGain(context);
        });
      }
      return state;
    });

    context.select<PersonalSpendCubit, PersonalSpendState>((cubit) {
      final state = cubit.state;
      if (state is PersonalSpendLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoSaveCurrentMonthGain(context);
        });
      }
      return state;
    });

    // ✅ Calculate net gain
    double netGain = 0.0;
    final sellerState = context.watch<SellerCubit>().state;

    if (sellerState is SellerLoaded) {
      double totalGainFromPayments = 0.0;
      for (var seller in sellerState.sellers) {
        totalGainFromPayments +=
            seller.getMonthlyGainForMonth(selectedMonth, selectedYear);
      }

      final driverState = context.watch<DriverCubit>().state;
      final totalDriverCost = driverState is DriverLoaded
          ? driverState.drivers.fold(0.0, (sum, driver) {
              final monthlyCost = driver.trips
                  .where((trip) =>
                      trip.date.month == selectedMonth &&
                      trip.date.year == selectedYear)
                  .fold(0.0, (sum, trip) => sum + trip.cost);
              return sum + monthlyCost;
            })
          : 0.0;

      final personalState = context.watch<PersonalSpendCubit>().state;
      final totalPersonalPaid = personalState is PersonalSpendLoaded
          ? personalState.personalSpends.fold(0.0, (sum, personalSpend) {
              final monthlyCost = personalSpend.date.month == selectedMonth &&
                      personalSpend.date.year == selectedYear
                  ? personalSpend.amount
                  : 0.0;
              return sum + monthlyCost;
            })
          : 0.0;

      netGain = totalGainFromPayments - totalDriverCost - totalPersonalPaid;
    }

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // ✅ Theme color
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor, // ✅ Theme color
        elevation: Theme.of(context).appBarTheme.elevation,
        key: ValueKey('${selectedMonth}_$selectedYear'),
        title: Center(
          child: Builder(
            builder: (builderContext) {
              return BlocBuilder<SellerCubit, SellerState>(
                builder: (context, sellerState) {
                  if (sellerState is SellerLoaded) {
                    double totalGainFromPayments = 0.0;
                    for (var seller in sellerState.sellers) {
                      totalGainFromPayments += seller.getMonthlyGainForMonth(
                          selectedMonth, selectedYear);
                    }

                    final totalDriverCost = context.read<DriverCubit>().state
                            is DriverLoaded
                        ? (context.read<DriverCubit>().state as DriverLoaded)
                            .drivers
                            .fold(0.0, (sum, driver) {
                            final monthlyCost = driver.trips
                                .where((trip) =>
                                    trip.date.month == selectedMonth &&
                                    trip.date.year == selectedYear)
                                .fold(0.0, (sum, trip) => sum + trip.cost);
                            return sum + monthlyCost;
                          })
                        : 0.0;

                    final totalPersonalPaid = context
                            .read<PersonalSpendCubit>()
                            .state is PersonalSpendLoaded
                        ? (context.read<PersonalSpendCubit>().state
                                as PersonalSpendLoaded)
                            .personalSpends
                            .fold(0.0, (sum, personalSpend) {
                            final monthlyCost =
                                personalSpend.date.month == selectedMonth &&
                                        personalSpend.date.year == selectedYear
                                    ? personalSpend.amount
                                    : 0.0;
                            return sum + monthlyCost;
                          })
                        : 0.0;

                    final netGain = totalGainFromPayments -
                        totalDriverCost -
                        totalPersonalPaid;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MonthlyGainsScreen()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Net Monthly Gain:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ), // ✅ Theme text
                          ),
                          Text(
                            '${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear: \$${netGain.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: netGain >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Text('Sellers',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge); // ✅ Theme text
                },
              );
            },
          ),
        ),
        actions: [
          // ✅ Theme Toggle Button
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          BlocBuilder<SellerCubit, SellerState>(
            builder: (context, state) {
              if (state is SellerLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.table_chart, color: Colors.green),
                      tooltip: 'Export All to Excel',
                      onPressed: () => _exportAllSellersToExcel(state.sellers),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      tooltip: 'Export All to PDF',
                      onPressed: () => _exportAllSellersToPDF(state.sellers),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout,
                color: Theme.of(context).iconTheme.color), // ✅ Theme icon
            onPressed: () async {
              await widget._authService.logout();
              if (!mounted) return;
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
          // ✅ Month/Year Filter with Theme
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Theme.of(context).cardColor, // ✅ Theme color
            child: Row(
              children: [
                Text(
                  'Filter by: ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ), // ✅ Theme text
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor, // ✅ Theme color
                    style:
                        Theme.of(context).textTheme.bodyMedium, // ✅ Theme text
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
                      _updateFilter();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor, // ✅ Theme color
                    style:
                        Theme.of(context).textTheme.bodyMedium, // ✅ Theme text
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
                      _updateFilter();
                    },
                  ),
                ),
              ],
            ),
          ),
          // ✅ Action Buttons with Theme
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddSellerDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary, // ✅ Theme color
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onPrimary, // ✅ Theme color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Add Seller'),
                ),
                ElevatedButton(
                  onPressed: () => _showSortOptionsDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary, // ✅ Theme color
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onSecondary, // ✅ Theme color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
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
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary, // ✅ Theme color
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onSecondary, // ✅ Theme color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Text(isGridView ? 'List View' : 'Grid View'),
                ),
              ],
            ),
          ),
          // ✅ Seller List/Grid
          Expanded(
            child: BlocConsumer<SellerCubit, SellerState>(
              listener: (context, state) {
                if (state is SellerLoaded) {
                  _autoSaveCurrentMonthGain(context);
                }
              },
              builder: (context, state) {
                if (state is SellerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SellerLoaded) {
                  return isGridView
                      ? _buildGridView(state.sellers)
                      : _buildListView(state.sellers);
                } else if (state is SellerError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error), // ✅ Theme color
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'No sellers found',
                    style:
                        Theme.of(context).textTheme.bodyLarge, // ✅ Theme text
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Grid View with Theme
  Widget _buildGridView(List<Seller> sellers) {
    return Padding(
      padding: EdgeInsets.all(20.sp),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: sellers.length,
        itemBuilder: (context, index) {
          final seller = sellers[index];
          final monthlyGain =
              seller.getMonthlyGainForMonth(selectedMonth, selectedYear);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SellerDetailScreen(seller: seller)),
              );
            },
            child: Card(
              color: Theme.of(context).cardColor, // ✅ Theme color
              elevation: Theme.of(context).cardTheme.elevation ?? 2,
              shape: Theme.of(context).cardTheme.shape,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'seller_${seller.id}',
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // ✅ Theme color
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      seller.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ), // ✅ Theme text
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.bodySmall, // ✅ Theme text
                    ),
                    Text(
                      'Monthly Gain: \$${monthlyGain.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: monthlyGain >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            seller.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: seller.isPinned
                                ? Colors.orange
                                : Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            context.read<SellerCubit>().togglePinSeller(seller);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showEditSellerDialog(context, seller),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteSellerDialog(context, seller.id),
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
    );
  }

  // ✅ List View with Theme
  Widget _buildListView(List<Seller> sellers) {
    return ListView.builder(
      itemCount: sellers.length,
      itemBuilder: (context, index) {
        final seller = sellers[index];
        final monthlyGain =
            seller.getMonthlyGainForMonth(selectedMonth, selectedYear);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // ✅ Theme color
            border: Border.all(
                color: Theme.of(context).dividerColor), // ✅ Theme color
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: Hero(
              tag: 'seller_${seller.id}',
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary, // ✅ Theme color
              ),
            ),
            title: Text(
              seller.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), // ✅ Theme text
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall, // ✅ Theme text
                ),
                Text(
                  'Monthly Gain: \$${monthlyGain.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: monthlyGain >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    seller.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: seller.isPinned
                        ? Colors.orange
                        : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    context.read<SellerCubit>().togglePinSeller(seller);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _showEditSellerDialog(context, seller),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteSellerDialog(context, seller.id),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SellerDetailScreen(seller: seller)),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ Dialogs with Theme
  void _showAddSellerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).dialogBackgroundColor, // ✅ Theme color
          title: Text('Add New Seller',
              style: Theme.of(context).textTheme.titleLarge),
          content: TextField(
            controller: widget.sellerNameController,
            style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme text
            decoration: InputDecoration(
              labelText: 'Seller Name',
              labelStyle:
                  Theme.of(context).textTheme.bodyMedium, // ✅ Theme text
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                  phone: '',
                );

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
          backgroundColor:
              Theme.of(context).dialogBackgroundColor, // ✅ Theme color
          title: Text('Edit Seller',
              style: Theme.of(context).textTheme.titleLarge),
          content: TextField(
            controller: widget.sellerNameController,
            style: Theme.of(context).textTheme.bodyMedium, // ✅ Theme text
            decoration: InputDecoration(
              labelText: 'Seller Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedSeller =
                    seller.copyWith(name: widget.sellerNameController.text);
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

  void _showDeleteSellerDialog(BuildContext context, String sellerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).dialogBackgroundColor, // ✅ Theme color
          title: Text('Delete Seller',
              style: Theme.of(context).textTheme.titleLarge),
          content: Text(
            'Are you sure you want to delete this seller?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SellerCubit>().deleteSeller(sellerId);
                Navigator.of(context).pop();
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
          backgroundColor:
              Theme.of(context).dialogBackgroundColor, // ✅ Theme color
          title: Text('Sort Options',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('By Amount Owed',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  context.read<SellerCubit>().sortSellersByAmountOwed();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('By Gains',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  context.read<SellerCubit>().sortSellersByGains();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
            onPressed: () => OpenFilex.open(file.path),
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
            onPressed: () => OpenFilex.open(file.path),
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

  void _autoSaveCurrentMonthGain(BuildContext context) {
    final sellerState = context.read<SellerCubit>().state;
    if (sellerState is! SellerLoaded) return;

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    double totalGainFromPayments = 0.0;
    for (var seller in sellerState.sellers) {
      totalGainFromPayments +=
          seller.getMonthlyGainForMonth(currentMonth, currentYear);
    }

    final driverState = context.read<DriverCubit>().state;
    final totalDriverCost = driverState is DriverLoaded
        ? driverState.drivers.fold(0.0, (sum, driver) {
            final monthlyCost = driver.trips
                .where((trip) =>
                    trip.date.month == currentMonth &&
                    trip.date.year == currentYear)
                .fold(0.0, (sum, trip) => sum + trip.cost);
            return sum + monthlyCost;
          })
        : 0.0;

    final personalState = context.read<PersonalSpendCubit>().state;
    final totalPersonalPaid = personalState is PersonalSpendLoaded
        ? personalState.personalSpends.fold(0.0, (sum, personalSpend) {
            final monthlyCost = personalSpend.date.month == currentMonth &&
                    personalSpend.date.year == currentYear
                ? personalSpend.amount
                : 0.0;
            return sum + monthlyCost;
          })
        : 0.0;

    final netGain = totalGainFromPayments - totalDriverCost - totalPersonalPaid;

    final monthlyGainsData = MonthlyGains(
      month: currentMonth,
      year: currentYear,
      netGain: netGain,
    );

    widget._monthlyGainsRepository.saveMonthlyGains(monthlyGainsData);

    print('💾 Auto-saved current month: \$${netGain.toStringAsFixed(2)}');
  }
}
