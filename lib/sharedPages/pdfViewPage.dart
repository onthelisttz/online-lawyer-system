import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Represents PDFScreen for Navigation
class PDFScreen extends StatefulWidget {
  String? pdf;
  PDFScreen({super.key, required this.pdf});
  @override
  _PDFScreen createState() => _PDFScreen();
}

class _PDFScreen extends State<PDFScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF009999),
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Lawyer Document',
              style: TextStyle(
                  fontSize: 17, letterSpacing: 2, color: Colors.white),
            ),
          ),
          elevation: 0,
        ),
        // body: Text(widget.pdf.toString()),
        body: widget.pdf.toString() != null
            ? SfPdfViewer.network(
                widget.pdf.toString(),
                key: _pdfViewerKey,
              )
            : Container(child: Text("No Document")));
  }
}
