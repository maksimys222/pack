import 'package:flutter/material.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String filterCategory;
  final String filterDifficulty;

  const TaskListScreen({
    super.key,
    this.filterCategory = 'Все задачи',
    this.filterDifficulty = '',
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  Set<int> _completed = {};
  String _searchQuery = '';
  bool _showCompletedOnly = false;
  late String _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.filterCategory;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final c = await ProgressService.getCompleted();
    setState(() => _completed = c);
  }

  List<Task> get _filtered {
    List<Task> tasks = kTasks;

    if (widget.filterDifficulty.isNotEmpty) {
      tasks = tasks.where((t) => t.difficulty == widget.filterDifficulty).toList();
    } else if (_currentCategory != 'Все задачи') {
      tasks = tasks.where((t) => t.category == _currentCategory).toList();
    }

    if (_showCompletedOnly) {
      tasks = tasks.where((t) => _completed.contains(t.id)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      tasks = tasks
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.scenario.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))
          .toList();
    }

    return tasks;
  }

  Color _difficultyColor(String d) {
    switch (d) {
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

  String _difficultyLabel(String d) {
    switch (d) {
      case 'easy':
        return 'Лёгкая';
      case 'medium':
        return 'Средняя';
      case 'hard':
        return 'Сложная';
      default:
        return d;
    }
  }

  String get _title {
    if (widget.filterDifficulty.isNotEmpty) {
      return _difficultyLabel(widget.filterDifficulty) + ' задачи';
    }
    return _currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tasks = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: cs.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(
              _showCompletedOnly ? Icons.check_circle : Icons.check_circle_outline,
              color: _showCompletedOnly ? Colors.green : null,
            ),
            tooltip: 'Только выполненные',
            onPressed: () =>
                setState(() => _showCompletedOnly = !_showCompletedOnly),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск по задачам...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (widget.filterDifficulty.isEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: kCategories
                        .map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(cat == 'Все задачи' ? 'Все' : cat),
                                selected: _currentCategory == cat,
                                onSelected: (_) =>
                                    setState(() => _currentCategory = cat),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Задачи не найдены',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                final task = tasks[i];
                final done = _completed.contains(task.id);
                final dColor = _difficultyColor(task.difficulty);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: done
                          ? Colors.green.withOpacity(0.5)
                          : cs.outlineVariant,
                    ),
                  ),
                  color: done
                      ? Colors.green.withOpacity(0.05)
                      : cs.surface,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(task: task),
                        ),
                      );
                      _loadProgress();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Number badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: done
                                  ? Colors.green
                                  : cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : Text(
                                      '${task.id}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: dColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: dColor.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        _difficultyLabel(task.difficulty),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: dColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        task.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        color: cs.surfaceContainerLow,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          top: false,
          child: Text(
            'Показано: ${tasks.length} задач • Выполнено: ${tasks.where((t) => _completed.contains(t.id)).length}',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
