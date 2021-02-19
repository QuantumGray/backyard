import 'dart:isolate';

import 'package:backyard/backyard_proxy.dart';

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

class Builder<T> {
  Builder(this._builderFunc);
  T Function() _builderFunc;
}
