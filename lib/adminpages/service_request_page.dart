import 'package:flutter/material.dart';
import 'package:prototype_project/services/certificate_preview.dart';
import 'package:prototype_project/services/certificate_service.dart';
import 'package:prototype_project/services/service_request.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:intl/intl.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _service = CertificateService();
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  ServiceRequest? _selectedRequest;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _service.getAdminRequests(status: _selectedFilter);
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Map<String, int> get _statusCounts {
    final counts = {
      'all': _requests.length,
      'pending': 0,
      'approved': 0,
      'ready_to_pickup': 0,
      'completed': 0,
      'rejected': 0,
    };
    for (var r in _requests) {
      counts[r.status] = (counts[r.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      appBar: AppBar(
        title: const Text(
          'Service Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // GRADIENT APPBAR
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
        // WALANG REFRESH BUTTON DITO
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // LEFT PANEL
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // NEW: HEADER WITH REFRESH BUTTON
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorStyle.topazyw3,
                        ),
                      ),
                      // REFRESH BUTTON DITO NA LANG
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: ColorStyle.topazyw3.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _loadRequests,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Refresh',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Cards (existing)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildStatusCard('All', _statusCounts['all'] ?? 0, 'all', ColorStyle.topazyw2),
                      _buildStatusCard('Pending', _statusCounts['pending'] ?? 0, 'pending', Colors.orange),
                      _buildStatusCard('Approved', _statusCounts['approved'] ?? 0, 'approved', Colors.blue),
                      _buildStatusCard('Ready', _statusCounts['ready_to_pickup'] ?? 0, 'ready_to_pickup', ColorStyle.maroon),
                      _buildStatusCard('Completed', _statusCounts['completed'] ?? 0, 'completed', Colors.green),
                      _buildStatusCard('Cancelled', _statusCounts['rejected'] ?? 0, 'rejected', Colors.red),
                    ],
                  ),
                ),
                
                // Search/Filter (existing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
                      hintStyle: const TextStyle(color: ColorStyle.paleslate),
                      prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorStyle.platinum),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                
                // Requests List (existing)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: ColorStyle.topazyw2))
                      : _requests.isEmpty
                          ? const Center(
                              child: Text(
                                'No requests found',
                                style: TextStyle(color: ColorStyle.slategrey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                final isSelected = _selectedRequest?.id == request.id;
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  color: isSelected 
                                      ? ColorStyle.topazyw1.withValues(alpha: 0.3)
                                      : Colors.white,
                                  child: ListTile(
                                    onTap: () => setState(() => _selectedRequest = request),
                                    leading: CircleAvatar(
                                      backgroundColor: request.statusColor.withValues(alpha: 0.2),
                                      child: Icon(
                                        _getStatusIcon(request.status),
                                        color: request.statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      request.requestCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorStyle.topazyw3,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request.residentName ?? 'Unknown',
                                          style: const TextStyle(color: ColorStyle.slategrey),
                                        ),
                                        Text(
                                          request.serviceName ?? 'Unknown Service',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ColorStyle.paleslate,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      DateFormat('MMM dd').format(request.requestedAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ColorStyle.paleslate,
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
          
          // RIGHT PANEL - Details (existing structure)
          Expanded(
            flex: 3,
            child: _selectedRequest == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          size: 100,
                          color: ColorStyle.platinum,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select a request to view details',
                          style: TextStyle(
                            color: ColorStyle.slategrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDetailsPanel(_selectedRequest!),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, String status, Color color) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = status;
          _selectedRequest = null;
        });
        _loadRequests();
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : ColorStyle.slategrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(ServiceRequest request) {
    final notesController = TextEditingController(text: request.adminNotes);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requestCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorStyle.topazyw3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: request.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.statusLabel,
                        style: TextStyle(
                          color: request.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (request.fee != null && request.fee! > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorStyle.topazyw1.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorStyle.topazyw2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'FEE',
                          style: TextStyle(
                            fontSize: 10,
                            color: ColorStyle.topazyw3,
                          ),
                        ),
                        Text(
                          '₱${request.fee!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorStyle.topazyw3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 40, color: ColorStyle.platinum),
            
            // Resident Info
            const Text(
              'RESIDENT INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorStyle.slategrey,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.person, 'Name', request.residentName ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Contact', request.residentPhone ?? 'N/A'),
            _buildInfoRow(Icons.location_on, 'Address', 
              request.residentAddress != null 
                ? 'Purok ${request.residentAddress}, Ulbujan' 
                : 'N/A'
            ),
            
            const SizedBox(height: 20),
            
            // Service Details
            const Text(
              'REQUEST DETAILS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorStyle.slategrey,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.description, 'Service', request.serviceName ?? 'N/A'),
            _buildInfoRow(Icons.flag, 'Purpose', request.purpose),
            _buildInfoRow(
              Icons.calendar_today, 
              'Requested On', 
              DateFormat('MMMM dd, yyyy - hh:mm a').format(request.requestedAt),
            ),
            
            if (request.pickupDate != null)
              _buildInfoRow(
                Icons.event_available,
                'Pickup Date',
                DateFormat('MMMM dd, yyyy').format(request.pickupDate!),
              ),
            
            const SizedBox(height: 20),
            
            // Admin Notes
            const Text(
              'ADMIN NOTES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorStyle.slategrey,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes here...',
                hintStyle: const TextStyle(color: ColorStyle.paleslate),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorStyle.platinum),
                ),
                filled: true,
                fillColor: ColorStyle.topazwhite,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons based on status
            _buildActionButtons(request, notesController),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorStyle.paleslate),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorStyle.slategrey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.topazyw3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ServiceRequest request, TextEditingController notesController) {
    switch (request.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(request.id, 'approved', notesController.text),
                icon: const Icon(Icons.check),
                label: const Text('APPROVE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(request.id, 'rejected', notesController.text),
                icon: const Icon(Icons.close),
                label: const Text('REJECT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.redtraf,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        );
        
      case 'approved':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPickupDateDialog(request),
                icon: const Icon(Icons.event),
                label: const Text('SET PICKUP DATE & MARK READY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.maroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generateCertificate(request),
                icon: const Icon(Icons.print),
                label: const Text('PREVIEW CERTIFICATE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        );
        
      case 'ready_to_pickup':
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ready for Pickup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          request.fee != null && request.fee! > 0
                              ? 'Resident must bring ₱${request.fee!.toStringAsFixed(2)} and Valid ID'
                              : 'Resident must bring Valid ID only (No fee)',
                          style: const TextStyle(fontSize: 12, color: ColorStyle.slategrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(request.id, 'completed', notesController.text),
                icon: const Icon(Icons.done_all),
                label: const Text('MARK AS COMPLETED (PICKED UP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _generateCertificate(request),
                icon: const Icon(Icons.print),
                label: const Text('REPRINT CERTIFICATE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorStyle.topazyw3,
                  side: const BorderSide(color: ColorStyle.topazyw2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        );
        
        case 'rejected':
          final bool isResidentCancelled = request.adminNotes == 'Cancelled by resident';
          
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isResidentCancelled 
                ? Colors.grey.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isResidentCancelled ? Colors.grey : Colors.red),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isResidentCancelled ? Icons.block : Icons.cancel,
                  color: isResidentCancelled ? Colors.grey : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isResidentCancelled ? 'Cancelled by Resident' : 'Rejected by Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isResidentCancelled ? Colors.grey : Colors.red,
                        ),
                      ),
                      if (request.adminNotes != null && !isResidentCancelled)
                        Text(
                          'Reason: ${request.adminNotes}',
                          style: const TextStyle(fontSize: 12, color: ColorStyle.slategrey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(String requestId, String status, String notes) async {
    try {
      await _service.updateRequestStatus(requestId, status, notes: notes);
      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${status.toUpperCase()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showPickupDateDialog(ServiceRequest request) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      try {
        await _service.setPickupDate(request.id, date);
        await _loadRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pickup date set successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _generateCertificate(ServiceRequest request) async {
    try {
      // Fetch complete resident data
      final residentData = await _service.getResidentData(request.residentId);
      final purok = residentData['address_purok']?.toString() ?? '___';
      
      // Show Preview First
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CertificatePreview(
            serviceName: request.serviceName ?? 'Certificate',
            residentName: '${residentData['first_name']} ${residentData['last_name']}',
            purok: purok,
            purpose: request.purpose,
            requestCode: request.requestCode,
            onPrint: () async {
              Navigator.pop(context);
              // Generate actual PDF
              await _service.generateCertificate(request, residentData);
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preview: $e')),
        );
      }
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'approved': return Icons.check_circle_outline;
      case 'ready_to_pickup': return Icons.event_available;
      case 'completed': return Icons.done_all;
      case 'rejected': return Icons.cancel;
      default: return Icons.help;
    }
  }
}