import 'package:flutter/material.dart';
import '../model/chat_filter_model.dart';

class ChatFilterChips extends StatelessWidget {
  final List<ChatFilter> filters;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ChatFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.id == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.icon,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter.id),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
            ),
          );
        },
      ),
    );
  }
}