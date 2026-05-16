import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';
import '../../models/billing_overview_model.dart';

class InvoiceViewerScreen extends StatelessWidget {
  final Transaction transaction;

  const InvoiceViewerScreen({super.key, required this.transaction});

  Future<void> _handleDownload(BuildContext context) async {
    try {
      // 1. Show Loading Indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              SizedBox(width: 16),
              const Text('Preparing Invoice PDF...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF1E1B4B),
        ),
      );

      // 2. Request Permissions (Android)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          if (await Permission.manageExternalStorage.request().isDenied) {
             throw 'Storage permission denied';
          }
        }
      }

      // 3. Load Unicode Font (Supports ₹ symbol)
      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();
      final fontItalic = await PdfGoogleFonts.notoSansItalic();

      // 4. Generate PDF Document
      final doc = pw.Document(
        title: 'Invoice-${transaction.invoiceNumber ?? transaction.id}',
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
      );
      
      final subtotal = transaction.amount / 1.18;
      final tax = transaction.amount - subtotal;
      
      final navyBlue = PdfColor.fromHex('#1E1B4B');
      final accentOrange = PdfColor.fromHex('#F59E0B');
      final logoOrange = PdfColor.fromHex('#C2410C');
      final logoGreen = PdfColor.fromHex('#16A34A');
      final logoBlue = PdfColor.fromHex('#1E3A8A');
      final successGreen = PdfColor.fromHex('#10B981');

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(height: 4, width: double.infinity, color: accentOrange),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('MIND', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: logoOrange)),
                            pw.Text('WARE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: logoGreen)),
                          ],
                        ),
                        pw.Text('INFOTECH', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: logoBlue, letterSpacing: 3)),
                        pw.SizedBox(height: 10),
                        pw.Text('Mindware Infotech', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text(
                          'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nDwarka, Delhi 110078\nsales@mindwareinfotech.com | +91-8527522688\nGST: 07AFDPM9463K1ZY',
                          style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: 'https://mindwareinfotech.com/invoice/${transaction.id}',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: navyBlue)),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(color: successGreen, borderRadius: pw.BorderRadius.circular(2)),
                          child: pw.Text('COMPLETED', style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 14),
                pw.Divider(thickness: 1, color: navyBlue),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    _pdfGridItem('Invoice', transaction.invoiceNumber ?? '—', navyBlue),
                    _pdfGridItem('Date & Time', _formatDate(transaction.createdAt), navyBlue),
                    _pdfGridItem('Payment ID', transaction.gatewayPaymentId ?? '—', navyBlue),
                    _pdfGridItem('Gateway', transaction.gateway?.toUpperCase() ?? '—', navyBlue),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: navyBlue),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(border: pw.Border.all(color: navyBlue, width: 0.5)),
                        child: _pdfAddress('FROM', 'Mindware Infotech', 'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nDwarka, Delhi 110078\nsales@mindwareinfotech.com\n+91-8527522688\nGST: 07AFDPM9463K1ZY', accentOrange),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(color: navyBlue, width: 0.5),
                            bottom: pw.BorderSide(color: navyBlue, width: 0.5),
                            right: pw.BorderSide(color: navyBlue, width: 0.5),
                          ),
                        ),
                        child: _pdfAddress('BILLED TO', 'Mindware info tech', 'Village: Karri-khurd, Post: Konar Dam, Dist: Bokaro\nBokaro, Jharkhand 825315\nsanjaycling123@gmail.com', successGreen),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 28),
                pw.Table(
                  border: pw.TableBorder.all(color: navyBlue, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(12),
                    1: const pw.FlexColumnWidth(5),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FlexColumnWidth(6),
                    4: const pw.FlexColumnWidth(6),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: navyBlue),
                      children: [
                        _pdfHeaderCell('Description'),
                        _pdfHeaderCell('Cycle', center: true),
                        _pdfHeaderCell('Qty', center: true),
                        _pdfHeaderCell('Unit', center: true),
                        _pdfHeaderCell('Total', right: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell(transaction.title, isBold: true),
                        _pdfCell(transaction.billingCycle ?? '—', center: true),
                        _pdfCell('1', center: true),
                        _pdfCell('\u20B9 ${(transaction.amount / 1.18).toStringAsFixed(2)}', center: true),
                        _pdfCell('\u20B9 ${(transaction.amount / 1.18).toStringAsFixed(2)}', isBold: true, right: true),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 150,
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: navyBlue, width: 0.5)),
                    child: pw.Column(
                      children: [
                        _pdfTotalRow('Subtotal', '\u20B9 ${subtotal.toStringAsFixed(2)}', navyBlue),
                        _pdfTotalRow('Tax (18%)', '\u20B9 ${tax.toStringAsFixed(2)}', navyBlue),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('GRAND TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: navyBlue)),
                              pw.Text('\u20B9 ${transaction.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: logoBlue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text('Terms & Conditions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.SizedBox(height: 4),
                pw.Text('Payment is due immediately on receipt of this invoice. Late payments may be charged as per applicable laws.', style: const pw.TextStyle(fontSize: 7.5)),
                pw.Spacer(),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 8),
                pw.Text('This is a system generated invoice. No signature required.\nThank you for choosing Mindware Infotech.', style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 20),
                pw.Container(height: 4, width: double.infinity, color: PdfColor.fromHex('#059669')),
              ],
            );
          },
        ),
      );

      // 5. Save and Open File
      final bytes = await doc.save();
      final fileName = 'Invoice-${transaction.invoiceNumber ?? transaction.id}.pdf';
      
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(bytes);

      // 5. Success Feedback and Open
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice downloaded successfully', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
        ),
      );

      await OpenFilex.open(file.path);

    } catch (e) {
      debugPrint('PDF Error: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _pdfGridItem(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        height: 35,
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: color, width: 0.5)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: color)),
            pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfAddress(String title, String name, String addr, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: color)),
        pw.SizedBox(height: 5),
        pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.SizedBox(height: 3),
        pw.Text(addr, style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 1.5)),
      ],
    );
  }

  pw.Widget _pdfHeaderCell(String text, {bool center = false, bool right = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8.5),
        textAlign: center ? pw.TextAlign.center : (right ? pw.TextAlign.right : pw.TextAlign.left),
      ),
    );
  }

  pw.Widget _pdfCell(String text, {bool isBold = false, bool center = false, bool right = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        textAlign: center ? pw.TextAlign.center : (right ? pw.TextAlign.right : pw.TextAlign.left),
      ),
    );
  }

  pw.Widget _pdfTotalRow(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: color, width: 0.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = transaction.amount / 1.18;
    final tax = transaction.amount - subtotal;
    const navyBlue = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: const Text('Invoice Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 4, width: double.infinity, color: const Color(0xFFF59E0B)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('MIND', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange.shade700, letterSpacing: -0.8)),
                                        Text('WARE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green.shade600, letterSpacing: -0.8)),
                                      ],
                                    ),
                                    Text('INFOTECH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blue.shade900, letterSpacing: 3)),
                                    const SizedBox(height: 10),
                                    const Text('Mindware Infotech', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nDwarka, Delhi 110078\nsales@mindwareinfotech.com | +91-8527522688\nGST: 07AFDPM9463K1ZY',
                                      style: TextStyle(fontSize: 7.5, color: Colors.black.withOpacity(0.8), height: 1.3, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.2), borderRadius: BorderRadius.circular(3)),
                                      child: const Icon(LucideIcons.qrCode, size: 48),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('INVOICE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navyBlue, letterSpacing: 0.2)),
                                    const SizedBox(height: 3),
                                    const StatusBadge(status: 'COMPLETED'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(thickness: 1.2, color: navyBlue),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildGridItem('Invoice', transaction.invoiceNumber ?? '—', navyBlue),
                                _buildGridItem('Date & Time', _formatDate(transaction.createdAt), navyBlue),
                                _buildGridItem('Payment ID', transaction.gatewayPaymentId ?? '—', navyBlue),
                                _buildGridItem('Gateway', transaction.gateway?.toUpperCase() ?? '—', navyBlue),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 1.2, color: navyBlue),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(border: Border.all(color: navyBlue, width: 0.8)),
                                    child: _buildAddressBlock('FROM', 'Mindware Infotech', 'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nDwarka, Delhi 110078\nsales@mindwareinfotech.com\n+91-8527522688\nGST: 07AFDPM9463K1ZY', const Color(0xFFF59E0B)),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: navyBlue, width: 0.8),
                                        bottom: BorderSide(color: navyBlue, width: 0.8),
                                        right: BorderSide(color: navyBlue, width: 0.8),
                                      ),
                                    ),
                                    child: _buildAddressBlock('BILLED TO', 'Mindware info tech', 'Village: Karri-khurd, Post: Konar Dam, Dist: Bokaro\nBokaro, Jharkhand 825315\nsanjaycling123@gmail.com', const Color(0xFF10B981)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _buildDataTable(transaction, navyBlue),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 180,
                                decoration: BoxDecoration(border: Border.all(color: navyBlue, width: 0.8)),
                                child: Column(
                                  children: [
                                    _buildTotalRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', navyBlue),
                                    _buildTotalRow('Tax (18%)', '₹${tax.toStringAsFixed(2)}', navyBlue),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8.5, color: navyBlue)),
                                          Text('₹${transaction.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF1E3A8A))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black)),
                            const SizedBox(height: 4),
                            const Text('Payment is due immediately on receipt of this invoice. Late payments may be charged as per applicable laws.', style: TextStyle(fontSize: 7.5, color: Colors.black54, height: 1.3, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 35),
                            const Divider(height: 1, thickness: 0.8),
                            const SizedBox(height: 8),
                            const Text('This is a system generated invoice. No signature required.\nThank you for choosing Mindware Infotech.', style: TextStyle(fontSize: 7, color: Colors.black45, fontStyle: FontStyle.italic, height: 1.3, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Container(height: 4, width: double.infinity, color: const Color(0xFF059669)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleDownload(context),
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text('Download Invoice (PDF)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF05234),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Go to Subscription', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.4), width: 0.6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.black, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressBlock(String title, String name, String address, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: accentColor)),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E1B4B))),
        const SizedBox(height: 3),
        Text(address, style: const TextStyle(fontSize: 7.5, height: 1.3, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDataTable(Transaction transaction, Color color) {
    return Column(
      children: [
        Container(
          color: color,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: const Row(
            children: [
              Expanded(flex: 12, child: Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5))),
              Expanded(flex: 5, child: Text('Cycle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5), textAlign: TextAlign.center)),
              Expanded(flex: 3, child: Text('Qty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5), textAlign: TextAlign.center)),
              Expanded(flex: 6, child: Text('Unit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5), textAlign: TextAlign.center)),
              Expanded(flex: 6, child: Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5), textAlign: TextAlign.right)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all(color: color, width: 0.8)),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(flex: 12, child: _cell(transaction.title, isBold: true)),
                _vDiv(color),
                Expanded(flex: 5, child: _cell(transaction.billingCycle ?? '—', center: true)),
                _vDiv(color),
                Expanded(flex: 3, child: _cell('1', center: true)),
                _vDiv(color),
                Expanded(flex: 6, child: _cell('₹${(transaction.amount / 1.18).toStringAsFixed(2)}', center: true)),
                _vDiv(color),
                Expanded(flex: 6, child: _cell('₹${(transaction.amount / 1.18).toStringAsFixed(2)}', isBold: true, right: true)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, {bool isBold = false, bool center = false, bool right = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 8, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: Colors.black),
        textAlign: center ? TextAlign.center : (right ? TextAlign.right : TextAlign.left),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _vDiv(Color color) => VerticalDivider(width: 0.8, thickness: 0.8, color: color);

  Widget _buildTotalRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 0.8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black)),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) { return dateStr; }
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.4),
      ),
    );
  }
}
