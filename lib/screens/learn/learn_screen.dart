import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learning_module.dart';
import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/illustration_banner.dart';
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
      body: Column(
        children: [
          const IllustrationBanner(asset: 'assets/images/illustration_learn.svg'),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ModuleList(modules: content.investmentModules, progress: progress),
                _ModuleList(modules: content.entrepreneurshipModules, progress: progress),
              ],
            ),
          ),
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
    final overall = progress.overallProgress(modules);
    final completed = progress.completedModulesCount(modules);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: modules.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _TrackProgressHeader(
            overall: overall,
            completed: completed,
            total: modules.length,
          );
        }
        final module = modules[index - 1];
        return StaggerFadeSlide(
          index: index - 1,
          child: ModuleCard(
            module: module,
            progress: progress.moduleProgress(module),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ModuleDetailScreen(moduleId: module.id)),
            ),
          ),
        );
      },
    );
  }
}

class _TrackProgressHeader extends StatelessWidget {
  final double overall;
  final int completed;
  final int total;

  const _TrackProgressHeader({
    required this.overall,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed sur $total modules terminés',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                AnimatedProgressBar(value: overall, minHeight: 8),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedCount(
            value: overall * 100,
            formatter: (v) => '${v.round()} %',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
