import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/task_model.dart';

class PdfService {
  // Helper to map our severity strings to PDF colors
  static PdfColor _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return PdfColors.red700;
      case 'high': return PdfColors.orange800;
      case 'medium': return PdfColors.amber700;
      default: return PdfColors.blue600;
    }
  }

  static Future<void> generateAndShareIncidentReport(TaskModel task) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('OpsBoard', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                    pw.SizedBox(height: 4),
                    pw.Text('OFFICIAL INCIDENT REPORT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                  ],
                ),
                pw.Text(
                  'Generated: ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Divider(thickness: 2, color: PdfColors.blueGrey900),
            pw.SizedBox(height: 20),

            // --- INCIDENT METADATA ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(task.title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _getSeverityColor(task.severity),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    task.severity.toUpperCase(),
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Details Grid
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetaColumn('STATUS', task.status),
                  _buildMetaColumn('ASSIGNED TO', task.assignee),
                  // --- FIX: Safely replace the UI bullet point with a hyphen for the PDF! ---
                  _buildMetaColumn('LOGGED ON', task.formattedDate.replaceAll('•', '-')),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // --- DESCRIPTION ---
            pw.Text('Description', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.SizedBox(height: 8),
            pw.Text(task.description, style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5)),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // --- ACTIVITY LOG (COMMENTS) ---
            pw.Text('Activity Log', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.SizedBox(height: 12),
            if (task.comments.isEmpty)
              pw.Text('No updates or notes recorded.', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic))
            else
              ...task.comments.map((rawComment) {
                // Bulletproof null checks
                if (rawComment == null || rawComment is! Map) return pw.SizedBox.shrink();
                final comment = rawComment as Map<String, dynamic>;

                final author = comment['authorName']?.toString() ?? comment['authorEmail']?.toString().split('@')[0] ?? 'Unknown';
                final text = comment['text']?.toString() ?? '[Deleted Message]';

                String prettyTime = '';
                if (comment['timestamp'] != null) {
                  try {
                    final stamp = DateTime.parse(comment['timestamp'].toString());
                    prettyTime = "${stamp.month}/${stamp.day} - ${stamp.hour}:${stamp.minute.toString().padLeft(2, '0')}";
                  } catch (e) {
                    prettyTime = 'Unknown Time';
                  }
                }

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(author, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                              pw.Text(prettyTime, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            ]
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
                      ]
                  ),
                );
              }),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();

    // Create a safe filename without spaces
    final safeTitle = task.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'OpsBoard_Incident_$safeTitle.pdf',
    );
  }

  static pw.Widget _buildMetaColumn(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
      ],
    );
  }
}