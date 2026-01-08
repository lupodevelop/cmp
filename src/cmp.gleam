import gleam/io

import gleam/int
import gleam/option
import gleam/order
import gleam/string
import gleam/float

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

/// Compare two floats using the stdlib `float.compare`.
pub fn natural_float(a: Float, b: Float) -> order.Order {
  float.compare(a, b)
}

/// Build a comparator by extracting a `Float` key from values of type `a`.
pub fn by_float(key: fn(a) -> Float) -> Comparator(a) {
  fn(x, y) { float.compare(key(x), key(y)) }
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

/// Build a comparator for `Option(a)` given:
/// - `none_order`: the `order.Order` to use when comparing `None` with `Some(_)`.
///   Use `order.Lt` for `None` < `Some`, `order.Gt` for `None` > `Some`.
/// - `comp`: comparator for the inner `a` values (used when both are `Some`).
///
/// Example:
///
/// ```gleam
/// let c = cmp.option(order.Lt, cmp.by_int(.age))
/// ```
pub fn option(
  none_order: order.Order,
  comp: Comparator(a),
) -> Comparator(option.Option(a)) {
  fn(x, y) {
    case x {
      option.None ->
        case y {
          option.None -> order.Eq
          option.Some(_) -> none_order
        }
      option.Some(xv) ->
        case y {
          option.None -> order.negate(none_order)
          option.Some(yv) -> comp(xv, yv)
        }
    }
  }
}

// Internal helper: iterate the list of comparators and return the first non-Eq
// result, or `order.Eq` if all comparators return `Eq`.
fn chain_go(comps: List(fn(a, a) -> order.Order), x: a, y: a) -> order.Order {
  case comps {
    [] -> order.Eq
    [h, ..t] ->
      case h(x, y) {
        order.Eq -> chain_go(t, x, y)
        o -> o
      }
  }
}

/// Chain a list of comparators lexicographically.
/// The returned comparator applies each comparator in order and uses the
/// first non-`Eq` result, or `Eq` if all comparators are `Eq`.
pub fn chain(comps: List(fn(a, a) -> order.Order)) -> Comparator(a) {
  fn(x, y) { chain_go(comps, x, y) }
}

// Helper: compare two lists lexicographically (top-level to allow recursion).
fn list_compare_go(elem_cmp: fn(a, a) -> order.Order, xl: List(a), yl: List(a)) -> order.Order {
  case xl {
    [] ->
      case yl {
        [] -> order.Eq
        _ -> order.Lt
      }
    [xh, ..xt] ->
      case yl {
        [] -> order.Gt
        [yh, ..yt] ->
          case elem_cmp(xh, yh) {
            order.Eq -> list_compare_go(elem_cmp, xt, yt)
            o -> o
          }
      }
  }
}

/// Compare two lists lexicographically given an element comparator.
/// Empty list is considered less than a non-empty list.
pub fn list_compare(elem_cmp: fn(a, a) -> order.Order) -> Comparator(List(a)) {
  fn(xs, ys) { list_compare_go(elem_cmp, xs, ys) }
}

pub fn main() -> Nil {
  io.println("Hello from cmp!")
}
