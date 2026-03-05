import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
import 'package:intl/intl.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final CarPart carPart;

  const PaymentDetailsScreen({super.key, required this.carPart});

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
              'Payment Details',
              style: Theme.of(context).textTheme.titleLarge, // ✅ Theme
            ),
          ),
          body: carPart.payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 64,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey, // ✅ Theme
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No payments have been made yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700, // ✅ Theme
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: carPart.payments.length,
                  itemBuilder: (context, index) {
                    final payment = carPart.payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // ✅ Theme
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300, // ✅ Theme
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1), // ✅ Theme
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.green.shade800
                                : Colors.green.shade100, // ✅ Theme
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.payment,
                            color: isDark
                                ? Colors.green.shade300
                                : Colors.green, // ✅ Theme
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Amount: \$${payment.amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // ✅ Theme
                        ),
                        subtitle: Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(payment.date)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ), // ✅ Theme
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
