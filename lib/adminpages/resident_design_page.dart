import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class EnhancedPurokStats extends StatelessWidget {
  final Map<String, int> purokCounts;
  final String currentFilter;
  final Function(String) onPurokSelected;

  const EnhancedPurokStats({
    super.key,
    required this.purokCounts,
    required this.currentFilter,
    required this.onPurokSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (purokCounts.isEmpty) return const SizedBox.shrink();

    // Sort puroks numerically
    final sortedPuroks = purokCounts.entries.toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_city, color: ColorStyle.topazyw3, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Residents per Purok',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.topazyw3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sortedPuroks.length} Puroks',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.topazyw3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 🔹 HORIZONTAL SCROLLABLE - kahit 50 puroks kaya!
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedPuroks.length,
              padding: const EdgeInsets.only(right: 24),
              itemBuilder: (context, index) {
                final entry = sortedPuroks[index];
                final isSelected = currentFilter == entry.key;

                return GestureDetector(
                  onTap: () => onPurokSelected(entry.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? ColorStyle.topazyw3 
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected 
                            ? ColorStyle.topazyw3 
                            : ColorStyle.topazyw3.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          size: 16,
                          color: isSelected ? Colors.white : ColorStyle.topazyw3,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Purok ${entry.key}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withValues(alpha: 0.2)
                                : ColorStyle.topazyw3.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : ColorStyle.topazyw3,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchAndFilter extends StatelessWidget {
  final List<String> purokList;
  final String currentFilter;
  final Function(String) onSearchChanged;
  final Function(String?) onFilterChanged;

  const SearchAndFilter({
    super.key,
    required this.purokList,
    required this.currentFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Determine current dropdown value
    String? selectedDropdownValue;
    if (currentFilter.isEmpty) {
      selectedDropdownValue = 'All';
    } else if (purokList.contains(currentFilter)) {
      selectedDropdownValue = 'Purok $currentFilter';
    } else {
      selectedDropdownValue = 'All';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search name, phone...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.95),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 🔹 FILTER DROPDOWN (replaces counter)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDropdownValue,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list, color: ColorStyle.topazyw3),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'All',
                      child: Text('All Residents'),
                    ),
                    ...purokList.map((purok) {
                      return DropdownMenuItem(
                        value: 'Purok $purok',
                        child: Text('Purok $purok'),
                      );
                    // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value == 'All') {
                      onFilterChanged('');
                    } else if (value != null && value.startsWith('Purok ')) {
                      final purokNum = value.replaceFirst('Purok ', '');
                      onFilterChanged(purokNum);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}