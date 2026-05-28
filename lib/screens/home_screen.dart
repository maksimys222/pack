import 'package:flutter/material.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<int> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await ProgressService.getCompleted();
    setState(() {
      _completed = completed;
      _loading = false;
    });
  }

  // Categories excluding 'Все задачи'
  List<String> get _categories =>
      kCategories.where((c) => c != 'Все задачи').toList();

  int _countByCategory(String category) =>
      kTasks.where((t) => t.category == category).length;

  int _completedByCategory(String category) =>
      kTasks.where((t) => t.category == category && _completed.contains(t.id)).length;

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = kTasks.length;
    final done = _completed.length;
    final percent = total > 0 ? done / total : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary,
                            cs.primaryContainer,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'УПК РФ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '100 задач',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.white30,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$done / $total',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    titlePadding: EdgeInsets.zero,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Сбросить прогресс',
                      onPressed: _confirmReset,
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Quick stats row
                      Row(
                        children: [
                          _StatCard(
                            label: 'Выполнено',
                            value: '$done',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            label: 'Осталось',
                            value: '${total - done}',
                            icon: Icons.pending,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            label: 'Прогресс',
                            value: '${(percent * 100).toInt()}%',
                            icon: Icons.trending_up,
                            color: cs.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // All tasks button
                      FilledButton.icon(
                        onPressed: () => _openList('Все задачи'),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Все 100 задач'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'По категориям',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Category cards
                      ..._categories.map((cat) {
                        final count = _countByCategory(cat);
                        final comp = _completedByCategory(cat);
                        final p = count > 0 ? comp / count : 0.0;
                        return _CategoryCard(
                          category: cat,
                          total: count,
                          completed: comp,
                          progress: p,
                          onTap: () => _openList(cat),
                        );
                      }),

                      const SizedBox(height: 20),
                      Text(
                        'По сложности',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _DifficultyChip(
                            label: 'Лёгкие',
                            color: Colors.green,
                            count: kTasks
                                .where((t) => t.difficulty == 'easy')
                                .length,
                            onTap: () => _openByDifficulty('easy'),
                          ),
                          const SizedBox(width: 8),
                          _DifficultyChip(
                            label: 'Средние',
                            color: Colors.orange,
                            count: kTasks
                                .where((t) => t.difficulty == 'medium')
                                .length,
                            onTap: () => _openByDifficulty('medium'),
                          ),
                          const SizedBox(width: 8),
                          _DifficultyChip(
                            label: 'Сложные',
                            color: Colors.red,
                            count: kTasks
                                .where((t) => t.difficulty == 'hard')
                                .length,
                            onTap: () => _openByDifficulty('hard'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  void _openList(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskListScreen(filterCategory: category),
      ),
    );
    _loadProgress();
  }

  void _openByDifficulty(String difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskListScreen(filterDifficulty: difficulty),
      ),
    );
    _loadProgress();
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text('Все отметки о выполнении будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              await ProgressService.resetAll();
              Navigator.pop(ctx);
              _loadProgress();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int total;
  final int completed;
  final double progress;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.total,
    required this.completed,
    required this.progress,
    required this.onTap,
  });

  IconData _iconFor(String cat) {
    switch (cat) {
      case 'Подсудность':
        return Icons.account_balance;
      case 'Основания ПС':
        return Icons.gavel;
      case 'Сроки (не под стражей)':
        return Icons.timer;
      case 'Сроки (под стражей)':
        return Icons.lock_clock;
      case 'Мировой судья':
        return Icons.balance;
      case 'Поиск ошибок':
        return Icons.search;
      case 'Составление постановления':
        return Icons.edit_document;
      case 'Комплексные задачи':
        return Icons.psychology;
      default:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(category), color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completed/$total',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
