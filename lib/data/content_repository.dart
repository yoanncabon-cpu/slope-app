import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/business_idea.dart';
import '../models/glossary_term.dart';
import '../models/learning_module.dart';

/// Charge le contenu statique de l'application depuis les fichiers JSON
/// embarqués dans les assets.
class ContentRepository {
  Future<List<LearningModule>> loadInvestmentModules() async {
    return _loadModules(
      'assets/data/investment_modules.json',
      LearningTrack.investment,
    );
  }

  Future<List<LearningModule>> loadEntrepreneurshipModules() async {
    return _loadModules(
      'assets/data/entrepreneurship_modules.json',
      LearningTrack.entrepreneurship,
    );
  }

  Future<List<LearningModule>> _loadModules(
    String path,
    LearningTrack track,
  ) async {
    final raw = await rootBundle.loadString(path);
    final list = json.decode(raw) as List;
    return list
        .map((e) => LearningModule.fromJson(e as Map<String, dynamic>, track))
        .toList();
  }

  Future<List<BusinessIdea>> loadBusinessIdeas() async {
    final raw = await rootBundle.loadString('assets/data/business_ideas.json');
    final list = json.decode(raw) as List;
    return list
        .map((e) => BusinessIdea.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GlossaryTerm>> loadGlossary() async {
    final raw = await rootBundle.loadString('assets/data/glossary.json');
    final list = json.decode(raw) as List;
    return list
        .map((e) => GlossaryTerm.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
