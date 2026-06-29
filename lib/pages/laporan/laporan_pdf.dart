import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Helper untuk generate & cetak PDF laporan servis.
/// Dipakai bersama oleh LaporanServisPage dan RiwayatServisPage.
class LaporanPdfHelper {

  /// Cetak Laporan Servis & Transaksi (data yang sudah Lunas).
  /// Hanya berisi tabel transaksi — kotak ringkasan (Total Transaksi,
  /// Pendapatan, Kendaraan) sengaja TIDAK ikut dicetak di PDF.
  static Future<void> cetakLaporanServis({
    required List<Map<String, dynamic>> rows,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    final pdf = pw.Document();

    final rentangText = _formatRentangTanggal(tanggalAwal, tanggalAkhir);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _buildHeader(
          "LAPORAN SERVIS & TRANSAKSI",
          rentangText,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 12),

          pw.Table.fromTextArray(
            headers: const [
              "NO",
              "TANGGAL",
              "NO. SPK",
              "NAMA PELANGGAN",
              "NAMA MONTIR",
              "KENDARAAN",
              "TOTAL BIAYA",
            ],
            data: List.generate(rows.length, (i) {
              final r = rows[i];
              return [
                "${i + 1}",
                r['tanggal'] ?? '-',
                r['no_spk'] ?? '-',
                r['nama_pelanggan'] ?? '-',
                r['nama_montir'] ?? '-',
                r['kendaraan'] ?? '-',
                r['total_biaya'] ?? '-',
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.center},
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'laporan_servis_transaksi.pdf',
    );
  }

  /// Cetak Riwayat Servis Pelanggan (semua data, tanpa kolom NO SPK).
  static Future<void> cetakRiwayatServis({
    required List<Map<String, dynamic>> rows,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    final pdf = pw.Document();

    final rentangText = _formatRentangTanggal(tanggalAwal, tanggalAkhir);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _buildHeader(
          "RIWAYAT SERVIS PELANGGAN",
          rentangText,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: const [
              "NO",
              "TANGGAL",
              "NAMA PELANGGAN",
              "KENDARAAN",
              "NAMA MONTIR",
              "STATUS",
              "TOTAL BIAYA",
            ],
            data: List.generate(rows.length, (i) {
              final r = rows[i];
              return [
                "${i + 1}",
                r['tanggal'] ?? '-',
                r['nama_pelanggan'] ?? '-',
                r['kendaraan'] ?? '-',
                r['nama_montir'] ?? '-',
                r['status'] ?? '-',
                r['total_biaya'] ?? '-',
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.center},
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'riwayat_servis_pelanggan.pdf',
    );
  }

  // ================= HELPER UI PDF =================

  static pw.Widget _buildHeader(String title, String rentangText) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "JIMU MITSUBISHI",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  title,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "Dicetak: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}",
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.Text(
                  "Periode: $rentangText",
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey400, thickness: 1),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        "Halaman ${context.pageNumber} dari ${context.pagesCount}",
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }

  static String _formatRentangTanggal(DateTime? awal, DateTime? akhir) {
    final fmt = DateFormat('dd MMM yyyy');
    if (awal == null && akhir == null) return "Semua Data";
    if (awal != null && akhir != null) {
      return "${fmt.format(awal)} - ${fmt.format(akhir)}";
    }
    if (awal != null) return "Mulai ${fmt.format(awal)}";
    return "Sampai ${fmt.format(akhir!)}";
  }
}