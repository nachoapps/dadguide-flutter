import 'dart:async';

import 'package:flutter/material.dart';

class TaskListProgress extends StatefulWidget {
  final TaskPublisher _tasks;

  const TaskListProgress(this._tasks, {Key key}) : super(key: key);

  @override
  _TaskListProgressState createState() => _TaskListProgressState(_tasks);
}

class _TaskListProgressState extends State<TaskListProgress> {
  final TaskPublisher _tasks;

  _TaskListProgressState(this._tasks);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskProgress>(
        stream: _tasks.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return buildIdle(context);
          }

          if (snapshot.hasError) {
            return buildFatalError(context, snapshot.error);
          }

          switch (snapshot.data.status) {
            case TaskStatus.failed:
              return buildFailed(context, snapshot.data);
            case TaskStatus.started:
              return buildRunning(context, snapshot.data);
            case TaskStatus.idle:
              return buildRunning(context, snapshot.data);
            case TaskStatus.finished:
              return buildFinished(context);
            default:
              throw 'Unexpected status ${snapshot.data.status}';
          }
        });
  }

  Widget buildRunning(BuildContext context, TaskProgress update) {
    var executingText = update.index > 0
        ? 'Executing task (${update.index}/${update.taskCount})'
        : 'Executing task';
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircularProgressIndicator(),
            title: Text(executingText),
            subtitle: Row(
              children: <Widget>[
                Text(update.taskName),
                Spacer(),
                if (update.progress != null) Text('${update.progress}%')
              ],
            ),
          ),
          if (update.progress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(value: update.progress / 100),
            ),
        ],
      ),
    );
  }

  Widget buildFailed(BuildContext context, TaskProgress update) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: SizedBox(
                width: 36, height: 36, child: Icon(Icons.error_outline, color: Colors.red)),
            title: Text('Task ${update.index} of ${update.taskCount} failed'),
            subtitle: Text(update.taskName),
          ),
          Text(update.message ?? 'Check your internet connection.\nAutomatically restarting.'),
        ],
      ),
    );
  }

  Widget buildIdle(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.schedule, color: Colors.yellow)),
        title: Text('Waiting to start tasks'),
      ),
    );
  }

  Widget buildFatalError(BuildContext context, Object error) {
    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.check, color: Colors.red)),
        title: Text('Fatal error occurred; try restarting the app'),
        subtitle: Text(error?.toString() ?? 'unkown error'),
      ),
    );
  }

  Widget buildFinished(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.check, color: Colors.green)),
        title: Text('All tasks complete'),
      ),
    );
  }
}

enum TaskStatus { idle, started, failed, finished }

class TaskProgress {
  final String taskName;
  final int index;
  final int taskCount;
  final TaskStatus status;
  final int progress;
  final String message;

  TaskProgress(this.taskName, this.index, this.taskCount, this.status,
      {this.progress, this.message});
}

mixin TaskPublisher {
  @protected
  final StreamController<TaskProgress> controller = StreamController.broadcast();

  Stream<TaskProgress> get stream => controller.stream;

  @protected
  void finishStream() {
    controller.close();
  }

  @protected
  void publish(TaskProgress update) {
    controller.add(update);
  }

  @protected
  void pipeTo(TaskPublisher sink) {
    stream.listen((e) => sink.controller.add(e));
  }
}
