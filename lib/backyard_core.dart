import 'dart:isolate';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'backyard_config.dart';

class Backyard extends ChangeNotifier {
  Backyard(
    this.config, {
    this.lazyInit = false,
  }) {
    if (!lazyInit) init();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      }
    });
  }
  final BackyardConfig config;
  final bool lazyInit;
  late Isolate _isolate;
  ReceivePort _receivePort = ReceivePort('UI-thread RP');
  StreamController<dynamic> _streamController = StreamController();
  // Completer _sendPortCompleter = Completer<SendPort>();
  late SendPort _sendPort;

  void init() {
    config.sendPort = _receivePort.sendPort;
    _spawn();
  }

  Stream<T> listen<T>() {
    return _streamController.stream.where((event) => event is T) as Stream<T>;
  }

  Future<void> _spawn() async {
    _isolate = await Isolate.spawn((BackyardConfig config) {
      config.init();
    }, config);
    return;
  }
}
