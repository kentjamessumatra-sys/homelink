import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/services/report_service.dart';
import 'package:prototype_project/services/service_report_model.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class ServiceReportPage extends StatefulWidget {
  const ServiceReportPage({super.key});

  @override
  State<ServiceReportPage> createState() => _ServiceReportPageState();
}

class _ServiceReportPageState extends State<ServiceReportPage> {
  final ReportService _reportService = ReportService();
  
  List<ServiceReportModel> _reports = [];
  ServiceReportModel? _selectedReport;
  bool _isLoading = true;
  bool _isUpdating = false;
  
  // Filters
  String _searchQuery = '';
  ReportStatus? _statusFilter;
  ReportType? _typeFilter;

  // For status update dialog
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getAllReports(
        statusFilter: _statusFilter,
        typeFilter: _typeFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load reports: $e');
    }
  }

  Future<void> _updateStatus(ReportStatus newStatus) async {
    if (_selectedReport == null) return;
    
    setState(() => _isUpdating = true);
    
    try {
      final updated = await _reportService.updateStatus(
        reportId: _selectedReport!.id!,
        newStatus: newStatus,
        adminFeedback: _feedbackController.text.isNotEmpty 
            ? _feedbackController.text 
            : null,
      );
      
      setState(() {
        _selectedReport = updated;
        final index = _reports.indexWhere((r) => r.id == updated.id);
        if (index != -1) _reports[index] = updated;
        _isUpdating = false;
      });
      
      _feedbackController.clear();
      _showSuccess('Status updated to ${newStatus.label}');
    } catch (e) {
      setState(() => _isUpdating = false);
      _showError('Failed to update status: $e');
    }
  }

  void _showStatusUpdateDialog() {
    if (_selectedReport == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${_selectedReport!.status.label}',
              style: TextStyle(color: _selectedReport!.status.color),
            ),
            const SizedBox(height: 16),
            const Text('Select new status:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportStatus.values.map((status) {
                final isCurrent = status == _selectedReport!.status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: isCurrent,
                  selectedColor: status.color.withValues(alpha: 0.2),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isCurrent ? status.color : Colors.black87,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: isCurrent ? null : (selected) {
                    Navigator.pop(context);
                    _showFeedbackDialog(status);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(ReportStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Feedback (${newStatus.label})'),
        content: TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Optional: Add feedback or notes for the resident...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _feedbackController.clear();
              Navigator.pop(context);
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Map<String, int> get _statusCounts {
    return {
      'all': _reports.length,
      for (var status in ReportStatus.values)
        status.name: _reports.where((r) => r.status == status).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      appBar: AppBar(
        title: const Text(
          'Service Reports Management',
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
        // WALA NANG ACTIONS DITO - TANGGAL NA YUNG REFRESH ICON
      ),
      body: Row(
        children: [
          // LEFT PANEL - List & Filters
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Status Cards
                Container(
                  height: 110,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildStatusCard('All', _statusCounts['all'] ?? 0, null, ColorStyle.topazyw2),
                      ...ReportStatus.values.map((status) {
                        return _buildStatusCard(
                          status.label,
                          _statusCounts[status.name] ?? 0,
                          status,
                          status.color,
                        );
                      }),
                    ],
                  ),
                ),
                
                // Search & Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _loadReports();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          hintStyle: const TextStyle(color: ColorStyle.paleslate),
                          prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Type Filter Dropdown
                      DropdownButtonFormField<ReportType?>(
                        initialValue: _typeFilter,
                        hint: const Text('Filter by Type'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Types')),
                          ...ReportType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 18),
                                  const SizedBox(width: 8),
                                  Text(type.label),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _typeFilter = value);
                          _loadReports();
                        },
                      ),
                      
                      // REFRESH BUTTON - NASA BABA NG DROPDOWN
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _loadReports,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh, size: 20),
                          label: Text(
                            _isLoading ? 'Refreshing...' : 'Refresh Reports',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorStyle.topazyw3,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Reports List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadReports,
                    color: ColorStyle.topazyw3,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _reports.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox, size: 60, color: ColorStyle.platinum),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No reports found',
                                      style: TextStyle(color: ColorStyle.slategrey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _reports.length,
                                itemBuilder: (context, index) {
                                  final report = _reports[index];
                                  final isSelected = _selectedReport?.id == report.id;
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: isSelected ? ColorStyle.topazyw4 : Colors.white,
                                    elevation: isSelected ? 4 : 1,
                                    child: ListTile(
                                      onTap: () => setState(() => _selectedReport = report),
                                      leading: CircleAvatar(
                                        backgroundColor: report.status.color.withValues(alpha: 0.2),
                                        child: Icon(
                                          report.reportType.icon,
                                          color: report.status.color,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        report.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? ColorStyle.topazyw3 : Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report.residentName ?? 'Unknown Resident',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: ColorStyle.slategrey,
                                            ),
                                          ),
                                          Text(
                                            report.reportCode,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: ColorStyle.paleslate,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Chip(
                                        label: Text(
                                          report.status.label,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: report.status.color.withValues(alpha: 0.1),
                                        labelStyle: TextStyle(
                                          color: report.status.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
          
          // RIGHT PANEL - Details
          Expanded(
            flex: 3,
            child: _selectedReport == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_outlined,
                          size: 100,
                          color: ColorStyle.platinum,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select a report to view details',
                          style: TextStyle(
                            color: ColorStyle.slategrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDetailPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, ReportStatus? status, Color color) {
    final isSelected = _statusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = status);
        _loadReports();
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : ColorStyle.slategrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    final report = _selectedReport!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  report.status.color.withValues(alpha: 0.2),
                  report.status.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: report.status.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      report.reportCode,
                      style: TextStyle(
                        color: ColorStyle.slategrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.topazyw3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(report.reportType.icon, size: 16, color: ColorStyle.slategrey),
                    const SizedBox(width: 6),
                    Text(
                      report.reportType.label,
                      style: TextStyle(color: ColorStyle.slategrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reporter Info Card
                  _buildInfoCard(
                    'Reporter Information',
                    Icons.person,
                    [
                      _buildInfoRow('Name', report.residentName ?? 'N/A'),
                      _buildInfoRow('Phone', report.residentPhone ?? 'N/A'),
                      _buildInfoRow('Address', report.residentAddress ?? 'N/A'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Report Details
                  _buildInfoCard(
                    'Report Details',
                    Icons.description,
                    [
                      _buildInfoRow('Description', report.description, isMultiline: true),
                      if (report.location != null)
                        _buildInfoRow('Location', report.location!),
                      _buildInfoRow(
                        'Submitted', 
                        DateFormat('MMM dd, yyyy • hh:mm a').format(report.submittedAt ?? DateTime.now()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Photos
                  if (report.photoUrls.isNotEmpty) ...[
                    const Text(
                      'Attached Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorStyle.topazyw3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photoUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullImage(report.photoUrls[index]),
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(report.photoUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Admin Feedback
                  if (report.adminFeedback != null) ...[
                    _buildInfoCard(
                      'Admin Feedback',
                      Icons.feedback,
                      [
                        Text(
                          report.adminFeedback!,
                          style: TextStyle(
                            color: ColorStyle.slategrey,
                            height: 1.5,
                          ),
                        ),
                      ],
                      color: Colors.amber.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Timeline
                  _buildTimeline(report),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _showStatusUpdateDialog,
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.update),
                    label: Text(_isUpdating ? 'Updating...' : 'Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorStyle.topazyw3,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: color == null ? Border.all(color: ColorStyle.platinum) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ColorStyle.topazyw3),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorStyle.paleslate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorStyle.slategrey,
                    height: 1.5,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorStyle.paleslate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorStyle.slategrey,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTimeline(ServiceReportModel report) {
    final events = <Map<String, dynamic>>[];
    
    if (report.submittedAt != null) {
      events.add({
        'status': 'Submitted',
        'date': report.submittedAt,
        'color': Colors.grey,
        'icon': Icons.send,
      });
    }
    if (report.receivedAt != null) {
      events.add({
        'status': 'Received',
        'date': report.receivedAt,
        'color': Colors.blue,
        'icon': Icons.inbox,
      });
    }
    if (report.investigatingAt != null) {
      events.add({
        'status': 'Investigating',
        'date': report.investigatingAt,
        'color': Colors.orange,
        'icon': Icons.search,
      });
    }
    if (report.resolvedAt != null) {
      events.add({
        'status': 'Resolved',
        'date': report.resolvedAt,
        'color': Colors.green,
        'icon': Icons.check_circle,
      });
    }
    if (report.closedAt != null) {
      events.add({
        'status': 'Closed',
        'date': report.closedAt,
        'color': Colors.purple,
        'icon': Icons.done_all,
      });
    }

    if (events.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorStyle.topazyw3,
          ),
        ),
        const SizedBox(height: 12),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: event['color'].withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      event['icon'],
                      size: 16,
                      color: event['color'],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: ColorStyle.platinum,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['status'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: event['color'],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(event['date']),
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorStyle.paleslate,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}