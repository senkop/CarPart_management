import 'package:easy_localization/easy_localization.dart';
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
import 'package:uuid/uuid.dart';
import 'package:elshaf3y_store/presentation/screens/seller_detail_screen.dart';class SellerScreen extends StatefulWidget {
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController carPartNameController = TextEditingController();
  final TextEditingController carPartPriceController = TextEditingController();
  final TextEditingController carPartDescriptionController = TextEditingController();
  final TextEditingController carPartQuantityController = TextEditingController();
  final String? selectedSellerId;
  final AuthService _authService = AuthService();
  final MonthlyGainsRepository _monthlyGainsRepository = MonthlyGainsRepository();

  SellerScreen({super.key, this.selectedSellerId});

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  bool isGridView = false;

  List<Map<String, dynamic>> calculateMonthlyGains(SellerState sellerState, BuildContext context) {
    if (sellerState is! SellerLoaded) return [];
    List<Map<String, dynamic>> monthlyGains = [];
    final currentYear = DateTime.now().year;
    for (int month = 1; month <= 12; month++) {
      final totalGain = sellerState.sellers.fold(0.0, (sum, seller) => sum + seller.getMonthlyGain());

      final totalDriverCost = context.read<DriverCubit>().state is DriverLoaded
          ? (context.read<DriverCubit>().state as DriverLoaded).drivers.fold(0.0, (sum, driver) {
              final monthlyCost = driver.trips
                  .where((trip) => trip.date.month == month && trip.date.year == currentYear)
                  .fold(0.0, (sum, trip) => sum + trip.cost);
              return sum + monthlyCost;
            })
          : 0.0;

      final totalPersonalPaid = context.read<PersonalSpendCubit>().state is PersonalSpendLoaded
          ? (context.read<PersonalSpendCubit>().state as PersonalSpendLoaded).personalSpends.fold(0.0, (sum, personalSpend) {
              final monthlyCost = personalSpend.date.month == month && personalSpend.date.year == currentYear ? personalSpend.amount : 0.0;
              return sum + monthlyCost;
            })
          : 0.0;

      final netGain = totalGain - totalDriverCost - totalPersonalPaid;
      monthlyGains.add({'month': month, 'year': currentYear, 'netGain': netGain});

      // Save monthly gains to Firebase
      final monthlyGainsData = MonthlyGains(month: month, year: currentYear, netGain: netGain);
      widget._monthlyGainsRepository.saveMonthlyGains(monthlyGainsData);
    }
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
          final monthlyGains = calculateMonthlyGains(sellerState, context);
          final currentMonth = DateTime.now().month;
          final currentMonthGain = monthlyGains.firstWhere((gain) => gain['month'] == currentMonth)['netGain'];
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${DateFormat.MMMM().format(DateTime(0, currentMonth))} ${DateTime.now().year}: \$${currentMonthGain.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
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
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
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
                                  foregroundColor: Colors.black, backgroundColor: Colors.white,

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
                                    foregroundColor: Colors.black, backgroundColor: Colors.white,

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
                  //   SnackBar(content: const Text('Sellers updated').tr()),
                  // );
                }
              },
              builder: (context, state) {
                if (state is SellerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SellerLoaded) {
                  return isGridView
                      ? Padding(
                        padding:  EdgeInsets.all(20.sp),
                        child: GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            builder: (context) => SellerDetailScreen(seller: seller),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'seller_${seller.id}',
                child: const Icon(Icons.person, size: 50, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              Text(
                seller.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text('Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}'),
              Text('Monthly Gain: \$${seller.getMonthlyGain().toStringAsFixed(2)}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      seller.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: seller.isPinned ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () {
                      context.read<SellerCubit>().togglePinSeller(seller);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      _showEditSellerDialog(context, seller);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteSellerDialog(context, seller.id);
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
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: Hero(
                                  tag: 'seller_${seller.id}',
                                  child: const Icon(Icons.person, color: Colors.blue),
                                ),
                                title: Text(seller.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}').tr(namedArgs: {'amount': seller.getTotalOwed().toStringAsFixed(2)}),
                                    Text('Monthly Gain: \$${seller.getMonthlyGain().toStringAsFixed(2)}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        seller.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                        color: seller.isPinned ? Colors.orange : Colors.grey,
                                      ),
                                      onPressed: () {
                                        context.read<SellerCubit>().togglePinSeller(seller);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () {
                                        _showEditSellerDialog(context, seller);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteSellerDialog(context, seller.id);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SellerDetailScreen(seller: seller),
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
                return Center(child: const Text('No sellers found').tr());
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
          title: const Text('Delete Seller').tr(),
          content: const Text('Are you sure you want to delete this seller?').tr(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                context.read<SellerCubit>().deleteSeller(sellerId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete').tr(),
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
          title: const Text('Add New Seller').tr(),
          content: TextField(
            controller: widget.sellerNameController,
            decoration: InputDecoration(labelText: 'Seller Name'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
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
                  phone: ''
                );

                context.read<SellerCubit>().addSeller(seller);

                widget.sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add').tr(),
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
          title: const Text('Edit Seller').tr(),
          content: TextField(
            controller: widget.sellerNameController,
            decoration: InputDecoration(labelText: 'Seller Name'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
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

                  phone: seller.phone
                );
                context.read<SellerCubit>().updateSeller(updatedSeller);

                widget.sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Save').tr(),
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
        title: const Text('Sort Options').tr(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('By Amount Owed').tr(),
              onTap: () {
                _sortByAmountOwed();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('By Gains').tr(),
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
            child: const Text('Cancel').tr(),
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
}}