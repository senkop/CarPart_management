import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/screens/trips_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class DriverScreen extends StatefulWidget {
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();

  DriverScreen({super.key});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool isGridView = false;
  @override
  void initState() {
    super.initState();
    context.read<DriverCubit>().loadDrivers();
  }
  @override
  Widget build(BuildContext context) {
    // context.read<DriverCubit>().loadDrivers();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: const Text('Drivers'),
        ),
       
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
                    _showAddDriverDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Driver'),
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
            child: BlocBuilder<DriverCubit, DriverState>(
              builder: (context, state) {
                if (state is DriverLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DriverLoaded) {
                  return isGridView
                      ? Padding(
                        padding:  EdgeInsets.all(20.sp),
                        child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.6/ 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                            itemCount: state.drivers.length,
                            itemBuilder: (context, index) {
                              final driver = state.drivers[state.drivers.length - 1 - index]; // Reverse the order of items
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TripScreen(driver: driver),
                                    ),
                                  );
                                },
                                child: Card(
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
                                        const Icon(Icons.person, size: 50, color: Colors.blue),
                                        const SizedBox(height: 10),
                                        Text(
                                          driver.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        Text('Phone: ${driver.phoneNumber}'),
                                        Text('Total Trips: ${driver.getTotalTrips()}'),
                                        Text('Total Cost: \$${driver.getTotalCost().toStringAsFixed(2)}'),
                                        Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                _showEditDriverDialog(context, driver);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                                      context.read<DriverCubit>().deleteDriver(driver.id);

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
                      :ListView.builder(
  reverse: false,
  itemCount: state.drivers.length,
  itemBuilder: (context, index) {
    final driver = state.drivers[state.drivers.length - 1 - index]; // Reverse the order of items
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.blue),
        title: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${driver.phoneNumber}'),
            Text('Total Trips: ${driver.getTotalTrips()}'),
            Text('Total Cost: \$${driver.getTotalCost().toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDriverDialog(context, driver);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<DriverCubit>().deleteDriver(driver.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripScreen(driver: driver),
            ),
          );
        },
      ),
    );
  },
);
                } else if (state is DriverEmpty) {
                  return const Center(child: Text('No drivers found.'));
                } else if (state is DriverError) {
                  return Center(child: Text('Failed to load drivers: ${state.message}'));
                }
                return const Center(child: Text('Failed to load drivers.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.driverNameController,
                decoration: const InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: widget.driverPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
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
                final driverId = const Uuid().v4();
                final driverName = widget.driverNameController.text;
                final driverPhone = widget.driverPhoneController.text;

                final driver = Driver(
                  id: driverId,
                  name: driverName,
                  phoneNumber: driverPhone,
                  trips: [],
                );

                context.read<DriverCubit>().addDriver(driver);

                widget.driverNameController.clear();
                widget.driverPhoneController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDriverDialog(BuildContext context, Driver driver) {
    widget.driverNameController.text = driver.name;
    widget.driverPhoneController.text = driver.phoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.driverNameController,
                decoration: const InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: widget.driverPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
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
                final driverName = widget.driverNameController.text;
                final driverPhone = widget.driverPhoneController.text;

                final updatedDriver = Driver(
                  id: driver.id,
                  name: driverName,
                  phoneNumber: driverPhone,
                  trips: driver.trips,
                );

                context.read<DriverCubit>().updateDriver(updatedDriver);

                widget.driverNameController.clear();
                widget.driverPhoneController.clear();

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
              title: const Text('By Total Trips').tr(),
              onTap: () {
                _sortByTotalTrips();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('By Total Costs').tr(),
              onTap: () {
                _sortByTotalCost();
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

  void _sortByTotalTrips() {
    setState(() {
      context.read<DriverCubit>().sortDriversByTotalTrips();
    });
  }

  void _sortByTotalCost() {
    setState(() {
      context.read<DriverCubit>().sortDriversByTotalCost();
    });
  }
}