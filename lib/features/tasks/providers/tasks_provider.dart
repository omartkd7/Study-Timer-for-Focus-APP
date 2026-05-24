import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regain/shared/models/models.dart';
import 'package:regain/core/constants/app_constants.dart';

class TasksNotifier extends StateNotifier<List<StudyTask>> {
  TasksNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(AppConstants.keyTasks) ?? [];
    state = raw.map((s) => StudyTask.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(AppConstants.keyTasks, state.map((t) => jsonEncode(t.toJson())).toList());
  }

  Future<void> addTask(StudyTask task) async {
    state = [task, ...state];
    await _save();
  }

  Future<void> toggleDone(String id) async {
    state = state.map((t) => t.id == id ? t.copyWith(isDone: !t.isDone) : t).toList();
    await _save();
  }

  Future<void> incrementPomodoro(String id) async {
    state = state.map((t) {
      if (t.id == id) {
        final next = t.completedPomodoros + 1;
        return t.copyWith(
          completedPomodoros: next,
          isDone: next >= t.estimatedPomodoros,
        );
      }
      return t;
    }).toList();
    await _save();
  }

  Future<void> deleteTask(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _save();
  }

  Future<void> clearCompleted() async {
    state = state.where((t) => !t.isDone).toList();
    await _save();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<StudyTask>>((_) => TasksNotifier());
