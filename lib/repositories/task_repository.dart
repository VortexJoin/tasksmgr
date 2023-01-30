// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/task_model.dart';

class TaskRepository {
  Future<List<Task>> getTasks({
    DateTime? initialDate,
    DateTime? finalDate,
    DateTime? fixedDate,
    bool showFinished = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final String taksJson = prefs.getString('taksJson') ?? '';
    List<Task> tasks = [];
    tasks = taskFromJson(taksJson);
    //return tasks;

    if (tasks.isNotEmpty) {
      if (fixedDate != null) {
        print('fixedDate');
        return tasks
            .where((tk) =>
                DateFormat('dd/MM/yyyy').format(tk.datatarefa) ==
                DateFormat('dd/MM/yyyy').format(fixedDate))
            .toList();
      } else if (initialDate != null && finalDate == null) {
        print('initialDate');
        initialDate =
            DateTime(initialDate.year, initialDate.month, initialDate.day);

        return tasks
            .where((tk) => tk.datatarefa
                .isBefore(initialDate!.subtract(const Duration(days: 1))))
            .toList();
      } else if (initialDate == null && finalDate != null) {
        finalDate = DateTime(finalDate.year, finalDate.month, finalDate.day);

        print('finalDate');
        return tasks
            .where((tk) =>
                tk.datatarefa.isAfter(finalDate!.add(const Duration(days: 1))))
            .toList();
      } else if (initialDate != null && finalDate != null) {
        finalDate = DateTime(finalDate.year, finalDate.month, finalDate.day);
        initialDate =
            DateTime(initialDate.year, initialDate.month, initialDate.day);
        print('initialDate||finalDate');
        tasks = tasks
            .where((tk) => tk.datatarefa
                .isBefore(initialDate!.subtract(const Duration(days: 1))))
            .toList();

        tasks = tasks
            .where((tk) => (tk.datatarefa
                .isAfter(finalDate!.add(const Duration(days: 1)))))
            .toList();
      }
    }

    // if (!showFinished) {
    //   tasks = tasks.where((tk) => tk.finalizada == true).toList();
    // }

    print(tasks);

    return tasks;
  }

  Future<List<Task>> getTasksToday({bool showFinished = true}) {
    return getTasks(
      fixedDate: DateTime.now(),
      showFinished: showFinished,
    );
  }

  Future<List<Task>> getTasksTomorrow({bool showFinished = true}) {
    return getTasks(
      fixedDate: DateTime.now().add(const Duration(days: 1)),
      showFinished: showFinished,
    );
  }

  Future<List<Task>> getTasksWeek({bool showFinished = true}) {
    final today = DateTime.now();
    var startFilter = DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime endFilter;
    if (startFilter.weekday != DateTime.monday) {
      startFilter =
          startFilter.subtract(Duration(days: (startFilter.weekday - 1)));
    }

    endFilter = startFilter.add(const Duration(days: 7));

    return getTasks(
      finalDate: startFilter,
      initialDate: endFilter,
      showFinished: showFinished,
    );
  }

  Future<void> newTask(String taskDescription, DateTime taskDate) async {
    getTasks().then((value) async {
      value.add(
        Task(
          uuid: const Uuid().v4(),
          descricao: taskDescription,
          datatarefa: taskDate,
          finalizada: false,
        ),
      );
      await saveList(value);
    });
  }

  Future<void> delete(String taskUuid) async {
    getTasks().then((value) {
      if (value.isNotEmpty) {
        value.removeWhere(
            (tk) => tk.uuid.toLowerCase() == taskUuid.toLowerCase());
        saveList(value);
      }
    });
  }

  Future<Task?> getOnlyTask(String uuid) async {
    Task? task;
    getTasks().then((value) {
      for (var tk in value) {
        if (tk.uuid.toLowerCase() == uuid.toLowerCase()) {
          task = tk;
        }
      }
    });
    return task;
  }

  Future<bool> editTask(Task tk) async {
    Task? task = await getOnlyTask(tk.uuid);

    if (task == null) {
      return false;
    } else {
      task = tk;
      await delete(tk.uuid);

      await getTasks().then((value) {
        value.add(tk);
        saveList(value);
        return true;
      }).onError((error, stackTrace) {
        return false;
      });
    }
    return false;
  }

  Future<void> deleteAll() async {
    saveList([]);
  }

  Future<void> checkOrUncheckTask(Task task) async {
    getTasks().then((value) {
      if (value.isNotEmpty) {
        for (var tk in value) {
          if (tk.uuid.toLowerCase() == task.uuid.toLowerCase()) {
            tk.finalizada = !tk.finalizada;
          }
        }
        saveList(value);
      }
    });
  }

  Future<bool> saveList(List<Task> taskList) async {
    final prefs = await SharedPreferences.getInstance();

    print(jsonEncode(taskList));
    return prefs.setString('taksJson', jsonEncode(taskList));
  }

  Future<int> totalTask(
    TaskFilterEnum taskEnum, {
    DateTime? initialDate,
    DateTime? finalDate,
  }) async {
    switch (taskEnum) {
      case TaskFilterEnum.hoje:
        return getTasksToday().then((value) {
          return value.length;
        }).onError((error, stackTrace) {
          return 0;
        });
      case TaskFilterEnum.amanha:
        return getTasksTomorrow().then((value) {
          return value.length;
        }).onError((error, stackTrace) {
          return 0;
        });
      case TaskFilterEnum.semana:
        return getTasksWeek().then((value) {
          return value.length;
        }).onError((error, stackTrace) {
          return 0;
        });
      case TaskFilterEnum.periodo:
        return getTasks(
          initialDate: initialDate,
          finalDate: finalDate,
        ).then((value) {
          return value.length;
        }).onError((error, stackTrace) {
          return 0;
        });
    }
  }
}
