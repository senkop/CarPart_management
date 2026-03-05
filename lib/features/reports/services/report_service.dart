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
import 'package:http/http.dart' as http; // ✅ Add this

class ReportService {
  // ✅ Load Arabic Font
  // ✅ SIMPLIFIED: Load bundled Arabic Font
  Future<pw.Font> _loadArabicFont() async {
    try {
      // Load the bundled Cairo Regular font
      final fontData =
          await rootBundle.load('assets/fonts/static/Cairo-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Failed to load Cairo font: $e');

      // Try variable font as fallback
      try {
        final varFont = await rootBundle
            .load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf');
        return pw.Font.ttf(varFont);
      } catch (e2) {
        print('Variable font also failed: $e2');
        rethrow;
      }
    }
  }

  // ✅ Helper function to detect if text contains Arabic characters
  bool _containsArabic(String text) {
    if (text.isEmpty) return false;
    // Check if any character is in Arabic Unicode range
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }

  // ✅ Helper to determine text direction
  pw.TextDirection _getTextDirection(String text) {
    return _containsArabic(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  }

  Future<File> generateInvoiceForCarPart({
    required CarPart carPart,
    required String sellerName,
    required String sellerId,
  }) async {
    final pdf = pw.Document();

    // ✅ Load Arabic font
    final arabicFont = await _loadArabicFont();

    // ✅ COMPACT text styles
    pw.TextStyle tinyStyle = pw.TextStyle(font: arabicFont, fontSize: 7);
    pw.TextStyle normalStyle = pw.TextStyle(font: arabicFont, fontSize: 8);
    pw.TextStyle boldStyle = pw.TextStyle(
        font: arabicFont, fontSize: 8, fontWeight: pw.FontWeight.bold);
    pw.TextStyle headerStyle = pw.TextStyle(
        font: arabicFont, fontSize: 9, fontWeight: pw.FontWeight.bold);
    pw.TextStyle titleStyle = pw.TextStyle(
        font: arabicFont,
        fontSize: 20, // ✅ Reduced from 32
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900);

    // Load logo
    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/Logo3.png');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      print('Logo not found: $e');
    }

    final totalSellingPrice = carPart.getTotalSellingPrice();
    final totalPaid = carPart.getTotalPayments();
    final amountOwed = carPart.amountOwed;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20), // ✅ Reduced margins
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ✅ COMPACT Header - Logo + Invoice Info side by side
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.blue900, width: 2)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Logo + Company Name
                    pw.Row(
                      children: [
                        if (logoBytes != null)
                          pw.Image(
                            pw.MemoryImage(logoBytes),
                            width: 50, // ✅ Smaller logo
                            height: 50,
                          )
                        else
                          pw.Container(
                            width: 50,
                            height: 50,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'LOGO',
                                style: pw.TextStyle(
                                  font: arabicFont,
                                  color: PdfColors.white,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('INVOICE', style: titleStyle),
                            pw.Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(carPart.dateAdded),
                              style: tinyStyle,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Customer Info (Right side)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('BILL TO:',
                              style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 7,
                                  color: PdfColors.grey600)),
                          pw.Text(
                            sellerName,
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textDirection: _getTextDirection(sellerName),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // ✅ COMPACT Car Name Badge
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Text(
                  carPart.name,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                  textDirection: _getTextDirection(carPart.name),
                ),
              ),

              pw.SizedBox(height: 10),

              // ✅ COMPACT Items Table
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1.2),
                  3: pw.FlexColumnWidth(1.2),
                },
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildCompactTableCell('Item', headerStyle,
                          isHeader: true),
                      _buildCompactTableCell('Qty', headerStyle,
                          isHeader: true),
                      _buildCompactTableCell('Price', headerStyle,
                          isHeader: true),
                      _buildCompactTableCell('Total', headerStyle,
                          isHeader: true),
                    ],
                  ),

                  // Main Item
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildCompactTableCell(
                          carPart.description.isNotEmpty
                              ? carPart.description
                              : 'Main Item',
                          normalStyle,
                          isArabic: true),
                      _buildCompactTableCell(
                          '${carPart.quantity}', normalStyle),
                      _buildCompactTableCell(
                          '\$${carPart.price.toStringAsFixed(2)}', normalStyle),
                      _buildCompactTableCell(
                        '\$${(carPart.price * carPart.quantity).toStringAsFixed(2)}',
                        boldStyle,
                      ),
                    ],
                  ),

                  // Sub-Items
                  ...carPart.subItems.map((subItem) {
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.blue50),
                      children: [
                        _buildCompactTableCell(
                          '  • ${subItem.name}',
                          tinyStyle,
                          isArabic: _containsArabic(subItem.name),
                        ),
                        _buildCompactTableCell(
                            '${subItem.quantity}', tinyStyle),
                        _buildCompactTableCell(
                            '\$${subItem.price.toStringAsFixed(2)}', tinyStyle),
                        _buildCompactTableCell(
                          '\$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                          pw.TextStyle(
                              font: arabicFont,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 12),

              // ✅ COMPACT Summary Section - Two columns layout
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Payment History
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(6),
                        border:
                            pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Payment History',
                              style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          if (carPart.payments.isEmpty)
                            pw.Text(
                              'No payments yet',
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 7,
                                color: PdfColors.grey600,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            )
                          else
                            ...carPart.payments
                                .take(5)
                                .map((payment) => pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(bottom: 2),
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(
                                              DateFormat('dd/MM/yy')
                                                  .format(payment.date),
                                              style: tinyStyle),
                                          pw.Text(
                                            '\$${payment.amount.toStringAsFixed(2)}',
                                            style: pw.TextStyle(
                                              font: arabicFont,
                                              fontSize: 7,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.green700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                          if (carPart.payments.length > 5)
                            pw.Text(
                              '+ ${carPart.payments.length - 5} more...',
                              style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 6,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  // Right: Totals
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(6),
                        border:
                            pw.Border.all(color: PdfColors.grey400, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildCompactTotalRow(
                              'Subtotal:', totalSellingPrice, tinyStyle,
                              valueColor: PdfColors.grey900),
                          pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                          _buildCompactTotalRow(
                              'Total Paid:', totalPaid, tinyStyle,
                              valueColor: PdfColors.green700),
                          _buildCompactTotalRow(
                              'Amount Owed:', amountOwed, tinyStyle,
                              valueColor: PdfColors.red700),
                          pw.Divider(thickness: 1, color: PdfColors.grey500),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 6, horizontal: 6),
                            decoration: pw.BoxDecoration(
                              color: amountOwed > 0
                                  ? PdfColors.red50
                                  : PdfColors.green50,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: _buildCompactTotalRow(
                              'Balance Due:',
                              amountOwed,
                              pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold),
                              valueColor: amountOwed > 0
                                  ? PdfColors.red900
                                  : PdfColors.green900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ✅ COMPACT Footer
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                ),
                child: pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for your business!',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 6,
                            color: PdfColors.grey600),
                      ),
                    ],
                  ),
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

  // ✅ COMPACT table cell helper
  pw.Widget _buildCompactTableCell(String text, pw.TextStyle style,
      {bool isHeader = false, bool isArabic = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4), // ✅ Reduced padding
      child: pw.Text(
        text,
        style: style,
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      ),
    );
  }

  // ✅ COMPACT total row helper
  pw.Widget _buildCompactTotalRow(
    String label,
    double value,
    pw.TextStyle style, {
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(
            '\$${value.toStringAsFixed(2)}',
            style: style.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

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
  /// Generate PDF report for a single seller with sub-items breakdown
  Future<File> generateSellerPDFReport(
    Seller seller,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();

    // ✅ Load Arabic font
    final arabicFont = await _loadArabicFont();

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
            // Header - ✅ Always English
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    seller.name,
                    style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold),
                    textDirection: _getTextDirection(seller.name),
                  ),
                  pw.Text(
                    '${DateFormat.MMMM().format(DateTime(0, month))} $year Report',
                    style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 16,
                        color: PdfColors.grey700),
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

            content.add(pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Sale Header - ✅ Dynamic car name
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            carPart.name,
                            style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold),
                            textDirection: _getTextDirection(carPart.name),
                          ),
                          if (carPart.description.isNotEmpty)
                            pw.Text(
                              carPart.description,
                              style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 12,
                                  color: PdfColors.grey600),
                              textDirection:
                                  _getTextDirection(carPart.description),
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
                            font: arabicFont,
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

                  // Main Item - ✅ Always English labels
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
                            style:
                                pw.TextStyle(font: arabicFont, fontSize: 10)),
                        pw.Text('\$${carPart.price.toStringAsFixed(2)} each',
                            style:
                                pw.TextStyle(font: arabicFont, fontSize: 10)),
                        pw.Text(
                            'Total: \$${(carPart.price * carPart.quantity).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'Cost: \$${(carPart.purchasePrice ?? 0).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 10,
                                color: PdfColors.orange)),
                      ],
                    ),
                  ),

                  // Sub-Items - ✅ Dynamic per sub-item
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
                                font: arabicFont,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue700),
                          ),
                          pw.SizedBox(height: 4),
                          ...carPart.subItems.map((subItem) => pw.Padding(
                                padding:
                                    const pw.EdgeInsets.only(left: 12, top: 4),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        '• ${subItem.name}',
                                        style: pw.TextStyle(
                                            font: arabicFont, fontSize: 9),
                                        textDirection:
                                            _getTextDirection(subItem.name),
                                      ),
                                    ),
                                    pw.Text('${subItem.quantity}x',
                                        style: pw.TextStyle(
                                            font: arabicFont, fontSize: 9)),
                                    pw.Text(
                                        '\$${subItem.price.toStringAsFixed(2)} each',
                                        style: pw.TextStyle(
                                            font: arabicFont, fontSize: 9)),
                                    pw.Text(
                                        'Total: \$${(subItem.price * subItem.quantity).toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            font: arabicFont,
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold)),
                                    pw.Text(
                                        'Cost: \$${(subItem.purchasePrice ?? 0).toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            font: arabicFont,
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

                  // Sale Summary - ✅ Always English
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItemWithFont('Total Price',
                          totalSellingPrice, PdfColors.black, arabicFont),
                      _buildSummaryItemWithFont('Total Cost', totalPurchaseCost,
                          PdfColors.orange, arabicFont),
                      _buildSummaryItemWithFont(
                          'Total Paid', totalPaid, PdfColors.blue, arabicFont),
                      _buildSummaryItemWithFont(
                          'Owed', carPart.amountOwed, PdfColors.red, arabicFont,
                          bold: true),
                    ],
                  ),
                ],
              ),
            ));
          }

          // Grand Total Summary - ✅ Always English
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
                        font: arabicFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 8),
                  _buildSummaryRowWithFont('Total Selling Price',
                      totalSellingPriceSum, PdfColors.blue, arabicFont),
                  _buildSummaryRowWithFont('Total Purchase Cost',
                      totalPurchaseCostSum, PdfColors.orange, arabicFont),
                  _buildSummaryRowWithFont(
                      'Total Paid', totalPaidSum, PdfColors.blue, arabicFont),
                  _buildSummaryRowWithFont(
                      'Total Owed', totalOwedSum, PdfColors.red, arabicFont),
                  pw.Divider(thickness: 2),
                  _buildSummaryRowWithFont(
                    'Total Actual Gain',
                    totalActualGainSum,
                    totalActualGainSum >= 0 ? PdfColors.green : PdfColors.red,
                    arabicFont,
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
              style: pw.TextStyle(
                  font: arabicFont, fontSize: 10, color: PdfColors.grey),
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

  // ✅ NEW: Helper widgets with font support
  pw.Widget _buildSummaryItemWithFont(
      String label, double value, PdfColor color, pw.Font font,
      {bool bold = false}) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text(
          '\$${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            font: font,
            fontSize: bold ? 11 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRowWithFont(
      String label, double value, PdfColor color, pw.Font font,
      {bool bold = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize - 1,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '\$${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              font: font,
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

    // ✅ Load Arabic font
    final arabicFont = await _loadArabicFont();

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
            // Header - ✅ Always English
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Monthly Sellers Report',
                    style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${DateFormat.MMMM().format(DateTime(0, month))} $year',
                    style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 16,
                        color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            // Summary Cards - ✅ Always English
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatCardWithFont(
                    'Total Selling Price',
                    '\$${totalSellingPriceSum.toStringAsFixed(2)}',
                    PdfColors.blue,
                    arabicFont),
                _buildStatCardWithFont(
                    'Total Cost',
                    '\$${totalCostSum.toStringAsFixed(2)}',
                    PdfColors.orange,
                    arabicFont),
                _buildStatCardWithFont(
                    'Total Gain',
                    '\$${totalGainFromPayments.toStringAsFixed(2)}',
                    totalGainFromPayments >= 0
                        ? PdfColors.green
                        : PdfColors.red,
                    arabicFont),
                _buildStatCardWithFont(
                    'Total Owed',
                    '\$${totalMonthlyOwed.toStringAsFixed(2)}',
                    PdfColors.red,
                    arabicFont),
              ],
            ),

            pw.SizedBox(height: 20),

            // Additional Stats - ✅ Always English
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
                      style: pw.TextStyle(
                          font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total Sales: $totalCarParts',
                      style: pw.TextStyle(
                          font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total Sub-Items: $totalSubItems',
                      style: pw.TextStyle(
                          font: arabicFont, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Sellers Table - ✅ Always English headers
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCellWithFont('Seller', arabicFont,
                        isHeader: true),
                    _buildTableCellWithFont('Selling Price', arabicFont,
                        isHeader: true),
                    _buildTableCellWithFont('Cost', arabicFont, isHeader: true),
                    _buildTableCellWithFont('Gain', arabicFont, isHeader: true),
                    _buildTableCellWithFont('Owed', arabicFont, isHeader: true),
                    _buildTableCellWithFont('Sales', arabicFont,
                        isHeader: true),
                    _buildTableCellWithFont('Sub-Items', arabicFont,
                        isHeader: true),
                  ],
                ),
                // Data Rows - ✅ Dynamic seller names
                ...sellerData.map((data) {
                  final gain = data['gain'] as double;
                  final sellerName = data['name'] as String;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          sellerName,
                          style: pw.TextStyle(font: arabicFont, fontSize: 9),
                          textAlign: pw.TextAlign.center,
                          textDirection: _getTextDirection(sellerName),
                        ),
                      ),
                      _buildTableCellWithFont(
                        '\$${(data['totalSellingPrice'] as double).toStringAsFixed(2)}',
                        arabicFont,
                        textColor: PdfColors.blue,
                      ),
                      _buildTableCellWithFont(
                        '\$${(data['totalCost'] as double).toStringAsFixed(2)}',
                        arabicFont,
                        textColor: PdfColors.orange,
                      ),
                      _buildTableCellWithFont(
                        '\$${gain.toStringAsFixed(2)}',
                        arabicFont,
                        textColor: gain >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                      _buildTableCellWithFont(
                        '\$${(data['monthlyOwed'] as double).toStringAsFixed(2)}',
                        arabicFont,
                        textColor: PdfColors.red,
                      ),
                      _buildTableCellWithFont(
                          '${data['carParts']}', arabicFont),
                      _buildTableCellWithFont(
                          '${data['subItems']}', arabicFont),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer Note - ✅ Always English
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Note: This report includes all sales with their sub-items added in ${DateFormat.MMMM().format(DateTime(0, month))} $year. Gain calculation includes all payments received to date.',
                style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 10,
                    color: PdfColors.grey800,
                    fontStyle: pw.FontStyle.italic),
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                  font: arabicFont, fontSize: 10, color: PdfColors.grey600),
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

  // ✅ NEW: Helper methods with font support
  pw.Widget _buildTableCellWithFont(String text, pw.Font font,
      {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildStatCardWithFont(
      String label, String value, PdfColor color, pw.Font font) {
    // ✅ Create darker version of the color for text
    final darkColor = PdfColor.fromInt(color.toInt() & 0xFF000000 |
        ((color.red * 0.6).toInt() << 16) |
        ((color.green * 0.6).toInt() << 8) |
        (color.blue * 0.6).toInt());

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white, // ✅ White background for better contrast
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey700,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
                font: font,
                fontSize: 16, // ✅ Larger
                fontWeight: pw.FontWeight.bold,
                color: darkColor), // ✅ Darker shade of the original color
          ),
        ],
      ),
    );
  }
}
