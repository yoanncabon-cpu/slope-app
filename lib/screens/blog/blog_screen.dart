import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/blog_article_card.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/search_and_filter_bar.dart';
import 'blog_article_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
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

    final categories = [
      'Toutes',
      ...{for (final article in content.blogArticles) article.category}.toList()..sort(),
    ];

    var articles = content.blogArticles.where((article) {
      if (_selectedCategory != 'Toutes' && article.category != _selectedCategory) {
        return false;
      }
      if (_onlyFavorites && !progress.isFavoriteArticle(article.id)) {
        return false;
      }
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        return article.title.toLowerCase().contains(q) || article.excerpt.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          IconButton(
            tooltip: 'Favoris',
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
            icon: Icon(
              _onlyFavorites ? Icons.bookmark : Icons.bookmark_border,
              color: _onlyFavorites ? AppColors.accent : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const IllustrationBanner(asset: 'assets/images/illustration_blog.svg'),
          SearchAndFilterBar(
            controller: _searchController,
            hintText: 'Rechercher un article...',
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
            child: articles.isEmpty
                ? Center(
                    child: Text(
                      'Aucun article ne correspond à votre recherche.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: articles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return StaggerFadeSlide(
                        index: index,
                        child: BlogArticleCard(
                          article: article,
                          isFavorite: progress.isFavoriteArticle(article.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlogArticleDetailScreen(articleId: article.id),
                            ),
                          ),
                          onToggleFavorite: () => progress.toggleFavoriteArticle(article.id),
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
