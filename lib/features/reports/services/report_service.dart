import 'dart:io';
import 'dart:typed_data';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/transaction_feature/data/models/transaction_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReportService {
  // ============= SINGLE SELLER REPORTS =============

  /// Generate Excel report for a single seller with sub-items breakdown
  Future<File> generateSellerExcelReport(
    Seller seller,
    int month,
    int year,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Monthly Report'];

    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final subItemStyle = CellStyle(
      italic: true,
      backgroundColorHex: ExcelColor.fromHexString('#E3F2FD'),
    );

    // Title Row
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('J1'));
    var titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(
        '${seller.name} - ${DateFormat.MMMM().format(DateTime(0, month))} $year Report');
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 16);

    // Headers
    final headers = [
      'Car Name', // ✅ Changed from 'Item Name'
      'Item/Part Name', // ✅ New column for description
      'Type',
      'Quantity',
      'Unit Price',
      'Total Price',
      'Purchase Cost',
      'Total Paid',
      'Actual Gain',
      'Amount Owed'
    ];
    for (var i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Filter car parts ADDED in selected month
    final monthlyCarParts = seller.carParts
        .where((part) =>
            part.dateAdded.month == month && part.dateAdded.year == year)
        .toList();

    int row = 3;
    double totalSellingPriceSum = 0;
    double totalPurchaseCostSum = 0;
    double totalPaidSum = 0;
    double totalActualGainSum = 0;
    double totalOwedSum = 0;

    // Data rows with sub-items
    for (var carPart in monthlyCarParts) {
      final mainItemPrice = carPart.price * carPart.quantity;
      final mainItemCost = carPart.purchasePrice ?? 0.0;
      final totalSellingPrice = carPart.getTotalSellingPrice();
      final totalPurchaseCost = carPart.getTotalPurchasePrice();
      final totalPaid = carPart.getTotalPayments();
      final actualGain = carPart.getActualGain();

      totalSellingPriceSum += totalSellingPrice;
      totalPurchaseCostSum += totalPurchaseCost;
      totalPaidSum += totalPaid;
      totalActualGainSum += actualGain;
      totalOwedSum += carPart.amountOwed;

      // Main Item Row - ✅ Fixed: Car name in column A, description in column B
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(carPart.name); // ✅ Car name (e.g., "BMW 2020")
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value =
          TextCellValue(carPart.description.isNotEmpty
              ? carPart.description
              : 'Main Item'); // ✅ Item name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue('Main Item');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = IntCellValue(carPart.quantity);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue('\$${carPart.price.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue('\$${mainItemPrice.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue('\$${mainItemCost.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = TextCellValue('-');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          .value = TextCellValue('-');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          .value = TextCellValue('-');

      row++;

      // Sub-Items Rows
      if (carPart.subItems.isNotEmpty) {
        for (var subItem in carPart.subItems) {
          final subItemTotal = subItem.price * subItem.quantity;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value = TextCellValue('  ↳ ${carPart.name}'); // ✅ Parent car name
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value = TextCellValue(subItem.name); // ✅ Sub-item part name
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value = TextCellValue('Sub-Item');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .value = IntCellValue(subItem.quantity);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .value = TextCellValue('\$${subItem.price.toStringAsFixed(2)}');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
              .value = TextCellValue('\$${subItemTotal.toStringAsFixed(2)}');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
                  .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
                  .value =
              TextCellValue(
                  '\$${(subItem.purchasePrice ?? 0).toStringAsFixed(2)}');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
              .value = TextCellValue('-');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
              .value = TextCellValue('-');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
              .cellStyle = subItemStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
              .value = TextCellValue('-');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
              .cellStyle = subItemStyle;

          row++;
        }
      }

      // Total Row for this Sale
      var totalRowStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#FFF3E0'),
      );

      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value =
          TextCellValue('${carPart.name} - Total:'); // ✅ Show car name in total
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .cellStyle = totalRowStyle;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue('\$${totalSellingPrice.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .cellStyle = totalRowStyle;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue('\$${totalPurchaseCost.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .cellStyle = totalRowStyle;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = TextCellValue('\$${totalPaid.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .cellStyle = totalRowStyle;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          .value = TextCellValue('\$${actualGain.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          .cellStyle = totalRowStyle;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          .value = TextCellValue('\$${carPart.amountOwed.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          .cellStyle = totalRowStyle;

      row += 2; // Add space between sales
    }

    // Grand Total Summary
    var summaryStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('GRAND TOTAL');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = TextCellValue('\$${totalSellingPriceSum.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = TextCellValue('\$${totalPurchaseCostSum.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .value = TextCellValue('\$${totalPaidSum.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
        .value = TextCellValue('\$${totalActualGainSum.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
        .value = TextCellValue('\$${totalOwedSum.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
        .cellStyle = summaryStyle;

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${seller.name}_${month}_$year.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  /// Generate PDF report for a single seller with sub-items breakdown
  Future<File> generateSellerPDFReport(
    Seller seller,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();

    final monthlyCarParts = seller.carParts
        .where((part) =>
            part.dateAdded.month == month && part.dateAdded.year == year)
        .toList();

    double totalSellingPriceSum = 0;
    double totalPurchaseCostSum = 0;
    double totalPaidSum = 0;
    double totalActualGainSum = 0;
    double totalOwedSum = 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          final content = <pw.Widget>[
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    seller.name,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${DateFormat.MMMM().format(DateTime(0, month))} $year Report',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
          ];

          // Sales with Sub-Items
          for (var carPart in monthlyCarParts) {
            final totalSellingPrice = carPart.getTotalSellingPrice();
            final totalPurchaseCost = carPart.getTotalPurchasePrice();
            final totalPaid = carPart.getTotalPayments();
            final actualGain = carPart.getActualGain();

            totalSellingPriceSum += totalSellingPrice;
            totalPurchaseCostSum += totalPurchaseCost;
            totalPaidSum += totalPaid;
            totalActualGainSum += actualGain;
            totalOwedSum += carPart.amountOwed;

            content.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Sale Header - ✅ Show car name prominently
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              carPart.name, // ✅ Car name (e.g., "BMW 2020")
                              style: pw.TextStyle(
                                  fontSize: 16, fontWeight: pw.FontWeight.bold),
                            ),
                            if (carPart.description.isNotEmpty)
                              pw.Text(
                                carPart.description, // ✅ Item/Part description
                                style: pw.TextStyle(
                                    fontSize: 12, color: PdfColors.grey600),
                              ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: actualGain >= 0
                                ? PdfColors.green50
                                : PdfColors.red50,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            '${actualGain >= 0 ? "+" : ""}\$${actualGain.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: actualGain >= 0
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Main Item
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Main Item: ${carPart.quantity}x',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('\$${carPart.price.toStringAsFixed(2)} each',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(
                              'Total: \$${(carPart.price * carPart.quantity).toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              'Cost: \$${(carPart.purchasePrice ?? 0).toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.orange)),
                        ],
                      ),
                    ),

                    // Sub-Items
                    if (carPart.subItems.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Additional Parts (${carPart.subItems.length}):',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue700),
                            ),
                            pw.SizedBox(height: 4),
                            ...carPart.subItems.map((subItem) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 12, top: 4),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                          '• ${subItem.name}', // ✅ Sub-item part name
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                      pw.Text('${subItem.quantity}x',
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                      pw.Text(
                                          '\$${subItem.price.toStringAsFixed(2)} each',
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                      pw.Text(
                                          'Total: \$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.Text(
                                          'Cost: \$${(subItem.purchasePrice ?? 0).toStringAsFixed(2)}',
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              color: PdfColors.orange)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],

                    pw.SizedBox(height: 8),
                    pw.Divider(),

                    // Sale Summary
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                            'Total Price', totalSellingPrice, PdfColors.black),
                        _buildSummaryItem(
                            'Total Cost', totalPurchaseCost, PdfColors.orange),
                        _buildSummaryItem(
                            'Total Paid', totalPaid, PdfColors.blue),
                        _buildSummaryItem(
                            'Owed', carPart.amountOwed, PdfColors.red,
                            bold: true),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // Grand Total Summary
          content.add(pw.SizedBox(height: 20));
          content.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Monthly Summary',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 8),
                  _buildSummaryRow('Total Selling Price', totalSellingPriceSum,
                      PdfColors.blue),
                  _buildSummaryRow('Total Purchase Cost', totalPurchaseCostSum,
                      PdfColors.orange),
                  _buildSummaryRow('Total Paid', totalPaidSum, PdfColors.blue),
                  _buildSummaryRow('Total Owed', totalOwedSum, PdfColors.red),
                  pw.Divider(thickness: 2),
                  _buildSummaryRow(
                    'Total Actual Gain',
                    totalActualGainSum,
                    totalActualGainSum >= 0 ? PdfColors.green : PdfColors.red,
                    bold: true,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          );

          // Footer
          content.add(pw.SizedBox(height: 20));
          content.add(
            pw.Text(
              'Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );

          return content;
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${seller.name}_${month}_${year}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper widgets for PDF
  pw.Widget _buildSummaryItem(String label, double value, PdfColor color,
      {bool bold = false}) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(
          '\$${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: bold ? 11 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, double value, PdfColor color,
      {bool bold = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: fontSize - 1,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '\$${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============= ALL SELLERS REPORTS =============

  /// Generate Excel report for ALL sellers with sub-items support
  Future<File> generateAllSellersExcelReport(
    List<Seller> sellers,
    int month,
    int year,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['All Sellers Report'];

    // Title
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));
    var titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(
        'All Sellers - ${DateFormat.MMMM().format(DateTime(0, month))} $year Report');
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 16);

    // Headers
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = [
      'Seller Name',
      'Total Selling Price',
      'Total Cost',
      'Total Revenue',
      'Total Gain',
      'Monthly Owed',
      'Car Parts',
      'Sub-Items'
    ];
    for (var i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    int row = 3;
    double grandTotalSellingPrice = 0;
    double grandTotalCost = 0;
    double grandTotalRevenue = 0;
    double grandTotalGain = 0;
    double grandTotalMonthlyOwed = 0;
    int totalCarParts = 0;
    int totalSubItems = 0;

    for (var seller in sellers) {
      final monthlyCarParts = seller.carParts
          .where((part) =>
              part.dateAdded.month == month && part.dateAdded.year == year)
          .toList();

      double sellerTotalSellingPrice = 0;
      double sellerTotalCost = 0;
      double sellerRevenue = 0;
      double sellerGain = 0;
      double sellerMonthlyOwed = 0;
      int sellerSubItemsCount = 0;

      for (var carPart in monthlyCarParts) {
        final totalSellingPrice = carPart.getTotalSellingPrice();
        final totalPurchaseCost = carPart.getTotalPurchasePrice();
        final totalPaid = carPart.getTotalPayments();
        final actualGain = carPart.getActualGain();

        sellerTotalSellingPrice += totalSellingPrice;
        sellerTotalCost += totalPurchaseCost;
        sellerRevenue += totalPaid;
        sellerGain += actualGain;
        sellerMonthlyOwed += carPart.amountOwed;
        sellerSubItemsCount += carPart.subItems.length;
      }

      grandTotalSellingPrice += sellerTotalSellingPrice;
      grandTotalCost += sellerTotalCost;
      grandTotalRevenue += sellerRevenue;
      grandTotalGain += sellerGain;
      grandTotalMonthlyOwed += sellerMonthlyOwed;
      totalCarParts += monthlyCarParts.length;
      totalSubItems += sellerSubItemsCount;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(seller.name);
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value =
          TextCellValue('\$${sellerTotalSellingPrice.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue('\$${sellerTotalCost.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue('\$${sellerRevenue.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue('\$${sellerGain.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue('\$${sellerMonthlyOwed.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = IntCellValue(monthlyCarParts.length);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = IntCellValue(sellerSubItemsCount);

      row++;
    }

    // Grand Total
    row++;
    var summaryStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#BBDEFB'),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('GRAND TOTAL');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value =
        TextCellValue('\$${grandTotalSellingPrice.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('\$${grandTotalCost.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue('\$${grandTotalRevenue.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = TextCellValue('\$${grandTotalGain.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = TextCellValue('\$${grandTotalMonthlyOwed.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = IntCellValue(totalCarParts);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .value = IntCellValue(totalSubItems);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .cellStyle = summaryStyle;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/AllSellers_${month}_$year.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  /// Generate PDF report for ALL sellers
  Future<File> generateAllSellersPDFReport(
    List<Seller> sellers,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();

    double totalSellingPriceSum = 0.0;
    double totalCostSum = 0.0;
    double totalGainFromPayments = 0.0;
    double totalMonthlyOwed = 0.0;
    int totalCarParts = 0;
    int totalSubItems = 0;
    final sellerData = <Map<String, dynamic>>[];

    for (final seller in sellers) {
      final carPartsForMonth = seller.carParts.where((carPart) {
        return carPart.dateAdded.month == month &&
            carPart.dateAdded.year == year;
      }).toList();

      double sellerTotalSellingPrice = 0.0;
      double sellerTotalCost = 0.0;
      double sellerGain = 0.0;
      double sellerMonthlyOwed = 0.0;
      int sellerSubItemsCount = 0;

      for (var carPart in carPartsForMonth) {
        final totalSellingPrice = carPart.getTotalSellingPrice();
        final totalPurchaseCost = carPart.getTotalPurchasePrice();
        final totalPaid = carPart.getTotalPayments();
        final actualGain = carPart.getActualGain();

        sellerTotalSellingPrice += totalSellingPrice;
        sellerTotalCost += totalPurchaseCost;
        sellerGain += actualGain;
        sellerMonthlyOwed += carPart.amountOwed;
        sellerSubItemsCount += carPart.subItems.length;
      }

      totalSellingPriceSum += sellerTotalSellingPrice;
      totalCostSum += sellerTotalCost;
      totalGainFromPayments += sellerGain;
      totalMonthlyOwed += sellerMonthlyOwed;
      totalCarParts += carPartsForMonth.length;
      totalSubItems += sellerSubItemsCount;

      sellerData.add({
        'name': seller.name,
        'totalSellingPrice': sellerTotalSellingPrice,
        'totalCost': sellerTotalCost,
        'owed': seller.getTotalOwed(),
        'gain': sellerGain,
        'monthlyOwed': sellerMonthlyOwed,
        'carParts': carPartsForMonth.length,
        'subItems': sellerSubItemsCount,
      });
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Monthly Sellers Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${DateFormat.MMMM().format(DateTime(0, month))} $year',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                    'Total Selling Price',
                    '\$${totalSellingPriceSum.toStringAsFixed(2)}',
                    PdfColors.blue),
                _buildStatCard('Total Cost',
                    '\$${totalCostSum.toStringAsFixed(2)}', PdfColors.orange),
                _buildStatCard(
                    'Total Gain',
                    '\$${totalGainFromPayments.toStringAsFixed(2)}',
                    totalGainFromPayments >= 0
                        ? PdfColors.green
                        : PdfColors.red),
                _buildStatCard('Total Owed',
                    '\$${totalMonthlyOwed.toStringAsFixed(2)}', PdfColors.red),
              ],
            ),

            pw.SizedBox(height: 20),

            // Additional Stats
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('Total Sellers: ${sellers.length}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total Sales: $totalCarParts',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total Sub-Items: $totalSubItems',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Sellers Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Seller', isHeader: true),
                    _buildTableCell('Selling Price', isHeader: true),
                    _buildTableCell('Cost', isHeader: true),
                    _buildTableCell('Gain', isHeader: true),
                    _buildTableCell('Owed', isHeader: true),
                    _buildTableCell('Sales', isHeader: true),
                    _buildTableCell('Sub-Items', isHeader: true),
                  ],
                ),
                // Data Rows
                ...sellerData.map((data) {
                  final gain = data['gain'] as double;
                  return pw.TableRow(
                    children: [
                      _buildTableCell(data['name'] as String),
                      _buildTableCell(
                        '\$${(data['totalSellingPrice'] as double).toStringAsFixed(2)}',
                        textColor: PdfColors.blue,
                      ),
                      _buildTableCell(
                        '\$${(data['totalCost'] as double).toStringAsFixed(2)}',
                        textColor: PdfColors.orange,
                      ),
                      _buildTableCell(
                        '\$${gain.toStringAsFixed(2)}',
                        textColor: gain >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                      _buildTableCell(
                        '\$${(data['monthlyOwed'] as double).toStringAsFixed(2)}',
                        textColor: PdfColors.red,
                      ),
                      _buildTableCell('${data['carParts']}'),
                      _buildTableCell('${data['subItems']}'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer Note
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Note: This report includes all sales with their sub-items added in ${DateFormat.MMMM().format(DateTime(0, month))} $year. Gain calculation includes all payments received to date.',
                style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey800,
                    fontStyle: pw.FontStyle.italic),
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/all_sellers_report_${month}_${year}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper methods
  pw.Widget _buildTableCell(String text,
      {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildStatCard(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  /// Generate Invoice/Receipt for a single car part sale
  Future<File> generateInvoiceForCarPart({
    required CarPart carPart,
    required String sellerName,
    required String sellerId,
  }) async {
    final pdf = pw.Document();

    // Load logo
    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/Logo3.png');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      print('Logo not found: $e');
    }

    final totalSellingPrice = carPart.getTotalSellingPrice();
    final totalPurchaseCost = carPart.getTotalPurchasePrice();
    final totalPaid = carPart.getTotalPayments();
    final amountOwed = carPart.amountOwed;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo
                  if (logoBytes != null)
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 80,
                      height: 80,
                    )
                  else
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'LOGO',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Invoice Info - ✅ REMOVED Invoice # and Customer ID
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(carPart.dateAdded)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Customer Info - ✅ REMOVED Customer ID
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BILL TO:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      sellerName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Car/Item Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      carPart.name,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    if (carPart.description.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        carPart.description,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Items Table - ✅ CENTERED & CLEAN SUB-ITEMS
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildInvoiceTableCell('Item', isHeader: true),
                      _buildInvoiceTableCell('Qty', isHeader: true),
                      _buildInvoiceTableCell('Unit Price', isHeader: true),
                      _buildInvoiceTableCell('Total', isHeader: true),
                    ],
                  ),

                  // Main Item
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildInvoiceTableCell('Main Item', centered: false),
                      _buildInvoiceTableCell('${carPart.quantity}'),
                      _buildInvoiceTableCell(
                          '\$${carPart.price.toStringAsFixed(2)}'),
                      _buildInvoiceTableCell(
                        '\$${(carPart.price * carPart.quantity).toStringAsFixed(2)}',
                        bold: true,
                      ),
                    ],
                  ),

                  // Sub-Items - ✅ CLEAN & CENTERED
                  ...carPart.subItems.map((subItem) => pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.blue50),
                        children: [
                          _buildInvoiceTableCell(subItem.name,
                              centered: false,
                              fontSize: 9), // ✅ No bullets or numbers
                          _buildInvoiceTableCell('${subItem.quantity}',
                              fontSize: 9),
                          _buildInvoiceTableCell(
                              '\$${subItem.price.toStringAsFixed(2)}',
                              fontSize: 9),
                          _buildInvoiceTableCell(
                            '\$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                            fontSize: 9,
                            bold: true,
                          ),
                        ],
                      )),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totals Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildInvoiceTotalRow('Subtotal:', totalSellingPrice),
                        pw.Divider(thickness: 1),
                        _buildInvoiceTotalRow('Total Paid:', totalPaid,
                            color: PdfColors.green700),
                        _buildInvoiceTotalRow('Amount Owed:', amountOwed,
                            color: PdfColors.red700),
                        pw.Divider(thickness: 2),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: amountOwed > 0
                                ? PdfColors.red50
                                : PdfColors.green50,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: _buildInvoiceTotalRow(
                            'Balance Due:',
                            amountOwed,
                            color: amountOwed > 0
                                ? PdfColors.red900
                                : PdfColors.green900,
                            bold: true,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Payment History
              if (carPart.payments.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment History',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...carPart.payments.map((payment) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  DateFormat('dd/MM/yyyy').format(payment.date),
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                                pw.Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green700,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 20),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your business!',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/Invoice_${carPart.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // ✅ UPDATED: Helper method with center alignment option
  pw.Widget _buildInvoiceTableCell(String text,
      {bool isHeader = false,
      bool bold = false,
      double fontSize = 10,
      bool centered = true}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight:
              (isHeader || bold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : null,
        ),
        textAlign: centered ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildInvoiceTotalRow(String label, double value,
      {PdfColor? color, bool bold = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '\$${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
