import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/transaction_feature/data/models/transaction_model.dart';

class ReportService {
  // ============= SINGLE SELLER REPORTS =============

  /// Generate Excel report for a single seller
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

    // Title Row
    sheet.merge(CellIndex.indexByString('A1'),
        CellIndex.indexByString('H1')); // ✅ Changed to H
    var titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(
        '${seller.name} - ${DateFormat.MMMM().format(DateTime(0, month))} $year Report');
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 16);

    // Headers
    final headers = [
      'Car Part',
      'Total Price', // ✅ NEW
      'Purchase Price',
      'Total Paid',
      'Amount Owed',
      'Actual Gain',
      'Monthly Owed'
    ];
    for (var i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // ✅ Filter car parts ADDED in selected month
    final monthlyCarParts = seller.carParts
        .where((part) =>
            part.dateAdded.month == month && part.dateAdded.year == year)
        .toList();

    int row = 3;
    double totalSellingPriceSum = 0; // ✅ NEW
    double totalRevenue = 0;
    double totalCost = 0;
    double totalGain = 0;
    double totalMonthlyOwed = 0;

    // Data rows
    for (var carPart in monthlyCarParts) {
      final totalSellingPrice = carPart.price * carPart.quantity;
      final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

      // ✅ Count ALL payments for this car part (not just this month)
      double totalPayments =
          carPart.payments.fold(0.0, (sum, payment) => sum + payment.amount);

      // ✅ SIMPLE: Gain = Payments - Cost
      final actualGain = totalPayments - totalPurchasePrice;

      // ✅ Monthly Owed = How much is still owed for this car part
      final monthlyOwed = carPart.amountOwed;

      totalSellingPriceSum += totalSellingPrice; // ✅ NEW
      totalRevenue += totalPayments;
      totalCost += totalPurchasePrice;
      totalGain += actualGain;
      totalMonthlyOwed += monthlyOwed;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(carPart.name);
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value =
          TextCellValue('\$${totalSellingPrice.toStringAsFixed(2)}'); // ✅ NEW
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue('\$${totalPurchasePrice.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue('\$${totalPayments.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue('\$${carPart.amountOwed.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue('\$${actualGain.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue('\$${monthlyOwed.toStringAsFixed(2)}');

      row++;
    }

    // Summary row
    row++;
    var summaryStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('TOTAL');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value =
        TextCellValue('\$${totalSellingPriceSum.toStringAsFixed(2)}'); // ✅ NEW
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue('\$${totalRevenue.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = TextCellValue('\$${totalGain.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = TextCellValue('\$${totalMonthlyOwed.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .cellStyle = summaryStyle;

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${seller.name}_${month}_$year.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  /// Generate PDF report for a single seller
  Future<File> generateSellerPDFReport(
    Seller seller,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();

    // ✅ Filter car parts ADDED in selected month
    final monthlyCarParts = seller.carParts
        .where((part) =>
            part.dateAdded.month == month && part.dateAdded.year == year)
        .toList();

    double totalSellingPriceSum = 0; // ✅ NEW
    double totalRevenue = 0;
    double totalCost = 0;
    double totalGain = 0;
    double totalMonthlyOwed = 0;

    final tableData = <List<String>>[];

    for (var carPart in monthlyCarParts) {
      final totalSellingPrice = carPart.price * carPart.quantity;
      final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

      // ✅ Count ALL payments for this car part
      double totalPayments =
          carPart.payments.fold(0.0, (sum, payment) => sum + payment.amount);

      // ✅ SIMPLE: Gain = Payments - Cost
      final actualGain = totalPayments - totalPurchasePrice;
      final monthlyOwed = carPart.amountOwed;

      totalSellingPriceSum += totalSellingPrice; // ✅ NEW
      totalRevenue += totalPayments;
      totalCost += totalPurchasePrice;
      totalGain += actualGain;
      totalMonthlyOwed += monthlyOwed;

      tableData.add([
        carPart.name,
        '\$${totalSellingPrice.toStringAsFixed(2)}', // ✅ NEW
        '\$${totalPurchasePrice.toStringAsFixed(2)}',
        '\$${totalPayments.toStringAsFixed(2)}',
        '\$${carPart.amountOwed.toStringAsFixed(2)}',
        '\$${actualGain.toStringAsFixed(2)}',
        '\$${monthlyOwed.toStringAsFixed(2)}',
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat
            .a4.landscape, // ✅ Change to landscape for more columns
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              seller.name,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            '${DateFormat.MMMM().format(DateTime(0, month))} $year Report',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table.fromTextArray(
            headers: [
              'Car Part',
              'Total Price', // ✅ NEW
              'Purchase Price',
              'Total Paid',
              'Amount Owed',
              'Actual Gain',
              'Monthly Owed'
            ],
            data: tableData,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(
                fontSize: 8), // ✅ Smaller font for more columns
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              border: pw.Border.all(color: PdfColors.green),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Summary',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Selling Price:', // ✅ NEW
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${totalSellingPriceSum.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Revenue:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${totalRevenue.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Cost:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${totalCost.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Monthly Owed:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${totalMonthlyOwed.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange)),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Gain:',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${totalGain.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: totalGain >= 0
                                ? PdfColors.green
                                : PdfColors.red)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Text(
            'Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${seller.name}_${month}_$year ${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // ============= ALL SELLERS REPORTS =============

  /// Generate Excel report for ALL sellers
  Future<File> generateAllSellersExcelReport(
    List<Seller> sellers,
    int month,
    int year,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['All Sellers Report'];

    // Title
    sheet.merge(CellIndex.indexByString('A1'),
        CellIndex.indexByString('G1')); // ✅ Changed to G
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
      'Total Selling Price', // ✅ NEW
      'Total Revenue',
      'Total Cost',
      'Total Gain',
      'Monthly Owed',
      'Car Parts'
    ];
    for (var i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    int row = 3;
    double grandTotalSellingPrice = 0; // ✅ NEW
    double grandTotalRevenue = 0;
    double grandTotalCost = 0;
    double grandTotalGain = 0;
    double grandTotalMonthlyOwed = 0;

    for (var seller in sellers) {
      // ✅ Filter car parts ADDED in selected month
      final monthlyCarParts = seller.carParts
          .where((part) =>
              part.dateAdded.month == month && part.dateAdded.year == year)
          .toList();

      double sellerTotalSellingPrice = 0; // ✅ NEW
      double sellerRevenue = 0;
      double sellerCost = 0;
      double sellerGain = 0;
      double sellerMonthlyOwed = 0;

      for (var carPart in monthlyCarParts) {
        final totalSellingPrice = carPart.price * carPart.quantity;
        final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

        // ✅ Count ALL payments for this car part
        double totalPayments =
            carPart.payments.fold(0.0, (sum, payment) => sum + payment.amount);

        // ✅ SIMPLE: Gain = Payments - Cost
        final actualGain = totalPayments - totalPurchasePrice;

        sellerTotalSellingPrice += totalSellingPrice; // ✅ NEW
        sellerRevenue += totalPayments;
        sellerCost += totalPurchasePrice;
        sellerGain += actualGain;
        sellerMonthlyOwed += carPart.amountOwed;
      }

      grandTotalSellingPrice += sellerTotalSellingPrice; // ✅ NEW
      grandTotalRevenue += sellerRevenue;
      grandTotalCost += sellerCost;
      grandTotalGain += sellerGain;
      grandTotalMonthlyOwed += sellerMonthlyOwed;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(seller.name);
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value =
          TextCellValue(
              '\$${sellerTotalSellingPrice.toStringAsFixed(2)}'); // ✅ NEW
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue('\$${sellerRevenue.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue('\$${sellerCost.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue('\$${sellerGain.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue('\$${sellerMonthlyOwed.toStringAsFixed(2)}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue(monthlyCarParts.length.toString());

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
        TextCellValue(
            '\$${grandTotalSellingPrice.toStringAsFixed(2)}'); // ✅ NEW
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('\$${grandTotalRevenue.toStringAsFixed(2)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .cellStyle = summaryStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue('\$${grandTotalCost.toStringAsFixed(2)}');
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

    // ✅ Calculate gain for car parts ADDED in selected month
    double totalSellingPriceSum = 0.0; // ✅ NEW
    double totalGainFromPayments = 0.0;
    double totalMonthlyOwed = 0.0;
    final sellerData = <Map<String, dynamic>>[];

    for (final seller in sellers) {
      // Filter car parts ADDED in this month
      final carPartsForMonth = seller.carParts.where((carPart) {
        return carPart.dateAdded.month == month &&
            carPart.dateAdded.year == year;
      }).toList();

      double sellerTotalSellingPrice = 0.0; // ✅ NEW
      double sellerGain = 0.0;
      double sellerMonthlyOwed = 0.0;

      for (var carPart in carPartsForMonth) {
        final totalSellingPrice = carPart.price * carPart.quantity;
        final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

        // Count ALL payments
        double totalPayments =
            carPart.payments.fold(0.0, (sum, payment) => sum + payment.amount);

        // ✅ SIMPLE: Gain = Payments - Cost
        final actualGain = totalPayments - totalPurchasePrice;

        sellerTotalSellingPrice += totalSellingPrice; // ✅ NEW
        sellerGain += actualGain;
        sellerMonthlyOwed += carPart.amountOwed;
      }

      totalSellingPriceSum += sellerTotalSellingPrice; // ✅ NEW
      totalGainFromPayments += sellerGain;
      totalMonthlyOwed += sellerMonthlyOwed;

      sellerData.add({
        'name': seller.name,
        'totalSellingPrice': sellerTotalSellingPrice, // ✅ NEW
        'owed': seller.getTotalOwed(),
        'gain': sellerGain,
        'monthlyOwed': sellerMonthlyOwed,
      });
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // ✅ Landscape for more columns
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

            // ✅ NET GAIN SECTION
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Monthly Net Gain',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Total Selling Price: \$${totalSellingPriceSum.toStringAsFixed(2)}', // ✅ NEW
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Total Gain from Car Parts Added This Month: \$${totalGainFromPayments.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: totalGainFromPayments >= 0
                          ? PdfColors.green
                          : PdfColors.red,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Total Monthly Owed: \$${totalMonthlyOwed.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Note: This shows gain from car parts added in ${DateFormat.MMMM().format(DateTime(0, month))} $year (including all their payments). Driver costs and personal expenses should be subtracted for final net gain.',
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic),
                  ),
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
                    _buildTableCell('Seller Name', isHeader: true),
                    _buildTableCell('Total Selling Price',
                        isHeader: true), // ✅ NEW
                    _buildTableCell('Total Owed', isHeader: true),
                    _buildTableCell('Monthly Owed', isHeader: true),
                    _buildTableCell('Monthly Gain', isHeader: true),
                  ],
                ),
                // Data Rows
                ...sellerData.map((data) {
                  final monthlyGain = data['gain'] as double;
                  final monthlyOwed = data['monthlyOwed'] as double;
                  final totalSellingPrice =
                      data['totalSellingPrice'] as double; // ✅ NEW
                  return pw.TableRow(
                    children: [
                      _buildTableCell(data['name'] as String),
                      _buildTableCell(
                        // ✅ NEW
                        '\$${totalSellingPrice.toStringAsFixed(2)}',
                        textColor: PdfColors.blue,
                      ),
                      _buildTableCell(
                          '\$${(data['owed'] as double).toStringAsFixed(2)}'),
                      _buildTableCell(
                        '\$${monthlyOwed.toStringAsFixed(2)}',
                        textColor: PdfColors.orange,
                      ),
                      _buildTableCell(
                        '\$${monthlyGain.toStringAsFixed(2)}',
                        textColor:
                            monthlyGain >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Sellers: ${sellers.length}'),
                  pw.Text(
                      'Total Selling Price (Monthly): \$${totalSellingPriceSum.toStringAsFixed(2)}'), // ✅ NEW
                  pw.Text(
                      'Total Owed (All Time): \$${sellers.fold(0.0, (sum, s) => sum + s.getTotalOwed()).toStringAsFixed(2)}'),
                  pw.Text(
                      'Total Monthly Owed: \$${totalMonthlyOwed.toStringAsFixed(2)}'),
                  pw.Text(
                      'Total Monthly Gain: \$${totalGainFromPayments.toStringAsFixed(2)}'),
                ],
              ),
            ),

            // Footer
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/all_sellers_report_${month}_$year ${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper method for table cells
  pw.Widget _buildTableCell(String text,
      {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}
