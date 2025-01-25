

import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:flutter/material.dart';

class MonthlyGainsScreen extends StatelessWidget {
  final MonthlyGainsRepository _monthlyGainsRepository = MonthlyGainsRepository();

  MonthlyGainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Monthly Gains'),
      ),
      body: FutureBuilder<List<MonthlyGains>>(
        future: _monthlyGainsRepository.getAllMonthlyGains(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No monthly gains found.'));
          }

          final monthlyGains = snapshot.data!;
          final currentMonth = DateTime.now().month;

          return ListView.builder(
            itemCount: monthlyGains.where((gain) => gain.month <= currentMonth).length,
            itemBuilder: (context, index) {
              final gain = monthlyGains.where((gain) => gain.month <= currentMonth).toList()[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.monetization_on, color: Colors.green),
                  title: Text('${DateFormat.MMMM().format(DateTime(0, gain.month))} ${gain.year}: \$${gain.netGain.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}