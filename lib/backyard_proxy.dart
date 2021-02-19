class BackyardProxy {
  BackyardProxy() {}
  List<Object> _instances = [];

  void addInstance(Object _instance) => _instances.add(_instance);
}
