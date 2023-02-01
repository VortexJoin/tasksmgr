import 'package:flutter/material.dart';
import 'package:tasksmgr/pages/home/widgets/todo_card.dart';

import '../../../model/task_model.dart';
import '../home_controller.dart';

class BodyFiltros extends StatefulWidget {
  final HomeController homeController;
  const BodyFiltros({super.key, required this.homeController});

  @override
  State<BodyFiltros> createState() => _BodyFiltrosState();
}

class _BodyFiltrosState extends State<BodyFiltros> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.homeController,
      builder: (context, child) {
        return Container(
          height: 160,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Scrollbar(
            controller: widget.homeController.scrollControllerFilters,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: widget.homeController.scrollControllerFilters,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    TodoCardFilter(
                      homeController: widget.homeController,
                      taskFilterEnumSelected: TaskFilterEnum.hoje,
                      tasks: widget.homeController
                          .getTasksFiltered(TaskFilterEnum.hoje),
                    ),
                    TodoCardFilter(
                      homeController: widget.homeController,
                      taskFilterEnumSelected: TaskFilterEnum.amanha,
                      tasks: widget.homeController
                          .getTasksFiltered(TaskFilterEnum.amanha),
                    ),
                    TodoCardFilter(
                      homeController: widget.homeController,
                      taskFilterEnumSelected: TaskFilterEnum.semana,
                      tasks: widget.homeController
                          .getTasksFiltered(TaskFilterEnum.semana),
                    ),
                    TodoCardFilter(
                      homeController: widget.homeController,
                      taskFilterEnumSelected: TaskFilterEnum.mes,
                      tasks: widget.homeController
                          .getTasksFiltered(TaskFilterEnum.mes),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
