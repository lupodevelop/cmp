import cmp
import gleam/int
import gleam/option
import gleam/order
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

pub fn natural_int_test() {
  assert cmp.natural_int(1, 2) == order.Lt
  assert cmp.natural_int(2, 1) == order.Gt
  assert cmp.natural_int(2, 2) == order.Eq
}

pub fn natural_string_test() {
  assert cmp.natural_string("a", "b") == order.Lt
  assert cmp.natural_string("z", "a") == order.Gt
  assert cmp.natural_string("hi", "hi") == order.Eq
}

pub fn by_string_test() {
  let u1 = #("Alice", 30)
  let u2 = #("Bob", 25)
  let key = fn(u) {
    case u {
      #(name, _) -> name
    }
  }
  let c = cmp.by_string(key)
  assert c(u1, u2) == order.Lt
  assert c(u2, u1) == order.Gt
}

pub fn by_generic_test() {
  // Use `by` with `string.compare` (example integration point for `str` too)
  let u1 = #("Alice", 30)
  let u2 = #("Bob", 25)
  let key = fn(u) {
    case u {
      #(name, _) -> name
    }
  }
  let c = cmp.by(key, string.compare)
  assert c(u1, u2) == order.Lt
  assert c(u2, u1) == order.Gt

  // Also test with `Int` comparator
  let k2 = fn(u) {
    case u {
      #(_, age) -> age
    }
  }
  let c2 = cmp.by(k2, int.compare)
  assert c2(u1, u2) == order.Gt
  assert c2(u2, u1) == order.Lt
}

pub fn by_int_test() {
  let u1 = #("Alice", 30)
  let u2 = #("Bob", 25)
  let key = fn(u) {
    case u {
      #(_, age) -> age
    }
  }
  let c = cmp.by_int(key)
  assert c(u1, u2) == order.Gt
  assert c(u2, u1) == order.Lt
}

pub fn chain_test() {
  let by_name =
    cmp.by(
      fn(u) {
        case u {
          #(name, _) -> name
        }
      },
      string.compare,
    )
  let by_age =
    cmp.by(
      fn(u) {
        case u {
          #(_, age) -> age
        }
      },
      int.compare,
    )

  let c = cmp.chain([by_name, by_age])

  let a = #("Alice", 30)
  let b = #("Alice", 25)
  let d = #("Bob", 20)

  // names equal -> compare ages
  assert c(a, b) == order.Gt
  assert c(b, a) == order.Lt

  // names differ -> compare by name
  assert c(a, d) == order.Lt
}

pub fn list_compare_test() {
  let cmp_ints = cmp.list_compare(int.compare)

  assert cmp_ints([], []) == order.Eq
  assert cmp_ints([], [1]) == order.Lt
  assert cmp_ints([1], []) == order.Gt
  assert cmp_ints([1, 2], [1, 3]) == order.Lt
  assert cmp_ints([1, 2], [1, 2]) == order.Eq
}

pub fn natural_float_test() {
  assert cmp.natural_float(1.2, 2.3) == order.Lt
  assert cmp.natural_float(2.3, 1.2) == order.Gt
  assert cmp.natural_float(2.0, 2.0) == order.Eq
}

pub fn by_float_test() {
  let u1 = #("Alice", 30.5)
  let u2 = #("Bob", 25.0)
  let key = fn(u) {
    case u {
      #(_, score) -> score
    }
  }
  let c = cmp.by_float(key)
  assert c(u1, u2) == order.Gt
  assert c(u2, u1) == order.Lt
}

pub fn option_test_none_first() {
  let key = fn(u) {
    case u {
      #(_, age) -> age
    }
  }
  let base = cmp.by_int(key)
  let c = cmp.option(order.Lt, base)

  let none = option.None
  let a = option.Some(#("Alice", 30))
  let b = option.Some(#("Bob", 25))

  assert c(none, a) == order.Lt
  assert c(a, none) == order.Gt
  assert c(none, none) == order.Eq

  // Some vs Some delegates to base comparator
  assert c(a, b) == order.Gt
}

pub fn option_test_none_last() {
  let key = fn(u) {
    case u {
      #(_, age) -> age
    }
  }
  let base = cmp.by_int(key)
  let c = cmp.option(order.Gt, base)

  let none = option.None
  let a = option.Some(#("Alice", 30))
  let b = option.Some(#("Bob", 25))

  assert c(none, a) == order.Gt
  assert c(a, none) == order.Lt
  assert c(none, none) == order.Eq

  assert c(a, b) == order.Gt
}
