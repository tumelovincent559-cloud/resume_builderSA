// main.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ResumeApp());
}

class ResumeApp extends StatelessWidget {
  const ResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Builder',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ResumeFormScreen(),
    );
  }
}

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();

  String _template = 'Modern';

  bool _saving = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _titleCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();
    _idCtrl.dispose();
    _summaryCtrl.dispose();
    _skillsCtrl.dispose();
    _experienceCtrl.dispose();
    _educationCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // Build UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(10));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        actions: [
          IconButton(
            tooltip: 'Export PDF / Share',
            onPressed: _generatePdfAndShare,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: 'Save locally',
            onPressed: _saveLocally,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  controller: _fullNameCtrl,
                  label: 'Full Name',
                  required: true,
                ),
                _buildField(
                  controller: _titleCtrl,
                  label: 'Target Job Title (e.g., Software Developer)',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _phoneCtrl,
                        label: 'Phone (incl. country code)',
                        required: true,
                        keyboard: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        required: true,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _locationCtrl,
                  label: 'City, Province (e.g., Johannesburg, Gauteng)',
                ),
                _buildField(
                  controller: _idCtrl,
                  label: 'South African ID (optional)',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _template,
                  items: const [
                    DropdownMenuItem(value: 'Modern', child: Text('Modern')),
                    DropdownMenuItem(value: 'Minimal', child: Text('Minimal')),
                    DropdownMenuItem(
                      value: 'ATS-friendly',
                      child: Text('ATS-friendly'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _template = v ?? 'Modern'),
                  decoration: InputDecoration(
                    labelText: 'Resume Template',
                    border: border,
                  ),
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _summaryCtrl,
                  label: 'Professional Summary (2–4 lines)',
                  maxLines: 4,
                ),
                _buildField(
                  controller: _skillsCtrl,
                  label: 'Skills (comma-separated)',
                  maxLines: 3,
                ),
                _buildField(
                  controller: _experienceCtrl,
                  label: 'Work Experience (roles, duties, dates)',
                  maxLines: 5,
                ),
                _buildField(
                  controller: _educationCtrl,
                  label: 'Education (qualifications & institutions)',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Preview card
                _templatePreview(),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generatePdfAndShare,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF / Share'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveLocally,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Resume'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                if (_saving)
                  Row(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                  ? 'This field is required'
                  : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ---------------------------
  // Preview widget (upgraded)
  // ---------------------------
  Widget _templatePreview() {
    Color accent;
    switch (_template) {
      case 'Minimal':
        accent = Colors.grey.shade800;
        break;
      case 'ATS-friendly':
        accent = Colors.blueGrey.shade900;
        break;
      default:
        accent = Colors.blueAccent;
    }

    final skills = _skillsCtrl.text.isEmpty
        ? ['Communication', 'Teamwork', 'Problem Solving']
        : _skillsCtrl.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _fullNameCtrl.text.isEmpty
                  ? 'Your Name'
                  : _fullNameCtrl.text.trim(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _titleCtrl.text.isEmpty ? 'Job Title' : _titleCtrl.text.trim(),
              style: TextStyle(fontSize: 14, color: accent.withOpacity(.9)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _phoneCtrl.text.isEmpty
                        ? '+27 00 000 0000'
                        : _phoneCtrl.text.trim(),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.email, size: 14, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _emailCtrl.text.isEmpty
                        ? 'email@example.com'
                        : _emailCtrl.text.trim(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _locationCtrl.text.isEmpty
                        ? 'City, Province'
                        : _locationCtrl.text.trim(),
                  ),
                ),
              ],
            ),
            if (_idCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.badge, size: 14, color: accent),
                  const SizedBox(width: 6),
                  Text('ID: ${_idCtrl.text.trim()}'),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _sectionTitle('Summary', accent),
            Text(
              _summaryCtrl.text.isEmpty
                  ? 'A short professional summary will appear here...'
                  : _summaryCtrl.text.trim(),
            ),
            const SizedBox(height: 12),
            _sectionTitle('Skills', accent),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: accent.withOpacity(.08),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12, color: accent)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _sectionTitle('Experience', accent),
            Text(
              _experienceCtrl.text.isEmpty
                  ? 'Your latest job experience will show here...'
                  : _experienceCtrl.text.trim(),
            ),
            const SizedBox(height: 12),
            _sectionTitle('Education', accent),
            Text(
              _educationCtrl.text.isEmpty
                  ? 'Your education history will show here...'
                  : _educationCtrl.text.trim(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: accent,
        ),
      ),
    );
  }

  // ---------------------------
  // PDF generation
  // ---------------------------
  Future<pw.Document> _buildResumePdf() async {
    final doc = pw.Document();

    final fullName = _fullNameCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final id = _idCtrl.text.trim();
    final summary = _summaryCtrl.text.trim();
    final skills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final experience = _experienceCtrl.text.trim();
    final education = _educationCtrl.text.trim();

    // Choose template
    if (_template == 'Minimal') {
      // Minimal template
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  fullName.isEmpty ? 'Your Name' : fullName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  title.isEmpty ? 'Job Title' : title,
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Phone: ${phone.isEmpty ? '+27 00 000 0000' : phone}',
                      ),
                    ),
                    pw.Text(
                      'Email: ${email.isEmpty ? 'email@example.com' : email}',
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                if (location.isNotEmpty) pw.Text(location),
                if (id.isNotEmpty) pw.Text('ID: $id'),
                pw.Divider(),
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  summary.isEmpty ? 'Short professional summary...' : summary,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Skills',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: skills.isEmpty
                      ? [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Communication'),
                          ),
                        ]
                      : skills
                            .map(
                              (s) => pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(s),
                              ),
                            )
                            .toList(),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Experience',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  experience.isEmpty
                      ? 'Your jobs, duties, and dates...'
                      : experience,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Education',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  education.isEmpty
                      ? 'Qualifications & institutions...'
                      : education,
                ),
              ],
            );
          },
        ),
      );
    } else if (_template == 'ATS-friendly') {
      // ATS-friendly (plain layout, easy parse)
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  fullName.isEmpty ? 'Your Name' : fullName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(title.isEmpty ? 'Job Title' : title),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Contact',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Bullet(
                  text: 'Phone: ${phone.isEmpty ? '+27 00 000 0000' : phone}',
                ),
                pw.Bullet(
                  text: 'Email: ${email.isEmpty ? 'email@example.com' : email}',
                ),
                if (location.isNotEmpty) pw.Bullet(text: 'Location: $location'),
                if (id.isNotEmpty) pw.Bullet(text: 'ID: $id'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Professional Summary',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  summary.isEmpty ? 'Short professional summary...' : summary,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Skills',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: skills.isEmpty
                      ? [pw.Text('- Communication')]
                      : skills.map((s) => pw.Text('- $s')).toList(),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Experience',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  experience.isEmpty ? 'Jobs, duties, dates...' : experience,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Education',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  education.isEmpty
                      ? 'Qualifications & institutions...'
                      : education,
                ),
              ],
            );
          },
        ),
      );
    } else {
      // Modern template
      final accentColor = PdfColor.fromInt(0xFF1E88E5); // blue accent
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) {
            return [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 2, color: accentColor),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            fullName.isEmpty ? 'Your Name' : fullName,
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            title.isEmpty ? 'Job Title' : title,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(phone.isEmpty ? '+27 00 000 0000' : phone),
                        pw.Text(email.isEmpty ? 'email@example.com' : email),
                        if (location.isNotEmpty) pw.Text(location),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Summary',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          summary.isEmpty
                              ? 'Short professional summary...'
                              : summary,
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'Experience',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          experience.isEmpty
                              ? 'Jobs, duties, dates...'
                              : experience,
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'Education',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          education.isEmpty
                              ? 'Qualifications & institutions...'
                              : education,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: accentColor),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Skills',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              for (var s
                                  in skills.isEmpty
                                      ? ['Communication', 'Teamwork']
                                      : skills)
                                pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 4),
                                  child: pw.Text('• $s'),
                                ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        if (id.isNotEmpty) pw.Text('ID: $id'),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );
    }

    return doc;
  }

  // ---------------------------
  // Export / Share / Save
  // ---------------------------
  Future<void> _generatePdfAndShare() async {
    // Validate required fields minimally
    if (_fullNameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      // show a small validation tip
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill required fields: Full name, Phone, Email.',
          ),
        ),
      );
      return;
    }

    try {
      final doc = await _buildResumePdf();
      final bytes = await doc.save();

      final dir = await getTemporaryDirectory();
      final fileName = _makeFileName();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Use share_plus to share
      if (kIsWeb) {
        // For web: open print preview
        await Printing.layoutPdf(onLayout: (format) => bytes);
      } else {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'My Resume — generated with Resume Builder');
      }
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('PDF generation error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to generate PDF.')));
    }
  }

  Future<void> _saveLocally() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors first.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final doc = await _buildResumePdf();
      final bytes = await doc.save();

      final dir = await getApplicationDocumentsDirectory();
      final fileName = _makeFileName();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    } catch (e, st) {
      debugPrint('Save error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save file.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _makeFileName() {
    final namePart = _fullNameCtrl.text.trim().isEmpty
        ? 'resume'
        : _fullNameCtrl.text.trim().replaceAll(RegExp(r'\s+'), '_');
    final datePart = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return '${namePart}_$datePart_${_template.toLowerCase().replaceAll(' ', '_')}.pdf';
  }
}
