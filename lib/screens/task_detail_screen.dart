import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/progress_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _showAnswer = false;
  bool _completed = false;
  bool _loading = true;
  final TextEditingController _myAnswerCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _myAnswerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final done = await ProgressService.getCompleted();
    setState(() {
      _completed = done.contains(widget.task.id);
      _loading = false;
    });
  }

  Future<void> _toggleCompleted() async {
    if (_completed) {
      await ProgressService.markUncompleted(widget.task.id);
    } else {
      await ProgressService.markCompleted(widget.task.id);
    }
    setState(() => _completed = !_completed);
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _difficultyLabel(String d) {
    switch (d) {
      case 'easy': return '● Лёгкая';
      case 'medium': return '● Средняя';
      case 'hard': return '● Сложная';
      default: return d;
    }
  }

  void _submit() {
    if (_myAnswerCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напишите ваш ответ перед проверкой')),
      );
      return;
    }
    setState(() {
      _submitted = true;
      _showAnswer = true;
    });
  }

  void _reset() {
    setState(() {
      _submitted = false;
      _showAnswer = false;
      _myAnswerCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final task = widget.task;
    final dColor = _difficultyColor(task.difficulty);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Задача № ${task.id}'),
        backgroundColor: cs.primaryContainer,
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(
                _completed ? Icons.check_circle : Icons.check_circle_outline,
                color: _completed ? Colors.green : null,
              ),
              tooltip: _completed ? 'Снять отметку' : 'Отметить выполненной',
              onPressed: _toggleCompleted,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Шапка задачи ──────────────────────────────────
            Card(
              elevation: 0,
              color: cs.primaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_completed)
                          const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: dColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: dColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            _difficultyLabel(task.difficulty),
                            style: TextStyle(fontSize: 12, color: dColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(fontSize: 12, color: cs.onSecondaryContainer),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Условие ───────────────────────────────────────
            _SectionCard(
              icon: Icons.description,
              title: 'Условие задачи',
              child: Text(task.scenario, style: const TextStyle(fontSize: 15, height: 1.6)),
            ),
            const SizedBox(height: 10),

            // ── Вопросы ───────────────────────────────────────
            _SectionCard(
              icon: Icons.help_outline,
              title: 'Вопросы',
              titleColor: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: task.questions
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(q, style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Поле ввода ─────────────────────────────────────
            if (!_submitted) ...[
              Row(
                children: [
                  const Icon(Icons.edit, size: 18, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text(
                    'Ваш ответ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.indigo.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.withOpacity(0.4)),
                  color: Colors.indigo.withOpacity(0.04),
                ),
                child: TextField(
                  controller: _myAnswerCtrl,
                  maxLines: 8,
                  minLines: 5,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: 'Напишите здесь свой ответ на вопросы задачи...',
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Проверить ответ', style: TextStyle(fontSize: 16)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAnswer = !_showAnswer),
                  icon: Icon(_showAnswer ? Icons.visibility_off : Icons.lightbulb_outline),
                  label: Text(_showAnswer ? 'Скрыть подсказку' : 'Посмотреть ответ без проверки'),
                ),
              ),
            ],

            // ── После нажатия «Проверить» ──────────────────────
            if (_submitted) ...[
              // Мой ответ (не редактируемый)
              _SectionCard(
                icon: Icons.person,
                title: 'Ваш ответ',
                titleColor: Colors.indigo,
                backgroundColor: Colors.indigo.withOpacity(0.04),
                borderColor: Colors.indigo.withOpacity(0.4),
                child: Text(
                  _myAnswerCtrl.text.trim(),
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Правильный ответ ───────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showAnswer
                  ? Column(
                      children: [
                        _SectionCard(
                          icon: Icons.check_circle,
                          title: 'Правильный ответ',
                          titleColor: Colors.green.shade700,
                          backgroundColor: Colors.green.withOpacity(0.05),
                          borderColor: Colors.green.withOpacity(0.35),
                          child: Text(task.answer, style: const TextStyle(fontSize: 14, height: 1.7)),
                        ),
                        const SizedBox(height: 14),

                        // Самооценка
                        if (_submitted) ...[
                          Text(
                            'Оцените свой ответ:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _reset,
                                  icon: const Icon(Icons.refresh, color: Colors.orange),
                                  label: const Text('Попробовать снова',
                                      style: TextStyle(color: Colors.orange)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.orange),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    await ProgressService.markCompleted(task.id);
                                    setState(() => _completed = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✓ Задача отмечена выполненной!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.done_all),
                                  label: const Text('Верно!'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? titleColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.titleColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: titleColor ?? cs.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: titleColor ?? cs.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
