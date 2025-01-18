import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:elshaf3y_store/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/language_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';

import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:uuid/uuid.dart';
import 'package:elshaf3y_store/presentation/screens/seller_detail_screen.dart';
class SellerScreen extends StatelessWidget {
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController carPartNameController = TextEditingController();
  final TextEditingController carPartPriceController = TextEditingController();
  final TextEditingController carPartDescriptionController = TextEditingController();
  final TextEditingController carPartQuantityController = TextEditingController();
  String? selectedSellerId;
  final AuthService _authService = AuthService();

  
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
    }
    return monthlyGains;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<SellerCubit, SellerState>(
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
                      builder: (context) => MonthlyGainsScreen(monthlyGains: monthlyGains),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Monthly Gain:'),
                    Text('${DateFormat.MMMM().format(DateTime(0, currentMonth))} ${DateTime.now().year}: \$${currentMonthGain.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }
            return Text('Sellers');
          },
        ),
      
         actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Call the logout method from AuthService
              await _authService.logout();

              // Navigate back to the AuthScreen after logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SellerCubit, SellerState>(
        listener: (context, state) {
          if (state is SellerLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sellers updated').tr()),
            );
          }
        },
        builder: (context, state) {
          if (state is SellerLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SellerLoaded) {
            return ListView.builder(
              itemCount: state.sellers.length,
              itemBuilder: (context, index) {
                final seller = state.sellers[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Text(seller.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Owed: \$${seller.getTotalOwed().toStringAsFixed(2)}').tr(namedArgs: {'amount': seller.getTotalOwed().toStringAsFixed(2)}),
                        Text('Monthly Gain: \$${seller.getMonthlyGain().toStringAsFixed(2)}'), // Use getMonthlyGain method
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
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _showEditSellerDialog(context, seller);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
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
          return Center(child: Text('No sellers found').tr());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSellerDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteSellerDialog(BuildContext context, String sellerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Seller').tr(),
          content: Text('Are you sure you want to delete this seller?').tr(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                context.read<SellerCubit>().deleteSeller(sellerId);
                Navigator.of(context).pop();
              },
              child: Text('Delete').tr(),
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
          title: Text('Add New Seller').tr(),
          content: TextField(
            controller: sellerNameController,
            decoration: InputDecoration(labelText: 'Seller Name'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                final sellerId = Uuid().v4();
                final sellerName = sellerNameController.text;

                final seller = Seller(
                  id: sellerId,
                  name: sellerName,
                  carParts: [],
                  monthlyGain: 0.0,
                  phone: ''
                );

                context.read<SellerCubit>().addSeller(seller);

                sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Add').tr(),
            ),
          ],
        );
      },
    );
  }

  void _showEditSellerDialog(BuildContext context, Seller seller) {
    sellerNameController.text = seller.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Seller').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sellerNameController,
                decoration: InputDecoration(labelText: 'Seller Name'.tr()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                final sellerName = sellerNameController.text;

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

                sellerNameController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Save').tr(),
            ),
          ],
        );
      },
    );
  }
}


class MonthlyGainsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyGains;

  const MonthlyGainsScreen({super.key, required this.monthlyGains});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Gains'),
      ),
      body: ListView.builder(
        itemCount: monthlyGains.where((gain) => gain['month'] <= currentMonth).length,
        itemBuilder: (context, index) {
          final gain = monthlyGains.where((gain) => gain['month'] <= currentMonth).toList()[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.green),
              title: Text('${DateFormat.MMMM().format(DateTime(0, gain['month']))} ${gain['year']}: \$${gain['netGain'].toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}