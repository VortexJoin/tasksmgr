// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

List<Task> taskFromJson(String str) =>
    List<Task>.from(json.decode(str).map((x) => Task.fromJson(x)));

String taskToJson(List<Task> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Task {
  Task({
    this.uuid = '',
    required this.descricao,
    required this.datatarefa,
    this.finalizada = false,
  });

  String uuid;
  String descricao;
  DateTime datatarefa;
  bool finalizada;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        uuid: json["uuid"],
        descricao: json["descricao"],
        datatarefa: DateTime.parse(json["datatarefa"]),
        finalizada: json["finalizada"],
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "descricao": descricao,
        "datatarefa":
            "${datatarefa.year.toString().padLeft(4, '0')}-${datatarefa.month.toString().padLeft(2, '0')}-${datatarefa.day.toString().padLeft(2, '0')}",
        "finalizada": finalizada,
      };
}

enum TaskFilterEnum { hoje, amanha, semana, periodo }

extension TaskFilterDescription on TaskFilterEnum {
  String get descricao {
    switch (this) {
      case TaskFilterEnum.hoje:
        return 'DE HOJE';
      case TaskFilterEnum.amanha:
        return 'DE AMANHÃ';
      case TaskFilterEnum.semana:
        return 'DA SEMANA';
      case TaskFilterEnum.periodo:
        return 'DO PERIODO';
    }
  }
}
