import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PersonalSpendScreen extends StatefulWidget {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  PersonalSpendScreen({super.key});

  @override
  _PersonalSpendScreenState createState() => _PersonalSpendScreenState();
}

class _PersonalSpendScreenState extends State<PersonalSpendScreen> {
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    context.read<PersonalSpendCubit>().loadPersonalSpends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Personal Spends'),
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
                    _showAddSpendDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Spend'),
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
            child: BlocBuilder<PersonalSpendCubit, PersonalSpendState>(
              builder: (context, state) {
                if (state is PersonalSpendLoaded) {
                  return isGridView
                      ? Padding(
                          padding: EdgeInsets.all(20.sp),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: state.personalSpends.length,
                            itemBuilder: (context, index) {
                              final personalSpend = state.personalSpends[index];
                              final formattedDate = DateFormat('yyyy-MM-dd').format(personalSpend.date);
                              return Card(
                                    elevation: 0,
                                          color: Colors.white,

                                   shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.money, size: 50, color: Colors.green),
                                      const SizedBox(height: 10),
                                      Text(
                                        personalSpend.description,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 5),
                                      Text('Amount: \$${personalSpend.amount.toStringAsFixed(2)}'),
                                      Text('Date: $formattedDate'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.orange),
                                            onPressed: () {
                                              _showEditSpendDialog(context, personalSpend);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              context.read<PersonalSpendCubit>().deletePersonalSpend(personalSpend.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: state.personalSpends.length,
                          itemBuilder: (context, index) {
                            final personalSpend = state.personalSpends[index];
                            final formattedDate = DateFormat('yyyy-MM-dd').format(personalSpend.date);
                            return Card(
                                 elevation: 0,
                                          color: Colors.white,

                                   shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
                              
                              
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListTile(
                                  contentPadding: const EdgeInsets.all(8.0),
                                  leading: const Icon(Icons.money, color: Colors.green),
                                  title: Text(personalSpend.description),
                                  subtitle: Text('Amount: \$${personalSpend.amount.toStringAsFixed(2)}\nDate: $formattedDate'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditSpendDialog(context, personalSpend);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          context.read<PersonalSpendCubit>().deletePersonalSpend(personalSpend.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ),
                            );
                          },
                        );
                } else if (state is PersonalSpendEmpty) {
                  return const Center(child: Text('No personal spends found.'));
                } else if (state is PersonalSpendLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PersonalSpendError) {
                  return Center(child: Text('Failed to load personal spends: ${state.message}'));
                }
                return const Center(child: Text('Failed to load personal spends.'));
              },
            ),
          ),
        ],
      ),
   
    );
  }

  void _showAddSpendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Spend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: widget.amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
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
            TextButton(
              onPressed: () {
                final spendId = const Uuid().v4();
                final description = widget.descriptionController.text;
                final amount = double.parse(widget.amountController.text);

                final spend = PersonalSpend(
                  id: spendId,
                  description: description,
                  amount: amount,
                  date: DateTime.now(),
                );

                context.read<PersonalSpendCubit>().addPersonalSpend(spend);

                widget.descriptionController.clear();
                widget.amountController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSpendDialog(BuildContext context, PersonalSpend spend) {
    widget.descriptionController.text = spend.description;
    widget.amountController.text = spend.amount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Spend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: widget.amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
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
            TextButton(
              onPressed: () {
                final description = widget.descriptionController.text;
                final amount = double.parse(widget.amountController.text);

                final updatedSpend = PersonalSpend(
                  id: spend.id,
                  description: description,
                  amount: amount,
                  date: spend.date,
                );

                context.read<PersonalSpendCubit>().updatePersonalSpend(updatedSpend);

                widget.descriptionController.clear();
                widget.amountController.clear();

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
          title: const Text('Sort Options').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('By Amount').tr(),
                onTap: () {
                  _sortByAmount();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('By Date').tr(),
                onTap: () {
                  _sortByDate();
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

  void _sortByAmount() {
    setState(() {
      context.read<PersonalSpendCubit>().sortPersonalSpendsByAmount();
    });
  }

  void _sortByDate() {
    setState(() {
      context.read<PersonalSpendCubit>().sortPersonalSpendsByDate();
    });
  }
}