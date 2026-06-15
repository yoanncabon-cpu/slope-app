import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/animations/animations.dart';

class BlogArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const BlogArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final article = content.findBlogArticle(articleId);

    if (article == null) {
      return const Scaffold(body: Center(child: Text('Article introuvable')));
    }

    final color = AppColors.categoryColor(
      article.category == 'Entrepreneuriat' ? 'idee' : 'actions',
    );
    final isFavorite = progress.isFavoriteArticle(article.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.category),
        actions: [
          IconButton(
            onPressed: () => progress.toggleFavoriteArticle(article.id),
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? AppColors.accent : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(mapIcon(article.icon), color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTimeMinutes} min de lecture',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            article.excerpt,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < article.content.length; i++)
            StaggerFadeSlide(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  article.content[i],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
