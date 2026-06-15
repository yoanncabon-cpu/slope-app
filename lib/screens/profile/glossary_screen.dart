import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/glossary_term.dart';
import '../../providers/content_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Toutes';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final categories = ['Toutes', ...{for (final term in content.glossary) term.category}.toList()..sort()];

    final terms = content.glossary.where((term) {
      if (_selectedCategory != 'Toutes' && term.category != _selectedCategory) {
        return false;
      }
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        return term.term.toLowerCase().contains(q) || term.definition.toLowerCase().contains(q);
      }
      return true;
    }).toList()
      ..sort((a, b) => a.term.compareTo(b.term));

    return Scaffold(
      appBar: AppBar(title: const Text('Glossaire')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un terme...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
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
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: terms.isEmpty
                ? Center(
                    child: Text(
                      'Aucun terme ne correspond à votre recherche.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: terms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => StaggerFadeSlide(
                      index: index,
                      child: _TermCard(term: terms[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  final GlossaryTerm term;

  const _TermCard({required this.term});

  @override
  Widget build(BuildContext context) {
    final color = term.category == 'Investissement'
        ? AppColors.categoryColor('actions')
        : AppColors.categoryColor('idee');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(term.term, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    term.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              term.definition,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
