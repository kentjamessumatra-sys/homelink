import 'package:flutter/material.dart';
import 'package:prototype_project/services/barangay_service.dart';
import 'package:prototype_project/services/certificate_service.dart';
import 'package:prototype_project/services/my_requests_page.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class BarangayServicesPage extends StatefulWidget {
  const BarangayServicesPage({super.key});

  @override
  State<BarangayServicesPage> createState() => _BarangayServicesPageState();
}

class _BarangayServicesPageState extends State<BarangayServicesPage> {
  final _service = CertificateService();
  List<BarangayService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _service.getServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  void _showRequestDialog(BarangayService service) {
    final purposeController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorStyle.topazyw3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: ColorStyle.slategrey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                service.description,
                style: const TextStyle(color: ColorStyle.slategrey, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw1.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorStyle.topazyw2.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: ColorStyle.topazyw3),
                        const SizedBox(width: 10),
                        Text(
                          service.fee == 0 
                              ? 'FREE' 
                              : '₱${service.fee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorStyle.topazyw3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.description, color: ColorStyle.reddart),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Requirements: ${service.requirements}',
                            style: const TextStyle(fontSize: 14, color: ColorStyle.slategrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Purpose of Request:',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: ColorStyle.topazyw3,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: purposeController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: For employment requirements...',
                  hintStyle: const TextStyle(color: ColorStyle.paleslate),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: ColorStyle.platinum),
                  ),
                  filled: true,
                  fillColor: ColorStyle.topazwhite,
                ),
              ),
              const SizedBox(height: 10),
              if (service.fee > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorStyle.redtraf.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: ColorStyle.redtraf),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reminder: Please bring ₱${service.fee.toStringAsFixed(2)} when picking up your certificate.',
                          style: const TextStyle(color: ColorStyle.redtraf, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (purposeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter purpose')),
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                    await _submitRequest(service, purposeController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorStyle.topazyw2,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest(BarangayService service, String purpose) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: ColorStyle.topazyw2)),
    );

    try {
      final code = await _service.createRequest(
        serviceId: service.id,
        purpose: purpose,
      );
      
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(code, service);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(String code, BarangayService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorStyle.topazwhite,
        title: const Text('Request Submitted!', style: TextStyle(color: ColorStyle.topazyw3)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Your request code:',
              style: TextStyle(color: ColorStyle.slategrey),
            ),
            Text(
              code,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: ColorStyle.topazyw3,
              ),
            ),
            const SizedBox(height: 10),
            if (service.fee > 0)
              Text(
                'Please bring ₱${service.fee.toStringAsFixed(2)} when picking up.',
                style: const TextStyle(color: ColorStyle.redtraf),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            const Text(
              'Check your requests tab for updates.',
              style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: ColorStyle.topazyw3)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      appBar: AppBar(
        title: const Text(
          'Barangay Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
       flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorStyle.topazyw2))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INFO BANNER (existing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: ColorStyle.topazyw3.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Select a certificate below and fill up the form. Processing usually takes 1-2 days.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ===== NEW: MY REQUESTS BUTTON =====
                  // Malaking button na hindi mapapindot ng dahil lang sa close
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyRequestsPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorStyle.topazyw2.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorStyle.topazyw1.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: ColorStyle.topazyw3,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Certificate Requests',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorStyle.topazyw3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Track status & view pickup details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ColorStyle.slategrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ColorStyle.topazyw2,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Available Certificates Header
                  const Text(
                    'Available Certificates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.topazyw3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // List of services
                  Expanded(
                    child: ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showRequestDialog(service),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorStyle.topazyw1.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getIconForService(service.serviceName),
                                      color: ColorStyle.topazyw3,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.serviceName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: ColorStyle.topazyw3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: ColorStyle.slategrey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: service.fee == 0 
                                                ? Colors.green.withValues(alpha: 0.1)
                                                : ColorStyle.topazyw1.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            service.fee == 0 
                                                ? 'FREE' 
                                                : '₱${service.fee.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: service.fee == 0 
                                                  ? Colors.green 
                                                  : ColorStyle.topazyw3,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: ColorStyle.paleslate),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getIconForService(String name) {
    if (name.toLowerCase().contains('clearance')) return Icons.fact_check;
    if (name.toLowerCase().contains('residency')) return Icons.home;
    if (name.toLowerCase().contains('indigency')) return Icons.volunteer_activism;
    if (name.toLowerCase().contains('business')) return Icons.business;
    if (name.toLowerCase().contains('moral')) return Icons.verified_user;
    return Icons.description;
  }
}