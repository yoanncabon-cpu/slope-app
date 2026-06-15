import 'package:flutter/foundation.dart';

import '../data/content_repository.dart';
import '../models/blog_article.dart';
import '../models/business_idea.dart';
import '../models/glossary_term.dart';
import '../models/learning_module.dart';

/// Fournit l'ensemble du contenu pédagogique et des idées business,
/// chargé une seule fois depuis les assets JSON.
class ContentProvider extends ChangeNotifier {
  final ContentRepository _repository;

  ContentProvider({ContentRepository? repository})
      : _repository = repository ?? ContentRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<LearningModule> _investmentModules = [];
  List<LearningModule> _entrepreneurshipModules = [];
  List<BusinessIdea> _businessIdeas = [];
  List<GlossaryTerm> _glossary = [];
  List<BlogArticle> _blogArticles = [];

  List<LearningModule> get investmentModules => _investmentModules;
  List<LearningModule> get entrepreneurshipModules => _entrepreneurshipModules;
  List<BusinessIdea> get businessIdeas => _businessIdeas;
  List<GlossaryTerm> get glossary => _glossary;
  List<BlogArticle> get blogArticles => _blogArticles;

  List<LearningModule> get allModules => [
        ..._investmentModules,
        ..._entrepreneurshipModules,
      ];

  Future<void> load() async {
    final results = await Future.wait([
      _repository.loadInvestmentModules(),
      _repository.loadEntrepreneurshipModules(),
      _repository.loadBusinessIdeas(),
      _repository.loadGlossary(),
      _repository.loadBlogArticles(),
    ]);

    _investmentModules = results[0] as List<LearningModule>;
    _entrepreneurshipModules = results[1] as List<LearningModule>;
    _businessIdeas = results[2] as List<BusinessIdea>;
    _glossary = results[3] as List<GlossaryTerm>;
    _blogArticles = results[4] as List<BlogArticle>;

    _isLoading = false;
    notifyListeners();
  }

  LearningModule? findModule(String id) {
    for (final module in allModules) {
      if (module.id == id) return module;
    }
    return null;
  }

  BusinessIdea? findBusinessIdea(String id) {
    for (final idea in _businessIdeas) {
      if (idea.id == id) return idea;
    }
    return null;
  }

  BlogArticle? findBlogArticle(String id) {
    for (final article in _blogArticles) {
      if (article.id == id) return article;
    }
    return null;
  }

  int get totalLessons =>
      allModules.fold(0, (sum, m) => sum + m.lessons.length);
}
