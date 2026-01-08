import gleam/io

import gleam/int
import gleam/order
import gleam/string

/// A comparator for values of type `a`.
/// Returns an `order.Order` from the stdlib `order` module.
pub type Comparator(a) =
  fn(a, a) -> order.Order

/// Compare two integers using the stdlib `int.compare`.
pub fn natural_int(a: Int, b: Int) -> order.Order {
  int.compare(a, b)
}

/// Reverse the ordering produced by `comp`.
/// Delegates to `order.reverse` for correctness.
pub fn reverse(comp: Comparator(a)) -> Comparator(a) {
  order.reverse(comp)
}

/// Compose two comparators: try `comp1`, if `Eq` fall back to `comp2`.
/// The returned comparator is type-safe and total.
pub fn then(comp1: Comparator(a), comp2: Comparator(a)) -> Comparator(a) {
  fn(x, y) {
    case comp1(x, y) {
      order.Eq -> comp2(x, y)
      o -> o
    }
  }
}

/// Build a comparator by extracting an `Int` key from values of type `a`.
/// Returns `order.Order` via `int.compare`.
pub fn by_int(key: fn(a) -> Int) -> Comparator(a) {
  fn(x, y) { int.compare(key(x), key(y)) }
}

/// Compare two strings in the natural (lexicographic) way.
pub fn natural_string(a: String, b: String) -> order.Order {
  string.compare(a, b)
}

/// Build a comparator by extracting a `String` key from values of type `a`.
/// Uses the stdlib `string.compare` which returns `order.Order`.
pub fn by_string(key: fn(a) -> String) -> Comparator(a) {
  fn(x, y) { string.compare(key(x), key(y)) }
}

/// Generic contramap helper: build a comparator for `a` by providing a key
/// extractor `key` and a comparator `cmp` for the key type `b`.
///
/// Example:
///
/// ```gleam
/// let cmp = cmp.by(fn(u) { #(name, _) -> name }, string.compare)
/// list.sort(users, by: cmp)
/// ```
pub fn by(key: fn(a) -> b, cmp: fn(b, b) -> order.Order) -> Comparator(a) {
  fn(x, y) { cmp(key(x), key(y)) }
}

pub fn main() -> Nil {
  io.println("Hello from cmp!")
}
