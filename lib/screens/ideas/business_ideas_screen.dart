import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/idea_card.dart';
import '../../widgets/illustration_banner.dart';
import 'business_idea_detail_screen.dart';

class BusinessIdeasScreen extends StatefulWidget {
  const BusinessIdeasScreen({super.key});

  @override
  State<BusinessIdeasScreen> createState() => _BusinessIdeasScreenState();
}

class _BusinessIdeasScreenState extends State<BusinessIdeasScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Toutes';
  bool _onlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();

    final categories = ['Toutes', ...{for (final idea in content.businessIdeas) idea.category}.toList()..sort()];

    var ideas = content.businessIdeas.where((idea) {
      if (_selectedCategory != 'Toutes' && idea.category != _selectedCategory) {
        return false;
      }
      if (_onlyFavorites && !progress.isFavoriteIdea(idea.id)) {
        return false;
      }
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        return idea.title.toLowerCase().contains(q) || idea.pitch.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idées business'),
        actions: [
          IconButton(
            tooltip: 'Favoris',
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
            icon: Icon(
              _onlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _onlyFavorites ? AppColors.danger : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const IllustrationBanner(asset: 'assets/images/illustration_ideas.svg'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une idée...',
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
            child: ideas.isEmpty
                ? Center(
                    child: Text(
                      'Aucune idée ne correspond à votre recherche.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: ideas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final idea = ideas[index];
                      return StaggerFadeSlide(
                        index: index,
                        child: IdeaCard(
                          idea: idea,
                          isFavorite: progress.isFavoriteIdea(idea.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BusinessIdeaDetailScreen(ideaId: idea.id)),
                          ),
                          onToggleFavorite: () => progress.toggleFavoriteIdea(idea.id),
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
