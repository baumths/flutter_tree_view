enum IndentType {
  connectingLines('Connecting Lines'),
  scopingLines('Scoping Lines'),
  empty('Empty Indent');

  final String label;

  const IndentType(this.label);

  static Iterable<IndentType> allExcept(IndentType type) {
    return values.where((element) => element != type);
  }
}
