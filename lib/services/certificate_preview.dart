import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class CertificatePreview extends StatelessWidget {
  final String serviceName;
  final String residentName;
  final String purok;
  final String purpose;
  final String requestCode;
  final VoidCallback onPrint;
  final VoidCallback onCancel;

  const CertificatePreview({
    super.key,
    required this.serviceName,
    required this.residentName,
    required this.purok,
    required this.purpose,
    required this.requestCode,
    required this.onPrint,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 900,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorStyle.topazyw3,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Certificate Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onPrint,
                        icon: const Icon(Icons.print),
                        label: const Text('Print / Save PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ColorStyle.topazyw3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Certificate Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      // Header with Logos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Logo (Ulbujan)
                          Image.asset(
                            'asset/logoulbujan.png',
                            height: 100,
                            width: 100,
                            errorBuilder: (_, _, _) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          
                          // Center Text
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  const Text(
                                    'REPUBLIC OF THE PHILIPPINES',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    'Province of Bohol',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    'Municipality of Calape',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Barangay Ulbujan',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: ColorStyle.topazyw3,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Right Logo (Bagong Pilipinas)
                          Image.asset(
                            'asset/bagoph.png',
                            height: 100,
                            width: 100,
                            errorBuilder: (_, _, _) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 30, thickness: 2, color: Colors.black),
                      
                      // Office Title
                      const Text(
                        'OFFICE OF THE BARANGAY CAPTAIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Certificate Title
                      Text(
                        serviceName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // To Whom It May Concern
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TO WHOM IT MAY CONCERN:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Body Content
                      _buildCertificateBody(),
                      
                      const SizedBox(height: 40),
                      
                      // Issued Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                              const TextSpan(text: 'ISSUED this '),
                              const TextSpan(
                                text: '_____',
                                style: TextStyle(decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: ' day of '),
                              const TextSpan(
                                text: '_____________________',
                                style: TextStyle(decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: ', 2025 at Barangay Ulbujan, Calape, Bohol upon request of the interested party for '),
                              TextSpan(
                                text: purpose.isNotEmpty ? purpose : 'whatever legal purposes',
                                style: const TextStyle(decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: ' it may serve.'),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Signature Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left side - Control Number
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Control No.: $requestCode',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'O.R. No.: _______________',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                'Date Issued: _______________',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                'Doc. Stamp: Paid',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          
                          // Right side - Signature
                          Column(
                            children: [
                              const Text(
                                '_________________________',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Hon. Cid Kagenou',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Barangay Captain',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Secretary attestation (optional, smaller)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                '_________________________',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Hon. Claire Kagenou',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Barangay Secretary',
                                style: TextStyle(fontSize: 11),
                              ),
                              
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateBody() {
    if (serviceName.toLowerCase().contains('clearance')) {
      return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.black),
          children: [
            const TextSpan(text: 'This is to certify that '),
            TextSpan(
              text: residentName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ', '),
            const TextSpan(
              text: '_____',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ' years old, Filipino, and a resident of '),
            TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ', is known to be of good moral character and law-abiding citizen in the community.\n\n'),
            const TextSpan(text: 'To certify further, that he/she has no derogatory and/or criminal records filed in this barangay.'),
          ],
        ),
      );
    } else if (serviceName.toLowerCase().contains('residency')) {
      return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.black),
          children: [
            const TextSpan(text: 'This is to certify that '),
            TextSpan(
              text: residentName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ', '),
            const TextSpan(
              text: '_____',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ' years old, Filipino, is a bonafide resident of '),
            TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: '.\n\n'),
            const TextSpan(text: 'This certification is issued upon request of the above-named person for whatever legal purpose it may serve.'),
          ],
        ),
      );
    } else {
      // Default/Indigency
      return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.black),
          children: [
            const TextSpan(text: 'This is to certify that '),
            TextSpan(
              text: residentName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ', residing at '),
            TextSpan(
              text: 'Purok $purok, Ulbujan, Calape, Bohol',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ', belongs to an indigent family in this Barangay.\n\n'),
            const TextSpan(text: 'This certification is issued upon request for '),
            TextSpan(
              text: purpose.isNotEmpty ? purpose : 'medical/financial assistance',
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
            const TextSpan(text: ' and for whatever legal purpose it may serve.'),
          ],
        ),
      );
    }
  }
}