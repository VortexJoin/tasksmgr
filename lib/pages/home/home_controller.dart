import 'package:flutter/material.dart';

import '../../model/task_model.dart';
import '../../repositories/task_repository.dart';

class HomeController extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  bool isLoading = false;
  bool hasData = false;
  bool hasError = false;
  String errorMessage = '';
  DateTime? _initialDate;
  DateTime? _finalDate;

  List<Task> tasksToday = [];
  List<Task> tasksWeek = [];
  List<Task> tasksTomorow = [];
  List<Task> tasksPeriod = [];
  List<Task> tasksMonth = [];
  List<Task> tasksSelected = [];

  ScrollController scrollControllerFilters = ScrollController();
  //SlidableController slidableControllertasks = SlidableController();

  bool _isShowingFinished = true;

  TaskFilterEnum _tipoTaskFilter = TaskFilterEnum.hoje;

  Future<void> refreshTaskList() async {
    update(isLoading: true, hasData: false);

    tasksToday = await _getTasksToday();
    tasksTomorow = await _getTasksTomorrow();
    tasksWeek = await _getTasksWeek();
    tasksPeriod = await _getTasksPeriod(
      initialDate: _initialDate,
      finalDate: _finalDate,
    );
    tasksMonth = await _getTasksMonth();

    switch (_tipoTaskFilter) {
      case TaskFilterEnum.hoje:
        tasksSelected = tasksToday;
        break;
      case TaskFilterEnum.amanha:
        tasksSelected = tasksTomorow;
        break;
      case TaskFilterEnum.semana:
        tasksSelected = tasksWeek;
        break;
      case TaskFilterEnum.periodo:
        tasksSelected = tasksPeriod;
        break;
      case TaskFilterEnum.mes:
        tasksSelected = tasksMonth;
        break;
    }
    if (_isShowingFinished == false) {
      tasksSelected =
          tasksSelected.where((tk) => tk.finalizada == false).toList();
    }
    update(isLoading: false, hasData: tasksSelected.isNotEmpty);
    notifyListeners();
  }

  bool showOrHideFinishedTasks() {
    return _isShowingFinished;
  }

  setShowOrHideFInishedtasks() {
    _isShowingFinished = !_isShowingFinished;
    refreshTaskList();
  }

  deleteTask(Task task) async {
    await _taskRepository.delete(task.uuid);
    refreshTaskList();
  }

  setTaskFilterEnum(TaskFilterEnum taskFilterEnum) {
    _tipoTaskFilter = taskFilterEnum;

    if (scrollControllerFilters.hasClients) {
      switch (_tipoTaskFilter) {
        case TaskFilterEnum.hoje:
          scrollControllerFilters.animateTo(
            scrollControllerFilters.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          break;

        case TaskFilterEnum.amanha:
          scrollControllerFilters.animateTo(
            scrollControllerFilters.position.maxScrollExtent * .25,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          break;
        case TaskFilterEnum.semana:
          scrollControllerFilters.animateTo(
            scrollControllerFilters.position.maxScrollExtent * .60,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          break;

        case TaskFilterEnum.periodo:
          scrollControllerFilters.animateTo(
            scrollControllerFilters.position.maxScrollExtent * .80,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          break;
        case TaskFilterEnum.mes:
          scrollControllerFilters.animateTo(
            scrollControllerFilters.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          break;
      }
    }
  }

  TaskFilterEnum getTaskFilterEnum() {
    return _tipoTaskFilter;
  }

  List<Task> getTasksFiltered(TaskFilterEnum taskFIlter) {
    switch (taskFIlter) {
      case TaskFilterEnum.hoje:
        return tasksToday;

      case TaskFilterEnum.amanha:
        return tasksTomorow;

      case TaskFilterEnum.semana:
        return tasksWeek;

      case TaskFilterEnum.periodo:
        return tasksPeriod;

      case TaskFilterEnum.mes:
        return tasksMonth;
    }
  }

  Future<void> checkOrUncheckTask(Task task) async {
    await _taskRepository.checkOrUncheckTask(task);
    await refreshTaskList();
    notifyListeners();
  }

  void update({
    bool isLoading = false,
    bool hasData = false,
    bool hasError = false,
    String errorMessage = '',
  }) {
    this.isLoading = isLoading;
    this.hasData = hasData;
    this.hasError = hasError;
    this.errorMessage = errorMessage;

    notifyListeners();
  }

  Future<List<Task>> _getTasksPeriod({
    DateTime? initialDate,
    DateTime? finalDate,
  }) async {
    // ATUALIZA ESTADO
    update(isLoading: true);

    // ATUALIZA VARIAVEIS DO CONTROLE
    _initialDate = initialDate;
    _finalDate = _finalDate;

    // BUSCA DO REPOSITORIO
    _taskRepository
        .getTasks(initialDate: initialDate, finalDate: finalDate)
        .then((value) {
      return value;
    }).onError((error, stackTrace) {
      // EXECUÇÃO COM ERRO
      if (error is Exception) {
        update(hasError: true, errorMessage: error.toString());
      } else if (error is FormatException) {
        update(
          hasError: true,
          errorMessage: 'Erro no formato :${error.toString()}',
        );
      } else {
        update(
          hasError: true,
          errorMessage: 'Erro desconhecido.',
        );
      }
      return [];
    });

    return [];
  }

  Future<List<Task>> _getTasksMonth() async {
    List<Task> tempTask = [];
    await _taskRepository.getTasksMonth().then((value) {
      tempTask = value;
    }).onError((error, stackTrace) {
      // EXECUÇÃO COM ERRO
      if (error is Exception) {
        update(hasError: true, errorMessage: error.toString());
      } else if (error is FormatException) {
        update(
          hasError: true,
          errorMessage: 'Erro no formato :${error.toString()}',
        );
      } else {
        update(
          hasError: true,
          errorMessage: 'Erro desconhecido.',
        );
      }
    });
    return tempTask;
  }

  Future<List<Task>> _getTasksToday() async {
    List<Task> tempTask = [];
    await _taskRepository.getTasksToday().then((value) {
      tempTask = value;
    }).onError((error, stackTrace) {
      // EXECUÇÃO COM ERRO
      if (error is Exception) {
        update(hasError: true, errorMessage: error.toString());
      } else if (error is FormatException) {
        update(
          hasError: true,
          errorMessage: 'Erro no formato :${error.toString()}',
        );
      } else {
        update(
          hasError: true,
          errorMessage: 'Erro desconhecido.',
        );
      }
    });
    return tempTask;
  }

  Future<List<Task>> _getTasksTomorrow() async {
    List<Task> tempTask = [];
    await _taskRepository.getTasksTomorrow().then((value) {
      tempTask = value;
    }).onError((error, stackTrace) {
      // EXECUÇÃO COM ERRO
      if (error is Exception) {
        update(hasError: true, errorMessage: error.toString());
      } else if (error is FormatException) {
        update(
          hasError: true,
          errorMessage: 'Erro no formato :${error.toString()}',
        );
      } else {
        update(
          hasError: true,
          errorMessage: 'Erro desconhecido.',
        );
      }
    });
    return tempTask;
  }

  Future<List<Task>> _getTasksWeek() async {
    List<Task> tempTask = [];
    await _taskRepository.getTasksWeek().then((value) {
      tempTask = value;
    }).onError((error, stackTrace) {
      // EXECUÇÃO COM ERRO
      if (error is Exception) {
        update(hasError: true, errorMessage: error.toString());
      } else if (error is FormatException) {
        update(
          hasError: true,
          errorMessage: 'Erro no formato :${error.toString()}',
        );
      } else {
        update(
          hasError: true,
          errorMessage: 'Erro desconhecido.',
        );
      }
    });

    return tempTask;
  }
}
