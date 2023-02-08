import 'package:flutter/material.dart';
import 'package:tasksmgr/model/task_model.dart';
import 'package:tasksmgr/pages/home/home_controller.dart';
import 'package:tasksmgr/pages/home/widgets/bode_header_tasks.dart';
import 'package:tasksmgr/pages/home/widgets/body_filtros.dart';
import 'package:tasksmgr/pages/home/widgets/body_tasks.dart';
import 'package:tasksmgr/pages/task/task_page.dart';

import '../../main.dart';
import '../../services/google_calendar_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var controller = HomeController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.setTaskFilterEnum(TaskFilterEnum.hoje);
      controller.refreshTaskList();

      var calendar = CalendarService();

      calendar.getEvents(
        start: DateTime(2023, 01, 01),
        end: DateTime(2023, 02, 01),
      );
    });
  }

  @override
  void dispose() {
    darkNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas Tarefas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          ValueListenableBuilder(
            valueListenable: darkNotifier,
            builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  isDark = !isDark;
                  darkNotifier.value = isDark;
                },
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          )
        ],
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            BodyFiltros(homeController: controller),
            BodyHeaderTasks(homeController: controller),
            BodyTasks(homeController: controller),
          ],
        ),
      ),
    );
  }
}
