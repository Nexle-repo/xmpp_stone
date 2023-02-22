import 'dart:async';

import 'package:xmpp_stone/src/Connection.dart';
import 'package:xmpp_stone/src/features/queue/QueueApi.dart';

class ConnectionExecutionQueueContent {
  final Function func;
  final dynamic params;
  final String name;
  final bool unique;
  final XmppConnectionState expectedState;

  const ConnectionExecutionQueueContent(
      this.func, this.unique, this.params, this.name,
      {required this.expectedState});
}

class ConnectionExecutionQueue
    extends QueueApi<ConnectionExecutionQueueContent> {
  List<ConnectionExecutionQueueContent> writingQueueContent = [];
  Connection? _connection;
  bool isRunning = false;

  ConnectionExecutionQueue(Connection connection) {
    _connection = connection;
    writingQueueContent = [];
  }

  @override
  put(ConnectionExecutionQueueContent content) {
    if (writingQueueContent
            .where((element) => element.name == content.name)
            .isNotEmpty &&
        content.unique) {
      return;
    }
    writingQueueContent.add(content);
  }

  @override
  resume() async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    await _resume();
  }

  _resume() async {
    if (writingQueueContent.isEmpty) {
      isRunning = false;
      return;
    }
    bool shouldResume = await pop();
    // Can continue
    if (shouldResume) {
      await _resume();
    } else {
      isRunning = false;
    }
  }

  @override
  bool isEligible(ConnectionExecutionQueueContent content) {
    return _connection!.state != content.expectedState;
  }

  @override
  Future<bool> execute(ConnectionExecutionQueueContent content) async {
    final Completer<bool> completer = Completer<bool>();
    Timer(const Duration(milliseconds: 2000), () {
      content.func();
      completer.complete(true);
    });
    return completer.future;
  }

  @override
  Future<bool> pop() async {
    if (writingQueueContent.isEmpty) {
      return false;
    }
    final temporalContent = writingQueueContent.elementAt(0);
    bool _isEligible = await isEligible(temporalContent);
    if (_isEligible) {
      await execute(writingQueueContent.elementAt(0));
      writingQueueContent.removeAt(0);
      return true;
    } else {
      return false;
    }
  }

  @override
  clear() {
    writingQueueContent = [];
  }
}
