import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/services/certificate_service.dart';
import 'package:prototype_project/services/service_request.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final _service = CertificateService();
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await _service.getMyRequests();
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
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  Future<void> _showCancelConfirmation(ServiceRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: Text(
          'Are you sure you want to cancel request ${request.requestCode}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO', style: TextStyle(color: ColorStyle.slategrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('YES, CANCEL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.cancelRequest(request.id);
        await _loadRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request cancelled successfully'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cancelling: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      appBar: AppBar(
        title: const Text(
          'My Certificate Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorStyle.topazyw3,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorStyle.topazyw2))
          : _requests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  color: ColorStyle.topazyw2,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_requests[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: ColorStyle.platinum,
          ),
          const SizedBox(height: 20),
          const Text(
            'No requests yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorStyle.topazyw3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your certificate requests will appear here',
            style: TextStyle(color: ColorStyle.slategrey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Request New Certificate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorStyle.topazyw2,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: request.statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: request.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(request.status),
              color: request.statusColor,
              size: 28,
            ),
          ),
          title: Text(
            request.serviceName ?? 'Certificate Request',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: ColorStyle.topazyw3,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Code: ${request.requestCode}',
                style: TextStyle(
                  fontSize: 13,
                  color: ColorStyle.slategrey,
                  fontFamily: 'Monospace',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: request.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: request.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(request.requestedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorStyle.paleslate,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorStyle.topazwhite,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Purpose
                  _buildDetailRow(Icons.flag, 'Purpose', request.purpose),
                  const Divider(height: 24),
                  
                  // Status Details based on current status
                  if (request.status == 'pending') ...[
                    _buildInfoAlert(
                      Icons.schedule,
                      'Under Review',
                      'Your request is being reviewed by the Barangay Office. Please wait for approval.',
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    // ADD CANCEL BUTTON HERE
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelConfirmation(request),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'CANCEL REQUEST',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]else if (request.status == 'approved') ...[
                    _buildInfoAlert(
                      Icons.check_circle,
                      'Approved',
                      'Your request has been approved. Please wait for the pickup schedule.',
                      Colors.blue,
                    ),
                  ] else if (request.status == 'ready_to_pickup') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_available, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text(
                                'Ready for Pickup!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (request.pickupDate != null)
                            _buildDetailRow(
                              Icons.calendar_today,
                              'Pickup Date',
                              DateFormat('MMMM dd, yyyy').format(request.pickupDate!),
                            ),
                          const SizedBox(height: 8),
                          _buildBringRequirements(request),
                        ],
                      ),
                    ),
                  ] else if (request.status == 'completed') ...[
                    _buildInfoAlert(
                      Icons.done_all,
                      'Completed',
                      'You have already picked up this certificate.',
                      Colors.green,
                    ),
                  ] else if (request.status == 'rejected') ...[
                    _buildInfoAlert(
                      request.isCancelledByResident ? Icons.block : Icons.cancel,
                      request.isCancelledByResident ? 'Cancelled' : 'Rejected',
                      request.isCancelledByResident 
                        ? 'You cancelled this request. You may submit a new request if needed.'
                        : (request.adminNotes ?? 'Your request was rejected by the Barangay Office. Please contact them for more information.'),
                      request.isCancelledByResident ? Colors.grey : Colors.red,
                    ),
                  ],
                  
                  // Fee Information (always show if there's fee)
                  if (request.fee != null && request.fee! > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorStyle.topazyw1.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorStyle.topazyw2.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payments, color: ColorStyle.topazyw3),
                              SizedBox(width: 8),
                              Text(
                                'Certificate Fee:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorStyle.topazyw3,
                                ),
                              ),
                            ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorStyle.paleslate),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
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
    );
  }

  Widget _buildInfoAlert(IconData icon, String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorStyle.slategrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBringRequirements(ServiceRequest request) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorStyle.platinum),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.backpack, color: ColorStyle.topazyw3, size: 18),
              SizedBox(width: 8),
              Text(
                'Bring upon pickup:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Valid ID (Original & Photocopy)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          if (request.fee != null && request.fee! > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment: ₱${request.fee!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request Code: ${request.requestCode}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle_outline;
      case 'ready_to_pickup':
        return Icons.event_available;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}