import 'package:flutter/material.dart';

abstract class Message {
  final String content;
  TimeOfDay time = TimeOfDay.now();
  Message(this.content);
  Color textColor();
  String type();
}
class Debug extends Message {
  Debug(super.content);
  @override Color textColor() => Colors.grey;
  @override String type() => "DBG";
}
class Info extends Message {
  Info(super.content);
  @override Color textColor() => Colors.black;
  @override String type() => "INFO";
}
class Warn extends Message {
  Warn(super.content);
  @override Color textColor() => const Color.fromARGB(255, 192, 192, 16);
  @override String type() => "WARN";
}
class Err extends Message {
  Err(super.content);
  @override Color textColor() => const Color.fromARGB(255, 255, 0, 0);
  @override String type() => "ERR";
}

List<Message> log = [];

void debug(dynamic obj) {
  debugPrint(obj.toString());
  log.add(Debug(obj.toString()));
}
void info(dynamic obj) {
  debugPrint(obj.toString());
  log.add(Info(obj.toString()));
}
void warn(dynamic obj) {
  debugPrint(obj.toString());
  log.add(Warn(obj.toString()));
}
void err(dynamic obj) {
  debugPrint(obj.toString());
  log.add(Err(obj.toString()));
}

Widget build(BuildContext context) => ListView.builder(
  itemCount: log.length,
  itemBuilder: (ctx, index) => Text(
    "${log[index].time.format(context)} [${log[index].type()}]: ${log[index].content}",
    style: TextStyle(
      color: log[index].textColor(),
    ),
  ),
);
