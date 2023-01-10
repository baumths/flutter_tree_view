/// Signature of a function that takes a `T` value and returns a `R` value.
typedef Mapper<T, R> = R Function(T value);

/// Signature of a function used to visit nodes during tree traversal.
typedef Visitor<T> = void Function(T node);

/// Signature of a function that takes a `T` value and returns an `Iterable<T>`.
///
/// Used to get the children of a node in a tree.
typedef ChildrenProvider<T> = Mapper<T, Iterable<T>>;

/// Signature of a function that takes a `T` value and returns a `T?` value.
///
/// Used to get the parent of a node in a tree.
typedef ParentProvider<T> = Mapper<T, T?>;

