import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  State<AddHouseholdPage> createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  // Household fields
  final _purokController = TextEditingController();
  final _streetController = TextEditingController();
  
  // Head fields
  final _headFirstNameController = TextEditingController();
  final _headLastNameController = TextEditingController();
  final _headMiddleNameController = TextEditingController();
  final _headPhoneController = TextEditingController();
  
  // Temporary members list
  final List<Map<String, dynamic>> _tempMembers = [];
  
  bool _isLoading = false;

  void _addTempMember() {
    showDialog(
      context: context,
      builder: (context) {
        final firstNameController = TextEditingController();
        final lastNameController = TextEditingController();
        final middleNameController = TextEditingController();
        final contactController = TextEditingController();
        final otherRelationController = TextEditingController();
        
        String? selectedRelationship;
        bool isOther = false;
        
        final List<String> relationships = ['Wife', 'Husband', 'Son', 'Daughter', 'Baby', 'Parent', 'Renter', 'Other'];
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Family Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: firstNameController,
                            decoration: const InputDecoration(labelText: 'First Name *'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lastNameController,
                            decoration: const InputDecoration(labelText: 'Last Name *'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: middleNameController,
                      decoration: const InputDecoration(labelText: 'Middle Name'),
                    ),
                    const SizedBox(height: 12),
                    // Relationship Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship *',
                        border: OutlineInputBorder(),
                      ),
                      items: relationships.map((r) => 
                        DropdownMenuItem(value: r, child: Text(r))
                      ).toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedRelationship = v;
                          isOther = v == 'Other';
                        });
                      },
                    ),
                    if (isOther) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: otherRelationController,
                        decoration: const InputDecoration(
                          labelText: 'Specify Relationship *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Contact Number Field
                    TextField(
                      controller: contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number (Optional)',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (firstNameController.text.isNotEmpty && 
                        lastNameController.text.isNotEmpty &&
                        selectedRelationship != null) {
                      
                      final relationship = isOther 
                          ? otherRelationController.text.trim()
                          : selectedRelationship!;
                          
                      setState(() {
                        _tempMembers.add({
                          'first_name': firstNameController.text.trim(),
                          'last_name': lastNameController.text.trim(),
                          'middle_name': middleNameController.text.trim(),
                          'relationship': relationship,
                          'contact_number': contactController.text.trim(),
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ColorStyle.topazyw3),
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _removeTempMember(int index) {
    setState(() {
      _tempMembers.removeAt(index);
    });
  }

  Future<void> _saveHousehold() async {
    if (!_formKey.currentState!.validate()) return;
    if (_headFirstNameController.text.isEmpty || _headLastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter head of household name'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Insert Household
      final householdResponse = await supabase
          .from('households')
          .insert({
            'purok': _purokController.text.trim(),
            'street': _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
            'barangay': 'Ulbujan',
            'municipality': 'Calape',
            'province': 'Bohol',
          })
          .select()
          .single();

      final householdId = householdResponse['id'];

      // 2. Insert Head to household_members (NEW TABLE)
      await supabase.from('household_members').insert({
        'household_id': householdId,
        'first_name': _headFirstNameController.text.trim(),
        'last_name': _headLastNameController.text.trim(),
        'middle_name': _headMiddleNameController.text.trim().isEmpty ? null : _headMiddleNameController.text.trim(),
        'contact_number': _headPhoneController.text.trim().isEmpty ? null : _headPhoneController.text.trim(),
        'relationship_to_head': 'Head',
        'is_head': true,
      });

      // 3. Insert Temporary Members to household_members (NEW TABLE)
      for (var member in _tempMembers) {
        await supabase.from('household_members').insert({
          'household_id': householdId,
          'first_name': member['first_name'],
          'last_name': member['last_name'],
          'middle_name': member['middle_name'].isEmpty ? null : member['middle_name'],
          'relationship_to_head': member['relationship'],
          'contact_number': member['contact_number'].isEmpty ? null : member['contact_number'],
          'is_head': false,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Household created with ${_tempMembers.length + 1} members!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw1,
      appBar: AppBar(
        backgroundColor: ColorStyle.topazyw3,
        elevation: 0,
        title: const Text('Register Household', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Household Location with Barangay, Municipal, Province
              _buildSectionTitle('Household Location'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purokController,
                decoration: _inputDecoration('Purok/Zone *', Icons.location_on),
                validator: (val) => val?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _streetController,
                decoration: _inputDecoration('Street (Optional)', Icons.add_road),
              ),
              const SizedBox(height: 16),
              // Barangay, Municipality, Province Display
              Row(
                children: [
                  Expanded(child: _buildReadOnlyField('Barangay', 'Ulbujan')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyField('Municipality', 'Calape')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyField('Province', 'Bohol')),
                ],
              ),
              const SizedBox(height: 24),

              // Head of Household (No Secondary Phone)
              _buildSectionTitle('Head of Household'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _headFirstNameController,
                      decoration: _inputDecoration('First Name *', null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _headLastNameController,
                      decoration: _inputDecoration('Last Name *', null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _headMiddleNameController,
                decoration: _inputDecoration('Middle Name', null),
              ),
              const SizedBox(height: 12),
              // Single Phone Only
              TextFormField(
                controller: _headPhoneController,
                decoration: _inputDecoration('Contact Number', Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              // Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Household Members (${_tempMembers.length})'),
                  ElevatedButton.icon(
                    onPressed: _addTempMember,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorStyle.topazyw3,
                      side: const BorderSide(color: ColorStyle.topazyw3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // List of temporary members
              if (_tempMembers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No additional members yet.\nTap "Add Member" to include family members.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._tempMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorStyle.topazyw3.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: ColorStyle.topazyw3),
                      ),
                      title: Text('${member['first_name']} ${member['last_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member['relationship']),
                          if (member['contact_number'] != null && member['contact_number'].toString().isNotEmpty)
                            Text(
                              member['contact_number'],
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTempMember(index),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHousehold,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorStyle.topazyw3,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('REGISTER HOUSEHOLD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: ColorStyle.topazyw3) : null,
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: ColorStyle.topazyw3, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorStyle.topazyw3)),
      ],
    );
  }

  @override
  void dispose() {
    _purokController.dispose();
    _streetController.dispose();
    _headFirstNameController.dispose();
    _headLastNameController.dispose();
    _headMiddleNameController.dispose();
    _headPhoneController.dispose();
    super.dispose();
  }
}