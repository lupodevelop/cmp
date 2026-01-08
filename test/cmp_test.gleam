import gleeunit
import cmp
import gleam/order as order

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
