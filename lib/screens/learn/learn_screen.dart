import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learning_module.dart';
import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/module_card.dart';
import 'module_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  final LearningTrack? initialTrack;

  const LearnScreen({super.key, this.initialTrack});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTrack == LearningTrack.entrepreneurship ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprendre'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Investissement'),
            Tab(text: 'Entrepreneuriat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ModuleList(modules: content.investmentModules, progress: progress),
          _ModuleList(modules: content.entrepreneurshipModules, progress: progress),
        ],
      ),
    );
  }
}

class _ModuleList extends StatelessWidget {
  final List<LearningModule> modules;
  final ProgressProvider progress;

  const _ModuleList({required this.modules, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: modules.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final module = modules[index];
        return ModuleCard(
          module: module,
          progress: progress.moduleProgress(module),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ModuleDetailScreen(moduleId: module.id)),
          ),
        );
      },
    );
  }
}
