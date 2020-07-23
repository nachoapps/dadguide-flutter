import 'dart:async';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/utils/email.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';

/// Displays the status of a running task, the total task count, spinner, details, etc.
///
/// This is used for the first launch flow, and the interactive update tables dialog.
class TaskListProgress extends StatefulWidget {
  // TODO: This class ended up not being reused for anything so just make it onboarding specific.

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
    var loc = DadGuideLocalizations.of(context);

    var executingText = update.index > 0
        ? loc.taskExecutingWithCount(update.index, update.taskCount)
        : loc.taskExecuting;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircularProgressIndicator(),
            title: Text(executingText),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(update.taskName)),
                if (update.progress != null) Text(loc.taskProgress(update.progress))
              ],
            ),
          ),
          if (update.progress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(value: update.progress / 100),
            ),
          MultipleFailureWidget(),
        ],
      ),
    );
  }

  Widget buildFailed(BuildContext context, TaskProgress update) {
    var loc = DadGuideLocalizations.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: SizedBox(
                width: 36, height: 36, child: Icon(Icons.error_outline, color: Colors.red)),
            title: Text(loc.taskFailedWithCount(update.index, update.taskCount)),
            subtitle: Text(update.taskName),
          ),
          ListTile(
            title: Text('Exception occurred'),
            subtitle: Text(update.message ?? loc.taskRestarting),
          ),
          MultipleFailureWidget(),
        ],
      ),
    );
  }

  Widget buildIdle(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.schedule, color: Colors.yellow)),
        title: Text(loc.taskWaiting),
      ),
    );
  }

  Widget buildFatalError(BuildContext context, Object error) {
    var loc = DadGuideLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.check, color: Colors.red)),
        title: Text(loc.taskFatalError),
        subtitle: Text(error?.toString() ?? 'unknown error'),
      ),
    );
  }

  Widget buildFinished(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: SizedBox(width: 36, height: 36, child: Icon(Icons.check, color: Colors.green)),
        title: Text(loc.taskFinished),
      ),
    );
  }
}

/// Possible states for a task. The various states trigger different UI displays.
enum TaskStatus { idle, started, failed, finished }

/// An update that a task can publish to adjust the UI.
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

/// Mixin for a class that adds the ability to publish status updates, and to listen for those
/// updates.
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

class MultipleFailureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Prefs.onboardingFailureCount == 0) return Container();

    return Card(
      child: ListTile(
        title: Text('Onboarding has failed ${Prefs.onboardingFailureCount} times'),
        subtitle: RaisedButton(
          child: Text('Submit logs to developer'),
          onPressed: () => sendOnboardingError(),
        ),
      ),
    );
  }
}
