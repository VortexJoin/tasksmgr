// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasksmgr/extensions/extension_date_time.dart';
import 'package:uuid/uuid.dart';

import '../model/task_model.dart';

class TaskRepository {
  Future<List<Task>> getTasks({
    DateTime? initialDate,
    DateTime? finalDate,
    DateTime? fixedDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final String taksJson = prefs.getString('taksJson') ?? '';
    //  print('JSON==$taksJson');
    List<Task> tasks = [];
    if (taksJson.isNotEmpty) {
      tasks = taskFromJson(taksJson);
    } else {
      return [];
    }

    if (fixedDate != null) {
      return tasks
          .where((tk) =>
              DateFormat('dd/MM/yyyy').format(tk.datatarefa) ==
              DateFormat('dd/MM/yyyy').format(fixedDate))
          .toList();
    } else if (initialDate != null && finalDate == null) {
      initialDate =
          DateTime(initialDate.year, initialDate.month, initialDate.day);

      return tasks
          .where((tk) => tk.datatarefa
              .isBefore(initialDate!.subtract(const Duration(days: 1))))
          .toList();
    } else if (initialDate == null && finalDate != null) {
      finalDate = DateTime(finalDate.year, finalDate.month, finalDate.day);

      return tasks
          .where((tk) =>
              tk.datatarefa.isAfter(finalDate!.add(const Duration(days: 1))))
          .toList();
    } else if (initialDate != null && finalDate != null) {
      finalDate = DateTime(finalDate.year, finalDate.month, finalDate.day);
      initialDate =
          DateTime(initialDate.year, initialDate.month, initialDate.day);

      tasks = tasks
          .where((tk) =>
              tk.datatarefa.isBefore(finalDate!.add(const Duration(days: 1))))
          .toList();

      tasks = tasks
          .where((tk) => (tk.datatarefa
              .isAfter(initialDate!.subtract(const Duration(days: 1)))))
          .toList();
    }

    tasks.sort((a, b) => a.datatarefa.compareTo(b.datatarefa));

    return tasks;
  }

  Future<List<Task>> getTasksToday() {
    return getTasks(
      fixedDate: DateTime.now(),
    );
  }

  Future<List<Task>> getTasksTomorrow() {
    return getTasks(
      fixedDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  Future<List<Task>> getTasksWeek() {
    final today = DateTime.now();
    var startFilter = DateTime(today.year, today.month, today.day, 0, 0, 0);
    if (startFilter.weekday != DateTime.monday) {
      startFilter =
          startFilter.subtract(Duration(days: (startFilter.weekday - 1)));
    }

    // ignore: unused_local_variable
    DateTime endFilter = startFilter.add(const Duration(days: 7));

    // return getTasks(
    //   finalDate: endFilter,
    //   initialDate: startFilter,
    // );

    return getTasks(
      initialDate: DateTime.now().firstDayOfWeek,
      finalDate: DateTime.now().lastDayOfWeek,
    );
  }

  Future<List<Task>> getTasksMonth() {
    return getTasks(
      initialDate: DateTime.now().fisrtDayOfMonth,
      finalDate: DateTime.now().lastDayOfMonth,
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
    await getTasks().then((value) {
      for (var tk in value) {
        if (tk.uuid.toLowerCase() == task.uuid.toLowerCase()) {
          tk.finalizada = !tk.finalizada;
        }
      }
      saveList(value);
    });
  }

  Future<bool> saveList(List<Task> taskList) async {
    final prefs = await SharedPreferences.getInstance();
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
      case TaskFilterEnum.mes:
        return getTasksMonth().then((value) {
          return value.length;
        }).onError((error, stackTrace) {
          return 0;
        });
    }
  }
}
