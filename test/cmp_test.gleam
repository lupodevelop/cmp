import gleeunit
import cmp

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
  assert cmp.natural_int(1, 2) == cmp.Less
  assert cmp.natural_int(2, 1) == cmp.Greater
  assert cmp.natural_int(2, 2) == cmp.Equal
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
  assert c(u1, u2) == cmp.Greater
  assert c(u2, u1) == cmp.Less
}
