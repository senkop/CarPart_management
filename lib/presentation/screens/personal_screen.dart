import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Theme
          appBar: AppBar(
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor, // ✅ Theme
            elevation: Theme.of(context).appBarTheme.elevation,
            title: Text(
              'Personal Spends',
              style: Theme.of(context).textTheme.titleLarge, // ✅ Theme
            ),
          ),
          body: Column(
            children: [
              // ✅ Action Buttons with Theme
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAddSpendDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary, // ✅ Theme
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary, // ✅ Theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Add Spend'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showSortOptionsDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary, // ✅ Theme
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onSecondary, // ✅ Theme
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
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary, // ✅ Theme
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onSecondary, // ✅ Theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(isGridView ? 'List View' : 'Grid View'),
                    ),
                  ],
                ),
              ),
              // ✅ Personal Spend List/Grid with Theme
              Expanded(
                child: BlocBuilder<PersonalSpendCubit, PersonalSpendState>(
                  builder: (context, state) {
                    if (state is PersonalSpendLoaded) {
                      if (state.personalSpends.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money_off_outlined,
                                size: 64,
                                color:
                                    isDark ? Colors.grey.shade600 : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No personal spends found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return isGridView
                          ? Padding(
                              padding: EdgeInsets.all(20.sp),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2 / 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: state.personalSpends.length,
                                itemBuilder: (context, index) {
                                  final personalSpend =
                                      state.personalSpends[index];
                                  final formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(personalSpend.date);
                                  return Card(
                                    color:
                                        Theme.of(context).cardColor, // ✅ Theme
                                    elevation:
                                        Theme.of(context).cardTheme.elevation ??
                                            2,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.money,
                                            size: 50,
                                            color: isDark
                                                ? Colors.green.shade300
                                                : Colors.green,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            personalSpend.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Amount: \$${personalSpend.amount.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          Text(
                                            'Date: $formattedDate',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.orange),
                                                onPressed: () =>
                                                    _showEditSpendDialog(
                                                        context, personalSpend),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  context
                                                      .read<
                                                          PersonalSpendCubit>()
                                                      .deletePersonalSpend(
                                                          personalSpend.id);
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
                              padding: const EdgeInsets.all(16.0),
                              itemCount: state.personalSpends.length,
                              itemBuilder: (context, index) {
                                final personalSpend =
                                    state.personalSpends[index];
                                final formattedDate = DateFormat('yyyy-MM-dd')
                                    .format(personalSpend.date);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).cardColor, // ✅ Theme
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
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
                                    contentPadding: const EdgeInsets.all(16.0),
                                    leading: Icon(
                                      Icons.money,
                                      color: isDark
                                          ? Colors.green.shade300
                                          : Colors.green,
                                      size: 32,
                                    ),
                                    title: Text(
                                      personalSpend.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Text(
                                      'Amount: \$${personalSpend.amount.toStringAsFixed(2)}\nDate: $formattedDate',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.orange),
                                          onPressed: () => _showEditSpendDialog(
                                              context, personalSpend),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            context
                                                .read<PersonalSpendCubit>()
                                                .deletePersonalSpend(
                                                    personalSpend.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                    } else if (state is PersonalSpendEmpty) {
                      return Center(
                        child: Text(
                          'No personal spends found.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    } else if (state is PersonalSpendLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    } else if (state is PersonalSpendError) {
                      return Center(
                        child: Text(
                          'Failed to load personal spends: ${state.message}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        'Failed to load personal spends.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Dialogs with Theme
  void _showAddSpendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          title: Text('Add New Spend',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.descriptionController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: widget.amountController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          title:
              Text('Edit Spend', style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.descriptionController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: widget.amountController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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

                context
                    .read<PersonalSpendCubit>()
                    .updatePersonalSpend(updatedSpend);

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
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          title: Text('Sort Options',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('By Amount',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  _sortByAmount();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('By Date',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  _sortByDate();
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
