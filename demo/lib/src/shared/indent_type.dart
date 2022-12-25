enum IndentType {
  connectingLines('Connecting Lines'),
  scopingLines('Scoping Lines'),
  blank('Blank');

  final String label;

  const IndentType(this.label);

  static Iterable<IndentType> allExcept(IndentType type) {
    return values.where((element) => element != type);
  }
}
