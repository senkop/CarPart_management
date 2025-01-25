import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final CarPart carPart;

  const PaymentDetailsScreen({super.key, required this.carPart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      appBar: AppBar(
              backgroundColor: Colors.white ,

        title: const Text('Payment Details').tr(),
      ),
      body: carPart.payments.isEmpty
          ? Center(child: const Text('No payments have been made yet').tr())
          : ListView.builder(
              itemCount: carPart.payments.length,
              itemBuilder: (context, index) {
                final payment = carPart.payments[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: Colors.green),
                    title: Text('Amount: \$${payment.amount.toStringAsFixed(2)}').tr(namedArgs: {'amount': payment.amount.toStringAsFixed(2)}),
                    subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(payment.date)}').tr(namedArgs: {'date': DateFormat('yyyy-MM-dd').format(payment.date)}),
                  ),
                );
              },
            ),
    );
  }
}