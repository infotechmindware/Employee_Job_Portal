import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();
    
    // Define PDF colors matching the brand
    final brandBlue = PdfColor.fromHex('#13489C');
    final borderBlue = PdfColor.fromHex('#2F3E9E');
    final statusGreen = PdfColor.fromHex('#16a34a');
    final brandOrange = PdfColor.fromHex('#EC7E2B');
    final brandGreen = PdfColor.fromHex('#7AB33D');
    final textColor = PdfColor.fromHex('#333333');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                        pw.RichText(
                          text: pw.TextSpan(
                            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                            children: [
                              pw.TextSpan(text: 'MIND', style: pw.TextStyle(color: brandOrange)),
                              pw.TextSpan(text: 'WARE', style: pw.TextStyle(color: brandGreen)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 55),
                          child: pw.Text('INFOTECH', maxLines: 1, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandBlue, letterSpacing: 2)),
                        ),
                      ],
                    ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Mindware Infotech', maxLines: 1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: brandBlue)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nsales@mindwareinfotech.com | +91-9527522630\nGST: 07A7FDFM8463K1ZY',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 9, color: brandBlue),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                        pw.Container(
                          width: 100,
                          height: 100,
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderBlue)),
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: 'https://mindware.com/invoice/${invoice['id']}',
                            width: 100,
                            height: 100,
                            color: brandBlue,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brandBlue)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: pw.BoxDecoration(color: statusGreen, borderRadius: pw.BorderRadius.circular(2)),
                          child: pw.Text('COMPLETED', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 40),
              // Summary Box
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderBlue), borderRadius: pw.BorderRadius.circular(2)),
                child: pw.Row(
                  children: [
                    _buildPdfSummaryItem('Invoice', invoice['id'], textColor, borderBlue),
                    _buildPdfSummaryItem('Date & Time', DateFormat('dd MMM 2026, hh:mm AM').format(invoice['date']), textColor, borderBlue),
                    _buildPdfSummaryItem('Payment ID', 'pay_Sk3lwJxagmki83', textColor, borderBlue),
                    _buildPdfSummaryItem('Gateway', 'RAZORPAY', textColor, borderBlue, isLast: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),
              // Billing info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderBlue)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FROM', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandOrange)),
                          pw.SizedBox(height: 6),
                          pw.Text('Mindware Infotech', maxLines: 1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: brandBlue)),
                          pw.Text('Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nGST: 07A7FDFM8463K1ZY', style: pw.TextStyle(fontSize: 9, color: textColor)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderBlue)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('BILLED TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: statusGreen)),
                          pw.SizedBox(height: 6),
                          pw.Text('Mindware info tech', maxLines: 1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: brandBlue)),
                          pw.SizedBox(height: 12),
                          pw.Text('sajeet2@gmail.com', style: pw.TextStyle(fontSize: 9, color: textColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              // Table
              pw.Table(
                border: pw.TableBorder.all(color: borderBlue),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfTableCell('Description', textColor, isHeader: true),
                      _buildPdfTableCell('Cycle', textColor, isHeader: true),
                      _buildPdfTableCell('Qty', textColor, isHeader: true),
                      _buildPdfTableCell('Unit', textColor, isHeader: true),
                      _buildPdfTableCell('Total', textColor, isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Subscription - Premium', textColor),
                      _buildPdfTableCell('Monthly', textColor),
                      _buildPdfTableCell('1', textColor),
                      _buildPdfTableCell('₹850.00', textColor),
                      _buildPdfTableCell('₹850.00', textColor),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderBlue),
                      children: [
                        _buildPdfTotalTableRow('Subtotal', '₹850.00', textColor),
                        _buildPdfTotalTableRow('Tax (18%)', '₹153.00', textColor),
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F7FB')),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('GRAND TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: brandBlue)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('₹1,003.00', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: brandBlue)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Terms & Conditions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: textColor)),
              pw.Text('Payment is due immediately on receipt of this invoice. Late payments may be charged as per applicable laws.', style: pw.TextStyle(fontSize: 8, color: textColor)),
              pw.Spacer(),
              pw.Divider(color: borderBlue),
              pw.SizedBox(height: 8),
              pw.Text('This is a system generated invoice. No signature required.', style: pw.TextStyle(fontSize: 8, color: textColor)),
              pw.Text('Thank you for choosing Mindware Infotech', style: pw.TextStyle(fontSize: 8, color: textColor)),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.TableRow _buildPdfTotalTableRow(String label, String value, PdfColor textColor) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 9, color: textColor)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textColor)),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSummaryItem(String label, String value, PdfColor textColor, PdfColor borderColor, {bool isLast = false}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: isLast ? null : pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: borderColor))),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 7, color: textColor)),
            pw.SizedBox(height: 2),
            pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, PdfColor textColor, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  // --- FLUTTER UI LOGIC ---

  static const _brandBlue = Color(0xFF13489C);
  static const _borderBlue = Color(0xFF2F3E9E);
  static const _statusGreen = Color(0xFF16A34A);
  static const _brandOrange = Color(0xFFEC7E2B);
  static const _brandGreen = Color(0xFF7AB33D);
  static const _textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Invoice #${invoice['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: 850, // FIXED WIDTH LIKE A PDF PAGE
                  padding: const EdgeInsets.all(40),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 50),
                      _buildInvoiceSummary(),
                      const SizedBox(height: 40),
                      _buildBillingSection(),
                      const SizedBox(height: 40),
                      _buildItemsTable(),
                      const SizedBox(height: 30),
                      _buildTotalsSection(),
                      const SizedBox(height: 50),
                      _buildTermsAndFooter(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  children: [
                    TextSpan(text: 'MIND', style: TextStyle(color: _brandOrange)),
                    TextSpan(text: 'WARE', style: TextStyle(color: _brandGreen)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 65),
                child: const Text('INFOTECH', maxLines: 1, softWrap: false, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _brandBlue, letterSpacing: 3)),
              ),
            ],
          ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Mindware Infotech', maxLines: 1, softWrap: false, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _brandBlue)),
              const SizedBox(height: 4),
              const Text(
                'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\nsales@mindwareinfotech.com | +91-9527522630\nGST: 07A7FDFM8463K1ZY',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: _brandBlue, height: 1.4),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: _borderBlue), borderRadius: BorderRadius.circular(4)),
                child: const Icon(LucideIcons.qrCode, size: 100, color: _brandBlue),
              ),
              const SizedBox(height: 16),
              const Text('INVOICE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _brandBlue)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: _statusGreen, borderRadius: BorderRadius.circular(2)),
                child: const Text('COMPLETED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInvoiceSummary() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: _borderBlue)),
      child: Row(
        children: [
          _buildSummaryBox('Invoice', invoice['id'], true),
          _buildSummaryBox('Date & Time', DateFormat('dd MMM 2026, 04:47 AM').format(invoice['date']), true),
          _buildSummaryBox('Payment ID', 'pay_Sk3lwJxagmki83', true),
          _buildSummaryBox('Gateway', 'RAZORPAY', false),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, bool hasBorder) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(border: hasBorder ? const Border(right: BorderSide(color: _borderBlue)) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: _textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingSection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildBillingBox('FROM', 'Mindware Infotech', 'Mindware, S-4, Pankaj Plaza, Pocket-7, Plot-7,\nDwarka Sector-12, Delhi-110078\n+91-9527522630\nGST: 07A7FDFM8463K1ZY', _brandOrange)),
          const SizedBox(width: 24),
          Expanded(child: _buildBillingBox('BILLED TO', 'Mindware info tech', '\nsajeet2@gmail.com', _statusGreen)),
        ],
      ),
    );
  }

  Widget _buildBillingBox(String tag, String name, String details, Color tagColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: _borderBlue)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor)),
          const SizedBox(height: 8),
          Text(name, maxLines: 1, softWrap: false, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _brandBlue)),
          const SizedBox(height: 4),
          Text(details, style: const TextStyle(fontSize: 11, color: _textColor, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: _borderBlue),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
      },
      children: [
        const TableRow(
          children: [
            _TableCell('Description', isHeader: true),
            _TableCell('Cycle', isHeader: true),
            _TableCell('Qty', isHeader: true),
            _TableCell('Unit', isHeader: true),
            _TableCell('Total', isHeader: true),
          ],
        ),
        TableRow(
          children: [
            const _TableCell('Subscription - Premium'),
            const _TableCell('Monthly'),
            const _TableCell('1'),
            _TableCell('₹${invoice['amount'].toStringAsFixed(2)}'),
            _TableCell('₹${invoice['amount'].toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 280,
          decoration: BoxDecoration(border: Border.all(color: _borderBlue)),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', '₹${invoice['amount'].toStringAsFixed(2)}'),
              _buildTotalRow('Tax (18%)', '₹${(invoice['amount'] * 0.18).toStringAsFixed(2)}'),
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF5F7FB),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.w900, color: _brandBlue, fontSize: 12)),
                    Text('₹${(invoice['amount'] * 1.18).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: _brandBlue, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _textColor, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textColor)),
        ],
      ),
    );
  }

  Widget _buildTermsAndFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Terms & Conditions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 6),
        const Text('Payment is due immediately on receipt of this invoice. Late payments may be charged as per applicable laws.', style: TextStyle(fontSize: 11, color: _textColor)),
        const SizedBox(height: 60),
        const Divider(color: _borderBlue),
        const SizedBox(height: 8),
        const Text('This is a system generated invoice. No signature required.', style: TextStyle(fontSize: 10, color: _textColor)),
        const Text('Thank you for choosing Mindware Infotech', style: TextStyle(fontSize: 10, color: _textColor)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _handleDirectDownload(context),
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _handlePrint(context),
          icon: const Icon(LucideIcons.printer, size: 16),
          label: const Text('Print Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _textColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDirectDownload(BuildContext context) async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: 'Invoice_${invoice['id']}.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  Future<void> _handlePrint(BuildContext context) async {
    try {
      final pdf = await _buildPdfDocument();
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Invoice_${invoice['id']}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print failed: $e')));
      }
    }
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}
