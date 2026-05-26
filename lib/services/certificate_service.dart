import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'barangay_service.dart';
import 'service_request.dart';

class CertificateService {
  final _supabase = Supabase.instance.client;

  // ==================== SERVICES ====================
  
  // Get all active services
  Future<List<BarangayService>> getServices() async {
    final response = await _supabase
        .from('barangay_services')
        .select()
        .eq('is_active', true)
        .order('service_name');
    
    return (response as List).map((e) => BarangayService.fromJson(e)).toList();
  }

  // ==================== RESIDENT REQUESTS ====================
  
  // Create new request
  Future<String> createRequest({
    required String serviceId,
    required String purpose,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final resident = await _supabase
        .from('resident_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    final code = 'BRG-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    
    final response = await _supabase.from('service_requests').insert({
      'request_code': code,
      'resident_id': resident['id'],
      'service_id': serviceId,
      'purpose': purpose,
      'status': 'pending',
    }).select().single();

    return response['request_code'] as String;
  }

  // Get requests for CURRENT resident (para sa MyRequestsPage)
  Future<List<ServiceRequest>> getMyRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Get resident_id first
    final resident = await _supabase
        .from('resident_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    final response = await _supabase
        .from('service_requests')
        .select('''
          *,
          barangay_services (service_name, fee, requirements),
          resident_profiles (first_name, last_name, address_purok, phone)
        ''')
        .eq('resident_id', resident['id'])
        .order('requested_at', ascending: false);

    return (response as List).map((e) => ServiceRequest.fromJson(e)).toList();
  }

  // ==================== ADMIN REQUESTS ====================
  
  // Get ALL requests for admin (para sa ServiceRequestPage)
  Future<List<ServiceRequest>> getAdminRequests({String? status}) async {
    var query = _supabase
        .from('service_requests')
        .select('''
          *,
          barangay_services (service_name, fee),
          resident_profiles (first_name, last_name, address_purok, phone, birthdate)
        ''');

    if (status != null && status != 'all') {
      query = query.eq('status', status);
    }

    final response = await query.order('requested_at', ascending: false);
    return (response as List).map((e) => ServiceRequest.fromJson(e)).toList();
  }

  Future<void> updateRequestStatus(String requestId, String status, {String? notes}) async {
    final updates = {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'admin_notes': notes,
      if (status == 'approved' || status == 'rejected') 
        'processed_at': DateTime.now().toIso8601String(),
    };
    await _supabase.from('service_requests').update(updates).eq('id', requestId);
  }

  Future<void> setPickupDate(String requestId, DateTime date) async {
    await _supabase.from('service_requests').update({
      'pickup_date': date.toIso8601String(),
      'status': 'ready_to_pickup',
    }).eq('id', requestId);
  }

  // Add this method sa CertificateService class:

  Future<void> cancelRequest(String requestId) async {
    await _supabase.from('service_requests').update({
      'status': 'rejected',
      'admin_notes': 'Cancelled by resident',
      'processed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  // ==================== CERTIFICATE GENERATION ====================
  
  SupabaseClient get supabase => _supabase;

  // Get resident data with purok
  Future<Map<String, dynamic>> getResidentData(String residentId) async {
    final data = await _supabase
        .from('resident_profiles')
        .select()
        .eq('id', residentId)
        .single();
    return data;
  }

  // Generate PDF with proper layout
  Future<void> generateCertificate(ServiceRequest request, Map<String, dynamic> residentData) async {
    final pdf = pw.Document();

    // Load logos
    Uint8List? leftLogoBytes;
    Uint8List? rightLogoBytes;
    
    try {
      final leftLogoData = await rootBundle.load('asset/logoulbujan.png');
      leftLogoBytes = leftLogoData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Left logo not found: $e');
    }
    
    try {
      final rightLogoData = await rootBundle.load('asset/bagoph.png');
      rightLogoBytes = rightLogoData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Right logo not found: $e');
    }

    final serviceName = request.serviceName ?? 'Certificate';
    final residentName = '${residentData['first_name']} ${residentData['last_name']}';
    final purok = residentData['address_purok']?.toString() ?? '___';
    final purpose = request.purpose;
    final requestCode = request.requestCode;
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2),
            ),
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header with Logos
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Logo
                    if (leftLogoBytes != null)
                      pw.Image(
                        pw.MemoryImage(leftLogoBytes),
                        height: 80,
                        width: 80,
                      )
                    else
                      pw.Container(height: 80, width: 80),
                    
                    // Center Text
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'REPUBLIC OF THE PHILIPPINES',
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.Text(
                              'Province of Bohol',
                              style: pw.TextStyle(fontSize: 12),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.Text(
                              'Municipality of Calape',
                              style: pw.TextStyle(fontSize: 12),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Barangay Ulbujan',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                fontStyle: pw.FontStyle.italic,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Right Logo
                    if (rightLogoBytes != null)
                      pw.Image(
                        pw.MemoryImage(rightLogoBytes),
                        height: 80,
                        width: 80,
                      )
                    else
                      pw.Container(height: 80, width: 80),
                  ],
                ),
                
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                
                pw.Text(
                  'OFFICE OF THE BARANGAY CAPTAIN',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2),
                ),
                
                pw.SizedBox(height: 30),
                
                pw.Text(
                  serviceName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'TO WHOM IT MAY CONCERN:',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Certificate Body based on type
                _buildPdfBody(serviceName, residentName, purok, purpose),
                
                pw.SizedBox(height: 30),
                
                // Issued section
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(fontSize: 12),
                      children: [
                        const pw.TextSpan(text: 'ISSUED this '),
                        const pw.TextSpan(
                          text: '_____',
                          style: pw.TextStyle(decoration: pw.TextDecoration.underline),
                        ),
                        const pw.TextSpan(text: ' day of '),
                        const pw.TextSpan(
                          text: '_____________________',
                          style: pw.TextStyle(decoration: pw.TextDecoration.underline),
                        ),
                        pw.TextSpan(text: ', ${now.year} at Barangay Ulbujan, Calape, Bohol upon request of the interested party for '),
                        pw.TextSpan(
                          text: purpose.isNotEmpty ? purpose : 'whatever legal purposes',
                          style: pw.TextStyle(decoration: pw.TextDecoration.underline),
                        ),
                        const pw.TextSpan(text: ' it may serve.'),
                      ],
                    ),
                  ),
                ),
                
                pw.Spacer(),
                
                // Bottom section with signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Left - Control Number
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Control No.: $requestCode',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text('O.R. No.: _______________', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Date Issued: _______________', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Doc. Stamp: Paid', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    
                    // Right - Captain Signature
                    pw.Column(
                      children: [
                        pw.Container(width: 200, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Hon. Cid Kagenou',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Barangay Captain', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Secretary Attestation
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Hon. Claire Kagenou',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Barangay Secretary', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('(Attested)', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfBody(String serviceName, String residentName, String purok, String purpose) {
    if (serviceName.toLowerCase().contains('clearance')) {
      return pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
          children: [
            const pw.TextSpan(text: 'This is to certify that '),
            pw.TextSpan(
              text: residentName.toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ', '),
            const pw.TextSpan(
              text: '_____',
              style: pw.TextStyle(decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ' years old, Filipino, and a resident of '),
            pw.TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ', is known to be of good moral character and law-abiding citizen in the community.\n\n'),
            const pw.TextSpan(text: 'To certify further, that he/she has no derogatory and/or criminal records filed in this barangay.'),
          ],
        ),
      );
    } else if (serviceName.toLowerCase().contains('residency')) {
      return pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
          children: [
            const pw.TextSpan(text: 'This is to certify that '),
            pw.TextSpan(
              text: residentName.toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ', '),
            const pw.TextSpan(
              text: '_____',
              style: pw.TextStyle(decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ' years old, Filipino, is a bonafide resident of '),
            pw.TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: '.\n\nThis certification is issued upon request of the above-named person for whatever legal purpose it may serve.'),
          ],
        ),
      );
    } else {
      // Indigency or default
      return pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
          children: [
            const pw.TextSpan(text: 'This is to certify that '),
            pw.TextSpan(
              text: residentName.toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ', residing at '),
            pw.TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ', belongs to an indigent family in this Barangay.\n\n'),
            const pw.TextSpan(text: 'This certification is issued upon request for '),
            pw.TextSpan(
              text: purpose.isNotEmpty ? purpose : 'medical/financial assistance',
              style: pw.TextStyle(decoration: pw.TextDecoration.underline),
            ),
            const pw.TextSpan(text: ' and for whatever legal purpose it may serve.'),
          ],
        ),
      );
    }
  }
}