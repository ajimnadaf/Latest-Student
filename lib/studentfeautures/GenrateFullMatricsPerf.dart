import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/base/base_activity_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Genratefullmatricsperf extends StatefulWidget {
  final bool clearanceIntent;
  const Genratefullmatricsperf({super.key, this.clearanceIntent = false});

  @override
  State<Genratefullmatricsperf> createState() => _GenratefullmatricsperfState();
}

class _GenratefullmatricsperfState extends State<Genratefullmatricsperf>
    with BaseActivityMixin {
  late WebViewController _controller;
  String htmlPath = '';

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    htmlPath = widget.clearanceIntent
        ? await generateClearanceHtml()
        : await generateMarksHtml();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..loadFile(htmlPath);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String> generateMarksHtml() async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir!.path}/TrueGuide/Reports/marks_cards';
    await Directory(path).create(recursive: true);

    final file = File('$path/Marks.html');
    final html = buildMarksHtml();
    await file.writeAsString(html);
    return file.path;
  }

  Future<String> generateClearanceHtml() async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir!.path}/TrueGuide/Reports/Clearance';
    await Directory(path).create(recursive: true);

    final file = File('$path/Clearance_form.html');
    await file.writeAsString("""
<html>
<body bgcolor="#F2F2F2">
<h2>Student Clearance Form</h2>
<p>Name : ${Glb.student_name}</p>
<p>Roll No : ${Glb.roll_no}</p>
<p>Class : ${Glb.sec_id}</p>
</body>
</html>
""");
    return file.path;
  }

  String buildMarksHtml() {
    Glb.sub_marks_legend.clear();

    final allSubs = <String>{};
    Glb.all_ex_sub_map.values
        .forEach((l) => allSubs.addAll(l.map((e) => e.toString())));

    Map<String, double> examTotals = {};
    Map<String, int> examCounts = {};

    Glb.all_ex_sub_map.forEach((exam, subs) {
      double total = 0;
      int count = 0;

      for (var i = 0; i < subs.length; i++) {
        final obt = Glb.all_ex_obt_map[exam]![i];
        final tot = Glb.all_ex_tot_map[exam]![i];

        double obtVal = double.tryParse(obt.toString()) ?? 0;
        double totVal = double.tryParse(tot.toString()) ?? 1;

        if (obtVal > 0) {
          total += (obtVal * 100) / totVal;
          count++;
        }
      }

      examTotals[exam] = total;
      examCounts[exam] = count == 0 ? 1 : count;
    });

    String html = """
<html>
<head>

<!-- Updated Chart.js to CDN for WebView compatibility -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
body {
  font-family: Arial;
}
canvas {
  width: 100% !important;
  height: 320px !important;
}
</style>

</head>

<body bgcolor="#D4E6F1">

<h3>Student Name : ${Glb.student_name}</h3>
<p>Roll Number : ${Glb.roll_no ?? "NA"}</p>
<p>Class : ${Glb.sec_id ?? "NA"}</p>

<table border="1" width="1000" style="border-collapse: collapse;">
<tr>
<th>Exams/Subject</th>
""";

    Glb.all_ex_sub_map.keys.forEach((e) {
      html += "<th>$e</th>";
    });

    html += "<th>ALL</th></tr>";

    for (final sub in allSubs) {
      html += "<tr><th>$sub</th>";
      double totalPerSub = 0;
      int subCount = 0;

      Glb.all_ex_sub_map.forEach((exam, subs) {
        final idx = subs.indexOf(sub);
        if (idx == -1) {
          html += "<td>NA</td>";
        } else {
          final obt = Glb.all_ex_obt_map[exam]![idx];
          final tot = Glb.all_ex_tot_map[exam]![idx];

          double obtVal = double.tryParse(obt.toString()) ?? 0;
          double totVal = double.tryParse(tot.toString()) ?? 1;
          double per = (obtVal * 100) / totVal;

          html +=
              "<td>${per.toStringAsFixed(2)}% (${obtVal.toInt()}/${totVal.toInt()})</td>";
          totalPerSub += per;
          subCount++;
        }
      });

      html +=
          "<td>${(subCount == 0 ? 0 : totalPerSub / subCount).toStringAsFixed(2)}%</td></tr>";
    }

    html += "<tr style='font-weight:bold;'><td>TOTAL</td>";

    Glb.all_ex_sub_map.keys.forEach((exam) {
      final avg = examTotals[exam]! / examCounts[exam]!;
      html += "<td>${avg.toStringAsFixed(2)}%</td>";
    });

    double overall = 0;
    examTotals.forEach((k, v) {
      overall += v / examCounts[k]!;
    });

    html +=
        "<td>${(overall / examTotals.length).toStringAsFixed(2)}%</td></tr>";
    html += "</table><br>";

    final List<String> lineDatasets = [];

    for (final sub in allSubs) {
      lineDatasets.add("""
{
  label: "$sub",
  data: ${jsonEncode(
        Glb.all_ex_sub_map.keys.map((exam) {
          final idx = Glb.all_ex_sub_map[exam]!.indexOf(sub);
          if (idx == -1) return 0;
          final obt = Glb.all_ex_obt_map[exam]![idx];
          final tot = Glb.all_ex_tot_map[exam]![idx];
          double obtVal = double.tryParse(obt.toString()) ?? 0;
          double totVal = double.tryParse(tot.toString()) ?? 1;
          return double.parse(((obtVal * 100) / totVal).toStringAsFixed(2));
        }).toList(),
      )},
  fill: false,
  tension: 0.2
}
""");
    }

    html += """
<h4>Aggregate Exam Performance</h4>
<canvas id="barChart"></canvas>

<h4>Company Performance</h4>
<canvas id="lineChart"></canvas>

<script>

new Chart(document.getElementById('barChart').getContext('2d'), {
  type: 'bar',
  data: {
    labels: ${jsonEncode(Glb.all_ex_sub_map.keys.toList())},
    datasets: [{
      label: 'Aggregate Performance',
      data: ${jsonEncode(
      Glb.all_ex_sub_map.keys
          .map((e) => double.parse(
              (examTotals[e]! / examCounts[e]!).toStringAsFixed(2)))
          .toList(),
    )},
      backgroundColor: 'rgba(54, 162, 235, 0.7)'
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      y: { beginAtZero: true }
    }
  }
});

new Chart(document.getElementById('lineChart').getContext('2d'), {
  type: 'line',
  data: {
    labels: ${jsonEncode(Glb.all_ex_sub_map.keys.toList())},
    datasets: [
      ${lineDatasets.join(",")}
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      y: { beginAtZero: true }
    }
  }
});

</script>

</body>
</html>
""";

    return html;
  }

  Future<void> _convertToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final allSubs = <String>{};
          Glb.all_ex_sub_map.values
              .forEach((l) => allSubs.addAll(l.map((e) => e.toString())));

          Map<String, double> examTotals = {};
          Map<String, int> examCounts = {};

          Glb.all_ex_sub_map.forEach((exam, subs) {
            double total = 0;
            int count = 0;
            for (var i = 0; i < subs.length; i++) {
              final obt = Glb.all_ex_obt_map[exam]![i];
              final tot = Glb.all_ex_tot_map[exam]![i];
              double obtVal = double.tryParse(obt.toString()) ?? 0;
              double totVal = double.tryParse(tot.toString()) ?? 1;
              if (obtVal > 0) {
                total += (obtVal * 100) / totVal;
                count++;
              }
            }
            examTotals[exam] = total;
            examCounts[exam] = count == 0 ? 1 : count;
          });

          List<pw.TableRow> rows = [];

          rows.add(pw.TableRow(
              children: [pw.Text("Exams/Subject")] +
                  Glb.all_ex_sub_map.keys.map((e) => pw.Text(e)).toList() +
                  [pw.Text("ALL")]));

          for (final sub in allSubs) {
            List<pw.Widget> cells = [pw.Text(sub)];
            double totalPerSub = 0;
            int subCount = 0;

            Glb.all_ex_sub_map.forEach((exam, subs) {
              final idx = subs.indexOf(sub);
              if (idx == -1) {
                cells.add(pw.Text("NA"));
              } else {
                final obt = Glb.all_ex_obt_map[exam]![idx];
                final tot = Glb.all_ex_tot_map[exam]![idx];

                double obtVal = double.tryParse(obt.toString()) ?? 0;
                double totVal = double.tryParse(tot.toString()) ?? 1;
                double per = (obtVal * 100) / totVal;

                cells.add(pw.Text(
                    "${per.toStringAsFixed(2)}% (${obtVal.toInt()}/${totVal.toInt()})"));
                totalPerSub += per;
                subCount++;
              }
            });

            cells.add(pw.Text((subCount == 0 ? 0 : totalPerSub / subCount)
                    .toStringAsFixed(2) +
                "%"));
            rows.add(pw.TableRow(children: cells));
          }

          // TOTAL ROW
          List<pw.Widget> totalCells = [pw.Text("TOTAL")];
          Glb.all_ex_sub_map.keys.forEach((exam) {
            final avg = examTotals[exam]! / examCounts[exam]!;
            totalCells.add(pw.Text(avg.toStringAsFixed(2) + "%"));
          });
          double overall = 0;
          examTotals.forEach((k, v) {
            overall += v / examCounts[k]!;
          });
          totalCells.add(
              pw.Text((overall / examTotals.length).toStringAsFixed(2) + "%"));
          rows.add(pw.TableRow(children: totalCells));

          return [
            pw.Text("Student Name: ${Glb.student_name}",
                style: pw.TextStyle(fontSize: 16)),
            pw.Text("Roll Number: ${Glb.roll_no ?? "NA"}"),
            pw.Text("Class: ${Glb.sec_id ?? "NA"}"),
            pw.SizedBox(height: 20),
            pw.Table(
                border: pw.TableBorder.all(),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: rows)
          ];
        },
      ),
    );

    final dir = await getExternalStorageDirectory();
    final pdfPath = '${dir!.path}/TrueGuide/Reports/marks_cards/Marks.pdf';
    final file = File(pdfPath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("PDF Generated at $pdfPath")));

    // Open share dialog
    await Share.shareXFiles([XFile(pdfPath)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clearanceIntent
            ? "Clearance Form"
            : "Consolidated Marks Report"),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "shareHtml",
            child: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles([XFile(htmlPath)]),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "pdfDownload",
            child: const Icon(Icons.picture_as_pdf),
            onPressed: _convertToPdf,
          ),
        ],
      ),
      body: htmlPath.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
