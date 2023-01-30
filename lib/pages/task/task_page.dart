import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasksmgr/pages/task/page_task_controller.dart';
import 'package:tasksmgr/widgets/taskformfield.dart';

import '../../model/task_model.dart';

class PageTask extends StatefulWidget {
  final Task? task;
  const PageTask({super.key, this.task});

  @override
  State<PageTask> createState() => _PageTaskState();
}

class _PageTaskState extends State<PageTask> {
  final controller = PageTaskController();
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/y');

  @override
  void initState() {
    if (widget.task != null) {
      controller.descricaoTaskController.text = widget.task!.descricao;
      controller.dataTask = widget.task!.datatarefa;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            if (controller.dataTask == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informe uma data!'),
                ),
              );
            } else {
              await controller.savetask(
                context,
                task: Task(
                  uuid: (widget.task == null) ? '' : widget.task!.uuid,
                  descricao: controller.descricaoTaskController.text,
                  datatarefa: controller.dataTask!,
                  finalizada:
                      (widget.task == null) ? false : widget.task!.finalizada,
                ),
              );
            }
          }
        },
        label: const Text(
          'Salvar Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  (widget.task == null) ? 'Criar Tarefa' : 'Editar Tarefa',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Taskformfield(
                label: '',
                autofocus: true,
                controller: controller.descricaoTaskController,
                validator: (value) {
                  return value!.isEmpty ? 'Defina uma descrição' : null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      var lastDate = DateTime.now();
                      lastDate = lastDate.add(const Duration(days: 10 * 365));

                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: lastDate,
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                        fieldHintText: 'dd/mm/yyyy',
                        fieldLabelText: 'Informe uma data',
                        locale: const Locale('pt', 'BR'),
                        keyboardType: TextInputType.datetime,
                      ).then((value) {
                        controller.setDataTask(value);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.today,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          (controller.dataTask == null)
                              ? const Text(
                                  'Selecione uma data',
                                )
                              : Text(
                                  dateFormat.format(controller.dataTask!),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          (controller.dataTask == null)
                              ? const SizedBox()
                              : IconButton(
                                  onPressed: () {
                                    controller.setDataTask(null);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
