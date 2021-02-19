import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class BackyardScope extends InheritedWidget {
  BackyardScope({
    required this.child,
    required this.config,
  }) : super(child: child) {
    _backyard = Backyard(config);
  }

  final Widget child;
  final BackyardConfig config;
  late Backyard _backyard;
  StreamController<dynamic> _streamController = StreamController();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  void dispose() {
    _streamController.close();
  }
}

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

class BackyardConfig {
  BackyardConfig({
    required this.builders,
  });
  final List<Builder> builders;

  BackyardProxy backyardProxy = BackyardProxy();
  ReceivePort _receivePort = ReceivePort('backyard-thread RP');
  late SendPort sendPort;

  void init() {
    sendPort.send(_receivePort.sendPort);
    builders.forEach((_builder) {
      backyardProxy.addInstance(_builder._builderFunc());
    });
  }
}

class BackyardProxy {
  BackyardProxy() {}
  List<Object> _instances = [];

  void addInstance(Object _instance) => _instances.add(_instance);
}

class Builder<T> {
  Builder(this._builderFunc);
  T Function() _builderFunc;
}
