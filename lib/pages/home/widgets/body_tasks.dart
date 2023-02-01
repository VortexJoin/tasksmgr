import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../model/task_model.dart';
import '../home_controller.dart';

class BodyTasks extends StatefulWidget {
  final HomeController homeController;
  const BodyTasks({super.key, required this.homeController});

  @override
  State<BodyTasks> createState() => _BodyTasksState();
}

class _BodyTasksState extends State<BodyTasks> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.homeController,
      builder: (context, child) {
        if (widget.homeController.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (widget.homeController.hasError) {
          return const Expanded(
            child: Center(
              child: Text('Ops, Não conseguimos carregar os dados.'),
            ),
          );
        } else if (widget.homeController.hasData) {
          return Expanded(
            child: ListView.builder(
              itemCount: widget.homeController.tasksSelected.length,
              itemBuilder: (context, index) {
                Task task = widget.homeController.tasksSelected[index];

                return Slidable(
                  closeOnScroll: true,
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          widget.homeController.deleteTask(task);
                        },
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Remover',
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      task.descricao,
                      style: task.finalizada
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 1.3,
                            )
                          : null,
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(task.datatarefa),
                      style: task.finalizada
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 1.3,
                            )
                          : null,
                    ),
                    value: task.finalizada,
                    onChanged: (check) =>
                        widget.homeController.checkOrUncheckTask(task),
                  ),
                );
              },
            ),
          );
        } else {
          return const Expanded(
            child: Center(
              child: Text('não há dados'),
            ),
          );
        }
      },
    );
  }
}
