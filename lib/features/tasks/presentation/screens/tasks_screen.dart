import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/tasks/providers/tasks_provider.dart';
import 'package:regain/features/timer/providers/timer_provider.dart';
import 'package:regain/shared/models/models.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final pending = tasks.where((t) => !t.isDone).toList();
    final done    = tasks.where((t) => t.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study tasks'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.go('/timer')),
        actions: [
          if (done.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(tasksProvider.notifier).clearCompleted(),
              child: const Text('Clear done', style: TextStyle(color: AppColors.accent, fontSize: 13)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTask(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: tasks.isEmpty
          ? _EmptyState(onAdd: () => _showAddTask(context, ref))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                if (pending.isNotEmpty) ...[
                  _SectionLabel('To do (${pending.length})'),
                  ...pending.map((t) => _TaskCard(task: t)),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionLabel('Completed (${done.length})'),
                  ...done.map((t) => _TaskCard(task: t)),
                ],
              ],
            ),
    );
  }

  void _showAddTask(BuildContext context, WidgetRef ref) {
    final titleCtrl   = TextEditingController();
    String subject    = 'Study';
    int pomodoros     = 1;
    const subjects    = ['Study', 'Math', 'Science', 'Language', 'Coding', 'Reading', 'History', 'Art'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New task', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Task title...'),
            ),
            const SizedBox(height: 14),
            // Subject picker
            const Text('Subject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: subjects.map((s) {
              final sel = s == subject;
              return GestureDetector(
                onTap: () => setState(() => subject = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.primary : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12, color: sel ? AppColors.primary : null, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),
            // Pomodoros
            Row(children: [
              const Expanded(child: Text('Estimated pomodoros', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: pomodoros > 1 ? () => setState(() => pomodoros--) : null),
              Text('$pomodoros', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.add, size: 18), onPressed: pomodoros < 10 ? () => setState(() => pomodoros++) : null),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  ref.read(tasksProvider.notifier).addTask(StudyTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text.trim(),
                    subject: subject,
                    estimatedPomodoros: pomodoros,
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Add task'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final StudyTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final isActive   = timerState.activeTaskId == task.id;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => ref.read(tasksProvider.notifier).deleteTask(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: AppColors.primary.withOpacity(0.4)) : null,
        ),
        child: Row(children: [
          // Checkbox
          GestureDetector(
            onTap: () => ref.read(tasksProvider.notifier).toggleDone(task.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.success.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: task.isDone ? AppColors.success : Colors.grey.withOpacity(0.4), width: 1.5),
              ),
              child: task.isDone ? const Icon(Icons.check, size: 13, color: AppColors.success) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : null,
              ),
            ),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(task.subject, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
              ),
              const SizedBox(width: 6),
              // Pomodoro dots
              ...List.generate(task.estimatedPomodoros, (i) => Container(
                margin: const EdgeInsets.only(right: 3),
                width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < task.completedPomodoros ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                ),
              )),
            ]),
          ])),
          // Focus button
          if (!task.isDone)
            GestureDetector(
              onTap: () {
                if (isActive) {
                  ref.read(timerProvider.notifier).clearTask();
                } else {
                  ref.read(timerProvider.notifier).setActiveTask(task.id, task.subject);
                }
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(isActive ? 'Active' : 'Focus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.primary)),
              ),
            ),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.checklist_rounded, size: 56, color: Colors.grey.withOpacity(0.3)),
    const SizedBox(height: 16),
    Text('No tasks yet', style: TextStyle(fontSize: 16, color: Colors.grey.withOpacity(0.5))),
    const SizedBox(height: 8),
    TextButton(onPressed: onAdd, child: const Text('Add your first task', style: TextStyle(color: AppColors.primary))),
  ]));
}
