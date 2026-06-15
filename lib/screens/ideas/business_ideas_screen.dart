import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/idea_card.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/search_and_filter_bar.dart';
import 'business_idea_detail_screen.dart';
import 'business_match_quiz_screen.dart';

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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: StaggerFadeSlide(index: 0, child: _BusinessMatchCtaCard()),
          ),
          SearchAndFilterBar(
            controller: _searchController,
            hintText: 'Rechercher une idée...',
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

class _BusinessMatchCtaCard extends StatelessWidget {
  const _BusinessMatchCtaCard();

  @override
  Widget build(BuildContext context) {
    return TapTilt(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BusinessMatchQuizScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.quiz, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quel projet pour moi ?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Répondez à 5 questions pour des recommandations personnalisées',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
