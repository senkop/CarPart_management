import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PersonalSpendScreen extends StatelessWidget {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<PersonalSpendCubit>().loadPersonalSpends();

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Spends'),
      ),
      body: BlocBuilder<PersonalSpendCubit, PersonalSpendState>(
        builder: (context, state) {
          if (state is PersonalSpendLoaded) {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: state.personalSpends.length,
              itemBuilder: (context, index) {
                final personalSpend = state.personalSpends[index];
                final formattedDate = DateFormat('yyyy-MM-dd').format(personalSpend.date);
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: Icon(Icons.money, color: Colors.green),
                    title: Text(personalSpend.description),
                    subtitle: Text('Amount: \$${personalSpend.amount.toStringAsFixed(2)}\nDate: $formattedDate'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditSpendDialog(context, personalSpend);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            context.read<PersonalSpendCubit>().deletePersonalSpend(personalSpend.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is PersonalSpendEmpty) {
            return Center(child: Text('No personal spends found.'));
          } else if (state is PersonalSpendLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PersonalSpendError) {
            return Center(child: Text('Failed to load personal spends: ${state.message}'));
          }
          return Center(child: Text('Failed to load personal spends.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSpendDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddSpendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Spend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final spendId = Uuid().v4();
                final description = descriptionController.text;
                final amount = double.parse(amountController.text);

                final spend = PersonalSpend(
                  id: spendId,
                  description: description,
                  amount: amount,
                  date: DateTime.now(),
                );

                context.read<PersonalSpendCubit>().addPersonalSpend(spend);

                descriptionController.clear();
                amountController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSpendDialog(BuildContext context, PersonalSpend spend) {
    descriptionController.text = spend.description;
    amountController.text = spend.amount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Spend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final description = descriptionController.text;
                final amount = double.parse(amountController.text);

                final updatedSpend = PersonalSpend(
                  id: spend.id,
                  description: description,
                  amount: amount,
                  date: spend.date,
                );

                context.read<PersonalSpendCubit>().updatePersonalSpend(updatedSpend);

                descriptionController.clear();
                amountController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}