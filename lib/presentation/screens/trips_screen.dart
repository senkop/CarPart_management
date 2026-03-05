import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/presentation/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TripScreen extends StatefulWidget {
  final Driver driver;

  TripScreen({super.key, required this.driver});

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TextEditingController tripFromController = TextEditingController();
  final TextEditingController tripToController = TextEditingController();
  final TextEditingController tripCostController = TextEditingController();
  bool isGridView = false;

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
              'Trips for ${widget.driver.name}',
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
                      onPressed: () => _showAddTripDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary, // ✅ Theme
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary, // ✅ Theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Add Trip'),
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
              // ✅ Trip List/Grid with Theme
              Expanded(
                child: BlocBuilder<DriverCubit, DriverState>(
                  builder: (context, state) {
                    if (state is DriverLoaded) {
                      final updatedDriver = state.drivers
                          .firstWhere((d) => d.id == widget.driver.id);

                      if (updatedDriver.trips.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 64,
                                color:
                                    isDark ? Colors.grey.shade600 : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No trips found',
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
                          ? GridView.builder(
                              padding: const EdgeInsets.all(16.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: updatedDriver.trips.length,
                              itemBuilder: (context, index) {
                                final trip = updatedDriver.trips[index];
                                final formattedDate =
                                    DateFormat('yyyy-MM-dd').format(trip.date);
                                return Card(
                                  color: Theme.of(context).cardColor, // ✅ Theme
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
                                          Icons.directions_car,
                                          size: 50,
                                          color: isDark
                                              ? Colors.blue.shade300
                                              : Colors.blue, // ✅ Theme
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${trip.from} → ${trip.to}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Cost: \$${trip.cost.toStringAsFixed(2)}',
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
                                                  _showEditTripDialog(
                                                      context, trip),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                context
                                                    .read<DriverCubit>()
                                                    .deleteTrip(
                                                        widget.driver.id,
                                                        trip.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: updatedDriver.trips.length,
                              itemBuilder: (context, index) {
                                final trip = updatedDriver.trips[index];
                                final formattedDate =
                                    DateFormat('yyyy-MM-dd').format(trip.date);
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
                                      Icons.directions_car,
                                      color: isDark
                                          ? Colors.blue.shade300
                                          : Colors.blue,
                                      size: 32,
                                    ),
                                    title: Text(
                                      '${trip.from} → ${trip.to}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Text(
                                      'Cost: \$${trip.cost.toStringAsFixed(2)}\nDate: $formattedDate',
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
                                          onPressed: () => _showEditTripDialog(
                                              context, trip),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            context
                                                .read<DriverCubit>()
                                                .deleteTrip(
                                                    widget.driver.id, trip.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
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
  void _showAddTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          title: Text('Add New Trip',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: tripToController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: tripCostController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Cost',
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
                final tripId = const Uuid().v4();
                final tripFrom = tripFromController.text;
                final tripTo = tripToController.text;
                final tripCost = double.parse(tripCostController.text);

                final trip = Trip(
                  id: tripId,
                  from: tripFrom,
                  to: tripTo,
                  cost: tripCost,
                  date: DateTime.now(),
                );

                context.read<DriverCubit>().addTrip(widget.driver.id, trip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTripDialog(BuildContext context, Trip trip) {
    tripFromController.text = trip.from;
    tripToController.text = trip.to;
    tripCostController.text = trip.cost.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Theme
          title:
              Text('Edit Trip', style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: tripToController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: tripCostController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Cost',
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
                final tripFrom = tripFromController.text;
                final tripTo = tripToController.text;
                final tripCost = double.parse(tripCostController.text);

                final updatedTrip = Trip(
                  id: trip.id,
                  from: tripFrom,
                  to: tripTo,
                  cost: tripCost,
                  date: trip.date,
                );

                context
                    .read<DriverCubit>()
                    .updateTrip(widget.driver.id, updatedTrip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

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
                title: Text('By Cost',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  _sortByCost();
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

  void _sortByCost() {
    setState(() {
      context.read<DriverCubit>().sortTripsByCost(widget.driver.id);
    });
  }

  void _sortByDate() {
    setState(() {
      context.read<DriverCubit>().sortTripsByDate(widget.driver.id);
    });
  }
}
