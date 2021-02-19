import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:backyard/backyard_config.dart';
import 'backyard_core.dart';

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
