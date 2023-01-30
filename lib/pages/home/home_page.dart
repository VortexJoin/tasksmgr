import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasksmgr/model/task_model.dart';
import 'package:tasksmgr/pages/home/home_controller.dart';
import 'package:tasksmgr/pages/task/task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var controller = HomeController(DateTime.now());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getTasksToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  animation = CurvedAnimation(
                      parent: animation, curve: Curves.easeInOut);
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.bottomRight,
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const PageTask();
                }),
          ).then((value) {
            controller.refreshTaskList();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return SizedBox(
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      botaoFiltro(TaskFilterEnum.hoje),
                      botaoFiltro(TaskFilterEnum.amanha),
                      botaoFiltro(TaskFilterEnum.semana),
                    ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              if (controller.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (controller.hasError) {
                return const Expanded(
                  child: Center(
                    child: Text('Ops, Não conseguimos carregar os dados.'),
                  ),
                );
              } else if (controller.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.listTasks.length,
                    itemBuilder: (context, index) {
                      Task task = controller.listTasks[index];
                      return ListTile(
                        onTap: () {},
                        leading: task.finalizada
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
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

              return Expanded(
                child: ListView.builder(
                  itemCount: controller.listTasks.length,
                  itemBuilder: (context, index) {
                    Task task = controller.listTasks[index];
                    return ListTile(
                      title: Text(task.descricao),
                      subtitle: Text(
                        task.datatarefa.toLocal().toString(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget botaoFiltro(TaskFilterEnum taskFilterEnum) {
    return Container(
      height: 80,
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: controller.tipoTaskFilter == taskFilterEnum
            ? Theme.of(context).colorScheme.primary
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          switch (taskFilterEnum) {
            case TaskFilterEnum.hoje:
              controller.getTasksToday();
              break;
            case TaskFilterEnum.amanha:
              controller.getTasksTomorrow();
              break;
            case TaskFilterEnum.semana:
              controller.getTasksWeek();
              break;
            case TaskFilterEnum.periodo:
              controller.getTasksWeek();
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                taskFilterEnum.descricao,
                //  style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            controller.tipoTaskFilter == taskFilterEnum
                ? Text(
                    '${controller.listTasks.length} Tasks',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
