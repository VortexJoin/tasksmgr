import 'package:flutter/material.dart';

import '../home_controller.dart';

class BodyHeaderTasks extends StatefulWidget {
  final HomeController homeController;
  const BodyHeaderTasks({super.key, required this.homeController});

  @override
  State<BodyHeaderTasks> createState() => _BodyHeaderTasksState();
}

class _BodyHeaderTasksState extends State<BodyHeaderTasks> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tarefas ',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        AnimatedBuilder(
          animation: widget.homeController,
          builder: (context, child) {
            return PopupMenuButton(
              icon: Icon(
                Icons.filter_alt,
                color: widget.homeController.showOrHideFinishedTasks()
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
              ),
              onSelected: (value) =>
                  widget.homeController.setShowOrHideFInishedtasks(),
              itemBuilder: (_) => [
                PopupMenuItem<bool>(
                  value: true,
                  child: Text(
                      '${widget.homeController.showOrHideFinishedTasks() ? 'Esconder' : 'Mostrar'} tarefas concluídas'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
