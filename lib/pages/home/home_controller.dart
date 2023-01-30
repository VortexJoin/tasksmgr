// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:tasksmgr/model/task_model.dart';
import 'package:tasksmgr/repositories/task_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._initialDate) : super() {
    //getTasks(initialDate: _initialDate);
  }

  final TaskRepository _taskRepository = TaskRepository();
  DateTime? _initialDate;
  DateTime? _finalDate;

  bool isLoading = false;
  bool hasData = false;
  bool hasError = false;
  String errorMessage = '';

  List<Task> listTasks = [];

  bool isShowingFinished = true;

  TaskFilterEnum tipoTaskFilter = TaskFilterEnum.hoje;

  void refreshTaskList() {
    switch (tipoTaskFilter) {
      case TaskFilterEnum.hoje:
        getTasksToday();
        break;
      case TaskFilterEnum.amanha:
        getTasksTomorrow();
        break;
      case TaskFilterEnum.semana:
        getTasksWeek();
        break;
      case TaskFilterEnum.periodo:
        getTasks(initialDate: _initialDate, finalDate: _finalDate);
        break;
    }
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

  Future<void> getTasksToday() async {
    update(isLoading: true);
    tipoTaskFilter = TaskFilterEnum.hoje;

    _taskRepository
        .getTasksToday(showFinished: isShowingFinished)
        .then((value) {
      // EXECUÇÃO OK

      print(value);
      listTasks = value;
      update(isLoading: false, hasData: listTasks.isNotEmpty);
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
  }

  Future<void> getTasksTomorrow() async {
    update(isLoading: true);
    tipoTaskFilter = TaskFilterEnum.amanha;

    _taskRepository
        .getTasksTomorrow(showFinished: isShowingFinished)
        .then((value) {
      // EXECUÇÃO OK
      listTasks = value;
      update(isLoading: false, hasData: listTasks.isNotEmpty);
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
  }

  Future<void> getTasksWeek() async {
    update(isLoading: true);
    tipoTaskFilter = TaskFilterEnum.semana;

    _taskRepository.getTasksWeek(showFinished: isShowingFinished).then((value) {
      // EXECUÇÃO OK
      listTasks = value;
      update(isLoading: false, hasData: listTasks.isNotEmpty);
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
  }

  Future<void> getTasks({
    DateTime? initialDate,
    DateTime? finalDate,
  }) async {
    if (kDebugMode) {
      print('gestask--');
    }
    // ATUALIZA ESTADO
    update(isLoading: true);

    // ATUALIZA VARIAVEIS DO CONTROLE
    _initialDate = initialDate;
    _finalDate = _finalDate;
    tipoTaskFilter = TaskFilterEnum.periodo;

    // BUSCA DO REPOSITORIO
    _taskRepository
        .getTasks(
            initialDate: initialDate,
            finalDate: finalDate,
            showFinished: isShowingFinished)
        .then((value) {
      // EXECUÇÃO OK
      listTasks = value;

      print(value);
      update(isLoading: false, hasData: listTasks.isNotEmpty);
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
  }
}
