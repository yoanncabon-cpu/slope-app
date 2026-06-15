import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/glossary_term.dart';
import '../../providers/content_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/search_and_filter_bar.dart';

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
          SearchAndFilterBar(
            controller: _searchController,
            hintText: 'Rechercher un terme...',
            query: _query,
            onQueryChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            categories: categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) => setState(() => _selectedCategory = category),
          ),
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
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
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
            ),
          ],
        ),
      ),
    );
  }
}
