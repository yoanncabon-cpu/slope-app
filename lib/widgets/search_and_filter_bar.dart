import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barre de recherche + filtres par catégorie, partagée entre les écrans
/// "Idées business", "Blog" et "Glossaire".
class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const SearchAndFilterBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: TextField(
            controller: controller,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = category == selectedCategory;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                showCheckmark: false,
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : null,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: selected
                      ? BorderSide.none
                      : BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                onSelected: (_) => onCategorySelected(category),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
