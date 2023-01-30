import 'package:flutter/material.dart';
import '../../model/task_model.dart';
import '../../repositories/task_repository.dart';

class PageTaskController extends ChangeNotifier {
  TextEditingController descricaoTaskController = TextEditingController();
  DateTime? dataTask;

  final TaskRepository _taskRepository = TaskRepository();

  void setDataTask(DateTime? dt) {
    dataTask = dt;
    notifyListeners();
  }

  void setDescricaoTask(String txt) {
    descricaoTaskController.text = txt;
  }

  Future<void> savetask(
    BuildContext context, {
    required Task task,
  }) async {
    if (task.uuid.isEmpty) {
      _taskRepository.newTask(task.descricao, task.datatarefa).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvo com Sucesso!'),
          ),
        );
        Navigator.pop(context);
      });
    } else {
      _taskRepository.editTask(task).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvo com Sucesso!'),
          ),
        );
        Navigator.pop(context);
      });
    }
  }
}
