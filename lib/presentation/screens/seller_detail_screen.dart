// import 'package:easy_localization/easy_localization.dart';
// import 'package:elshaf3y_store/presentation/screens/payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
// import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
// import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/services.dart';

// class SellerDetailScreen extends StatefulWidget {
//   final Seller seller;

//   SellerDetailScreen({super.key, required this.seller});

//   @override
//   _SellerDetailScreenState createState() => _SellerDetailScreenState();
// }

// class _SellerDetailScreenState extends State<SellerDetailScreen> {
//   final TextEditingController carPartNameController = TextEditingController();
//   final TextEditingController carPartPriceController = TextEditingController();
//   final TextEditingController carPartPurchasePriceController = TextEditingController();
//   final TextEditingController carPartDescriptionController = TextEditingController();
//   final TextEditingController carPartQuantityController = TextEditingController();
//   final TextEditingController paymentAmountController = TextEditingController();
//   bool isGridView = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//               backgroundColor: Colors.white,

//         title: Hero(
//           tag: 'seller_${widget.seller.id}', // Ensure unique tag for each seller
//           child: Text(widget.seller.name).tr(),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: BlocBuilder<SellerCubit, SellerState>(
//                 builder: (context, state) {
//                   if (state is SellerLoaded) {
//                     final updatedSeller = state.sellers.firstWhere((s) => s.id == widget.seller.id);
//                     final totalGain = updatedSeller.getMonthlyGain();
//                     return Text('Total Gain: \$${totalGain.toStringAsFixed(2)}').tr(namedArgs: {'amount': totalGain.toStringAsFixed(2)});
//                   }
//                   return Container();
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     _clearCarPartControllers(); // Clear the controllers before showing the dialog
//                     _showAddCarPartDialog(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black, backgroundColor: Colors.white,
//                     side: BorderSide(color: Colors.black),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: const Text('Add Seller'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     _showSortOptionsDialog(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black, backgroundColor: Colors.white,
//                     side: BorderSide(color: Colors.black),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: const Text('Sort'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isGridView = !isGridView;
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black, backgroundColor: Colors.white,
//                     side: BorderSide(color: Colors.black),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: const Text('Grid View'),
//                 ),
//               ],
//             ),
//           ),
//           BlocBuilder<SellerCubit, SellerState>(
//             builder: (context, state) {
//               if (state is SellerLoaded) {
//                 final updatedSeller = state.sellers.firstWhere((s) => s.id == widget.seller.id);
//                 final currentMonth = DateTime.now().month;
//                 final currentYear = DateTime.now().year;
//                 final carPartsThisMonth = updatedSeller.carParts.where((carPart) {
//                   return carPart.dateAdded.month == currentMonth && carPart.dateAdded.year == currentYear;
//                 }).toList();
//                 return Expanded(
//                   child: isGridView
//                       ? GridView.builder(
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             childAspectRatio: .8 / 2,
//                           ),
//                           itemCount: carPartsThisMonth.length,
//                           itemBuilder: (context, index) {
//                             final carPart = carPartsThisMonth[index];
//                             final gain = (carPart.price - carPart.purchasePrice) * carPart.quantity;
//                             return GestureDetector(
//                               onTap: () {
//                                 _showEditCarPartDialog(context, carPart);
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.all(8.0),
//                                 padding: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey.shade300),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.build, color: Colors.blue),
//                                         const SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Text(
//                                             carPart.name,
//                                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Table(
//                                       columnWidths: const {
//                                         0: FlexColumnWidth(1),
//                                         1: FlexColumnWidth(2),
//                                       },
//                                       children: [
//                                         TableRow(
//                                           children: [
//                                             const Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${(carPart.price * carPart.quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': (carPart.price * carPart.quantity).toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Purchase Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.purchasePrice.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Selled Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.price.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('${carPart.quantity}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'quantity': carPart.quantity.toString()}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text(DateFormat('yyyy-MM-dd').format(carPart.dateAdded), style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'date': DateFormat('yyyy-MM-dd').format(carPart.dateAdded)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Amount Owed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.amountOwed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.amountOwed.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Gain:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${gain.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': gain.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Text(
//                                       'Description: ${carPart.description}',
//                                       style: const TextStyle(color: Colors.black, fontSize: 16.0),
//                                     ).tr(namedArgs: {'description': carPart.description}),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.payment, color: Colors.green),
//                                           onPressed: () {
//                                             _showPaymentDialog(context, carPart);
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.list, color: Colors.blue),
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) => PaymentDetailsScreen(carPart: carPart),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete, color: Colors.red),
//                                           onPressed: () {
//                                             _showDeleteCarPartDialog(context, carPart);
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : ListView.builder(
//                           itemCount: carPartsThisMonth.length,
//                           itemBuilder: (context, index) {
//                             final carPart = carPartsThisMonth[index];
//                             final gain = (carPart.price - carPart.purchasePrice) * carPart.quantity;
//                             return GestureDetector(
//                               onTap: () {
//                                 _showEditCarPartDialog(context, carPart);
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                                 padding: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey.shade300),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.build, color: Colors.blue),
//                                         const SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Text(
//                                             carPart.name,
//                                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Table(
//                                       columnWidths: const {
//                                         0: FlexColumnWidth(1),
//                                         1: FlexColumnWidth(2),
//                                       },
//                                       children: [
//                                         TableRow(
//                                           children: [
//                                             const Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${(carPart.price * carPart.quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': (carPart.price * carPart.quantity).toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Purchase Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.purchasePrice.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Selled Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.price.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('${carPart.quantity}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'quantity': carPart.quantity.toString()}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text(DateFormat('yyyy-MM-dd').format(carPart.dateAdded), style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'date': DateFormat('yyyy-MM-dd').format(carPart.dateAdded)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Amount Owed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${carPart.amountOwed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.amountOwed.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                         TableRow(
//                                           children: [
//                                             const Text('Gain:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
//                                             Text('\$${gain.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': gain.toStringAsFixed(2)}),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Text(
//                                       'Description: ${carPart.description}',
//                                       style: const TextStyle(color: Colors.black, fontSize: 16.0),
//                                     ).tr(namedArgs: {'description': carPart.description}),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.payment, color: Colors.green),
//                                           onPressed: () {
//                                             _showPaymentDialog(context, carPart);
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.list, color: Colors.blue),
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) => PaymentDetailsScreen(carPart: carPart),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete, color: Colors.red),
//                                           onPressed: () {
//                                             _showDeleteCarPartDialog(context, carPart);
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 );
//               }
//               return const Center(child: CircularProgressIndicator());
//             },
//           ),
//         ],
//       ),

//     );
//   }

//   void _clearCarPartControllers() {
//     carPartNameController.clear();
//     carPartPriceController.clear();
//     carPartPurchasePriceController.clear();
//     carPartDescriptionController.clear();
//     carPartQuantityController.clear();
//   }

//   void _showAddCarPartDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add New Car Part').tr(),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: carPartNameController,
//                 decoration: InputDecoration(labelText: 'Car Part Name'.tr()),
//               ),
//               TextField(
//                 controller: carPartPriceController,
//                 decoration: InputDecoration(labelText: 'Car Part Price'.tr()),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//               TextField(
//                 controller: carPartPurchasePriceController,
//                 decoration: InputDecoration(labelText: 'Car Part Purchase Price'.tr()),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//               TextField(
//                 controller: carPartDescriptionController,
//                 decoration: InputDecoration(labelText: 'Car Part Description'.tr()),
//               ),
//               TextField(
//                 controller: carPartQuantityController,
//                 decoration: InputDecoration(labelText: 'Car Part Quantity'.tr()),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel').tr(),
//             ),
//             TextButton(
//               onPressed: () {
//                 final carPartName = carPartNameController.text;
//                 final carPartPrice = double.parse(carPartPriceController.text);
//                 final carPartPurchasePrice = double.parse(carPartPurchasePriceController.text);
//                 final carPartDescription = carPartDescriptionController.text;
//                 final carPartQuantity = int.parse(carPartQuantityController.text);

//                 final carPart = CarPart(
//                   id: const Uuid().v4(),
//                   name: carPartName,
//                   price: carPartPrice,
//                   purchasePrice: carPartPurchasePrice,
//                   description: carPartDescription,
//                   quantity: carPartQuantity,
//                   dateAdded: DateTime.now(),
//                   amountOwed: carPartPrice * carPartQuantity,
//                 );

//                 context.read<SellerCubit>().addCarPartToSeller(widget.seller.id, carPart);

//                 _clearCarPartControllers(); // Clear the controllers after adding the car part

//                 Navigator.of(context).pop();
//               },
//               child: const Text('Add').tr(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditCarPartDialog(BuildContext context, CarPart carPart) {
//     carPartNameController.text = carPart.name;
//     carPartPriceController.text = carPart.price.toString();
//     carPartPurchasePriceController.text = carPart.purchasePrice.toString();
//     carPartDescriptionController.text = carPart.description;
//     carPartQuantityController.text = carPart.quantity.toString();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Edit Car Part').tr(),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: carPartNameController,
//                 decoration: InputDecoration(labelText: 'Car Part Name'.tr()),
//               ),
//               TextField(
//                 controller: carPartPriceController,
//                 decoration: InputDecoration(labelText: 'Car Part Price'.tr()),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: carPartPurchasePriceController,
//                 decoration: InputDecoration(labelText: 'Car Part Purchase Price'.tr()),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: carPartDescriptionController,
//                 decoration: InputDecoration(labelText: 'Car Part Description'.tr()),
//               ),
//               TextField(
//                 controller: carPartQuantityController,
//                 decoration: InputDecoration(labelText: 'Car Part Quantity'.tr()),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel').tr(),
//             ),
//             TextButton(
//               onPressed: () {
//                 final carPartName = carPartNameController.text;
//                 final carPartPrice = double.parse(carPartPriceController.text);
//                 final carPartPurchasePrice = double.parse(carPartPurchasePriceController.text);
//                 final carPartDescription = carPartDescriptionController.text;
//                 final carPartQuantity = int.parse(carPartQuantityController.text);

//                 final updatedCarPart = CarPart(
//                   id: carPart.id,
//                   name: carPartName,
//                   price: carPartPrice,
//                   purchasePrice: carPartPurchasePrice,
//                   description: carPartDescription,
//                   quantity: carPartQuantity,
//                   dateAdded: carPart.dateAdded,
//                   amountOwed: carPart.price * carPart.quantity,
//                   payments: carPart.payments, // Preserve existing payments
//                 );

//                 context.read<SellerCubit>().updateCarPart(widget.seller.id, updatedCarPart);

//                 _clearCarPartControllers(); // Clear the controllers after editing the car part

//                 Navigator.of(context).pop();
//               },
//               child: const Text('Save').tr(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showPaymentDialog(BuildContext context, CarPart carPart) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Make Payment').tr(),
//           content: TextField(
//             controller: paymentAmountController,
//             decoration: InputDecoration(labelText: 'Payment Amount'.tr()),
//             keyboardType: TextInputType.number,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel').tr(),
//             ),
//             TextButton(
//               onPressed: () {
//                 final paymentAmount = double.parse(paymentAmountController.text);
//                 final remainingAmount = carPart.amountOwed - paymentAmount;

//                 final payment = Payment(amount: paymentAmount, date: DateTime.now());

//                 final updatedCarPart = CarPart(
//                   id: carPart.id,
//                   name: carPart.name,
//                   price: carPart.price,
//                   purchasePrice: carPart.purchasePrice,
//                   description: carPart.description,
//                   quantity: carPart.quantity,
//                   dateAdded: carPart.dateAdded,
//                   amountOwed: remainingAmount,
//                   payments: [...carPart.payments, payment], // Add the new payment
//                 );

//                 context.read<SellerCubit>().updateCarPart(widget.seller.id, updatedCarPart);

//                 paymentAmountController.clear();

//                 Navigator.of(context).pop();
//               },
//               child: const Text('Pay').tr(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteCarPartDialog(BuildContext context, CarPart carPart) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Car Part').tr(),
//           content: const Text('Are you sure you want to delete this car part?').tr(),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel').tr(),
//             ),
//             TextButton(
//               onPressed: () {
//                 context.read<SellerCubit>().deleteCarPart(widget.seller.id, carPart.id);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Delete').tr(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSortOptionsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Sort Options').tr(),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: const Text('Sort by Date').tr(),
//                 onTap: () {
//                   context.read<SellerCubit>().sortCarPartsByDate(widget.seller.id);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 title: const Text('Sort by Price').tr(),
//                 onTap: () {
//                   context.read<SellerCubit>().sortCarPartsByPrice(widget.seller.id);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 title: const Text('Sort by Amount Owed').tr(),
//                 onTap: () {
//                   context.read<SellerCubit>().sortCarPartsByAmountOwed(widget.seller.id);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:elshaf3y_store/presentation/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/seller_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class SellerDetailScreen extends StatefulWidget {
  final Seller seller;

  SellerDetailScreen({super.key, required this.seller});

  @override
  _SellerDetailScreenState createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  final TextEditingController carPartNameController = TextEditingController();
  final TextEditingController carPartPriceController = TextEditingController();
  final TextEditingController carPartPurchasePriceController = TextEditingController();
  final TextEditingController carPartDescriptionController = TextEditingController();
  final TextEditingController carPartQuantityController = TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController();
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
appBar: AppBar(
  backgroundColor: Colors.white,
  centerTitle: true,
  title: BlocBuilder<SellerCubit, SellerState>(
    builder: (context, state) {
      if (state is SellerLoaded) {
        final updatedSeller = state.sellers.firstWhere((s) => s.id == widget.seller.id);
        final totalGain = updatedSeller.getMonthlyGain();
        return Column(
          children: [
            Hero(
              tag: 'seller_${widget.seller.id}', // Ensure unique tag for each seller
              child: Text(widget.seller.name).tr(),
            ),
            Text('Total Gain: \$${totalGain.toStringAsFixed(2)}').tr(namedArgs: {'amount': totalGain.toStringAsFixed(2)}),
          ],
        );
      }
      return Container();
    },
  ),
  actions: [],
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
                    _clearCarPartControllers(); // Clear the controllers before showing the dialog
                    _showAddCarPartDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Sale'),
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
            
              ],
            ),
          ),
     BlocBuilder<SellerCubit, SellerState>(
  builder: (context, state) {
    if (state is SellerLoaded) {
      final updatedSeller = state.sellers.firstWhere((s) => s.id == widget.seller.id);
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;
      final carPartsThisMonth = updatedSeller.carParts.where((carPart) {
        return carPart.dateAdded.month == currentMonth && carPart.dateAdded.year == currentYear;
      }).toList();
      return Expanded(
        child: ListView.builder(
          key: ValueKey(carPartsThisMonth), // Add a key to force rebuild
          itemCount: carPartsThisMonth.length,
          itemBuilder: (context, index) {
            final carPart = carPartsThisMonth[carPartsThisMonth.length - index - 1];
            final gain = (carPart.price - carPart.purchasePrice) * carPart.quantity;
            return GestureDetector(
              onTap: () {
                _showEditCarPartDialog(context, carPart);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.build, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            carPart.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('\$${(carPart.price * carPart.quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': (carPart.price * carPart.quantity).toStringAsFixed(2)}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Purchase Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('\$${carPart.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.purchasePrice.toStringAsFixed(2)}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Selled Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('\$${carPart.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.price.toStringAsFixed(2)}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('${carPart.quantity}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'quantity': carPart.quantity.toString()}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text(DateFormat('yyyy-MM-dd').format(carPart.dateAdded), style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'date': DateFormat('yyyy-MM-dd').format(carPart.dateAdded)}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Amount Owed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('\$${carPart.amountOwed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': carPart.amountOwed.toStringAsFixed(2)}),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Gain:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)).tr(),
                            Text('\$${gain.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16.0)).tr(namedArgs: {'amount': gain.toStringAsFixed(2)}),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Description: ${carPart.description}',
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
                    ).tr(namedArgs: {'description': carPart.description}),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.payment, color: Colors.green),
                          onPressed: () {
                            _showPaymentDialog(context, carPart);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentDetailsScreen(carPart: carPart),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteCarPartDialog(context, carPart);
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
      );
    }
    return const Center(child: CircularProgressIndicator());
  },
),
        ],
      ),
   
    );
  }

  void _clearCarPartControllers() {
    carPartNameController.clear();
    carPartPriceController.clear();
    carPartPurchasePriceController.clear();
    carPartDescriptionController.clear();
    carPartQuantityController.clear();
  }

  void _showAddCarPartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Car Part').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carPartNameController,
                decoration: InputDecoration(labelText: 'Car Part Name'.tr()),
              ),
              TextField(
                controller: carPartPriceController,
                decoration: InputDecoration(labelText: 'Car Part Price'.tr()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: carPartPurchasePriceController,
                decoration: InputDecoration(labelText: 'Car Part Purchase Price'.tr()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: carPartDescriptionController,
                decoration: InputDecoration(labelText: 'Car Part Description'.tr()),
              ),
              TextField(
                controller: carPartQuantityController,
                decoration: InputDecoration(labelText: 'Car Part Quantity'.tr()),
                keyboardType: TextInputType.number,
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
            TextButton(
              onPressed: () {
                final carPartName = carPartNameController.text;
                final carPartPrice = double.parse(carPartPriceController.text);
                final carPartPurchasePrice = double.parse(carPartPurchasePriceController.text);
                final carPartDescription = carPartDescriptionController.text;
                final carPartQuantity = int.parse(carPartQuantityController.text);

                final carPart = CarPart(
                  id: const Uuid().v4(),
                  name: carPartName,
                  price: carPartPrice,
                  purchasePrice: carPartPurchasePrice,
                  description: carPartDescription,
                  quantity: carPartQuantity,
                  dateAdded: DateTime.now(),
                  amountOwed: carPartPrice * carPartQuantity,
                );

                context.read<SellerCubit>().addCarPartToSeller(widget.seller.id, carPart);

                _clearCarPartControllers(); // Clear the controllers after adding the car part

                Navigator.of(context).pop();
              },
              child: const Text('Add').tr(),
            ),
          ],
        );
      },
    );
  }

  void _showEditCarPartDialog(BuildContext context, CarPart carPart) {
    carPartNameController.text = carPart.name;
    carPartPriceController.text = carPart.price.toString();
    carPartPurchasePriceController.text = carPart.purchasePrice.toString();
    carPartDescriptionController.text = carPart.description;
    carPartQuantityController.text = carPart.quantity.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Car Part').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carPartNameController,
                decoration: InputDecoration(labelText: 'Car Part Name'.tr()),
              ),
              TextField(
                controller: carPartPriceController,
                decoration: InputDecoration(labelText: 'Car Part Price'.tr()),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carPartPurchasePriceController,
                decoration: InputDecoration(labelText: 'Car Part Purchase Price'.tr()),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carPartDescriptionController,
                decoration: InputDecoration(labelText: 'Car Part Description'.tr()),
              ),
              TextField(
                controller: carPartQuantityController,
                decoration: InputDecoration(labelText: 'Car Part Quantity'.tr()),
                keyboardType: TextInputType.number,
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
            TextButton(
              onPressed: () {
                final carPartName = carPartNameController.text;
                final carPartPrice = double.parse(carPartPriceController.text);
                final carPartPurchasePrice = double.parse(carPartPurchasePriceController.text);
                final carPartDescription = carPartDescriptionController.text;
                final carPartQuantity = int.parse(carPartQuantityController.text);

                final updatedCarPart = CarPart(
                  id: carPart.id,
                  name: carPartName,
                  price: carPartPrice,
                  purchasePrice: carPartPurchasePrice,
                  description: carPartDescription,
                  quantity: carPartQuantity,
                  dateAdded: carPart.dateAdded,
                  amountOwed: carPart.price * carPart.quantity,
                  payments: carPart.payments, // Preserve existing payments
                );

                context.read<SellerCubit>().updateCarPart(widget.seller.id, updatedCarPart);

                _clearCarPartControllers(); // Clear the controllers after editing the car part

                Navigator.of(context).pop();
              },
              child: const Text('Save').tr(),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, CarPart carPart) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Make Payment').tr(),
          content: TextField(
            controller: paymentAmountController,
            decoration: InputDecoration(labelText: 'Payment Amount'.tr()),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                final paymentAmount = double.parse(paymentAmountController.text);
                final remainingAmount = carPart.amountOwed - paymentAmount;

                final payment = Payment(amount: paymentAmount, date: DateTime.now());

                final updatedCarPart = CarPart(
                  id: carPart.id,
                  name: carPart.name,
                  price: carPart.price,
                  purchasePrice: carPart.purchasePrice,
                  description: carPart.description,
                  quantity: carPart.quantity,
                  dateAdded: carPart.dateAdded,
                  amountOwed: remainingAmount,
                  payments: [...carPart.payments, payment], // Add the new payment
                );

                context.read<SellerCubit>().updateCarPart(widget.seller.id, updatedCarPart);

                paymentAmountController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Pay').tr(),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCarPartDialog(BuildContext context, CarPart carPart) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Car Part').tr(),
          content: const Text('Are you sure you want to delete this car part?').tr(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                context.read<SellerCubit>().deleteCarPart(widget.seller.id, carPart.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete').tr(),
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
                backgroundColor: Colors.white,

          title: const Text('Sort Options').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Date').tr(),
                onTap: () {
                  context.read<SellerCubit>().sortCarPartsByDate(widget.seller.id);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Sort by Price').tr(),
                onTap: () {
                  context.read<SellerCubit>().sortCarPartsByPrice(widget.seller.id);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Sort by Amount Owed').tr(),
                onTap: () {
                  context.read<SellerCubit>().sortCarPartsByAmountOwed(widget.seller.id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}