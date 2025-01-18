import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/screens/trips_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:uuid/uuid.dart';

class DriverScreen extends StatelessWidget {
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<DriverCubit>().loadDrivers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Drivers'),
      ),
      body: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          if (state is DriverLoaded) {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: state.drivers.length,
              itemBuilder: (context, index) {
                final driver = state.drivers[index];
                return Card(
                  elevation: 0, // Remove elevation
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Text(driver.name),
                    subtitle: Text('Phone: ${driver.phoneNumber}\nTotal Trips: ${driver.getTotalTrips()}\nTotal Cost: \$${driver.getTotalCost().toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDriverDialog(context, driver);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
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
            return Center(child: Text('No drivers found.'));
          } else if (state is DriverLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is DriverError) {
            return Center(child: Text('Failed to load drivers: ${state.message}'));
          }
          return Center(child: Text('Failed to load drivers.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDriverDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: driverNameController,
                decoration: InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: driverPhoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
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
                final driverId = Uuid().v4();
                final driverName = driverNameController.text;
                final driverPhone = driverPhoneController.text;

                final driver = Driver(
                  id: driverId,
                  name: driverName,
                  phoneNumber: driverPhone,
                  trips: [],
                );

                context.read<DriverCubit>().addDriver(driver);

                driverNameController.clear();
                driverPhoneController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDriverDialog(BuildContext context, Driver driver) {
    driverNameController.text = driver.name;
    driverPhoneController.text = driver.phoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: driverNameController,
                decoration: InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: driverPhoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
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
                final driverName = driverNameController.text;
                final driverPhone = driverPhoneController.text;

                final updatedDriver = Driver(
                  id: driver.id,
                  name: driverName,
                  phoneNumber: driverPhone,
                  trips: driver.trips,
                );

                context.read<DriverCubit>().updateDriver(updatedDriver);

                driverNameController.clear();
                driverPhoneController.clear();

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