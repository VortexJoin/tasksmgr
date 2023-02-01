import 'package:flutter/material.dart';
import 'package:tasksmgr/pages/home/home_controller.dart';
import '../../../model/task_model.dart';

class TodoCardFilter extends StatefulWidget {
  final TaskFilterEnum taskFilterEnumSelected;
  final HomeController homeController;
  final List<Task> tasks;
  const TodoCardFilter({
    super.key,
    required this.taskFilterEnumSelected,
    required this.homeController,
    required this.tasks,
  });

  @override
  State<TodoCardFilter> createState() => _TodoCardFilterState();
}

class _TodoCardFilterState extends State<TodoCardFilter> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.homeController,
      builder: (context, child) {
        int total = widget.tasks.length;
        int totalFinished =
            widget.tasks.where((x) => x.finalizada).toList().length;

        bool selected = widget.homeController.getTaskFilterEnum() ==
            widget.taskFilterEnumSelected;

        double getFinishedPercentTodoCard() {
          if (total == 0) {
            return 0.0;
          }

          return ((totalFinished * 100) / total) / 100;
        }

        return Container(
          margin: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () {
              widget.homeController
                  .setTaskFilterEnum(widget.taskFilterEnumSelected);
              widget.homeController.refreshTaskList();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: const BoxConstraints(minHeight: 120, maxWidth: 150),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                border: Border.all(
                  width: 1,
                  color: Colors.grey.withOpacity(.8),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalFinished de $total TASKS',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 10,
                        color: selected ? Colors.white : Colors.grey),
                  ),
                  Expanded(
                    child: Text(
                      widget.taskFilterEnumSelected.descricao,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: getFinishedPercentTodoCard()),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        backgroundColor: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        value: getFinishedPercentTodoCard(),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          selected
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
