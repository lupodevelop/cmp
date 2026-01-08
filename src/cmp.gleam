import gleam/io

pub type Order {
  Less
  Equal
  Greater
}

pub type Comparator(a) = fn(a, a) -> Order

pub fn natural_int(a: Int, b: Int) -> Order {
  case a < b {
    True -> Less
    False ->
      case a > b {
        True -> Greater
        False -> Equal
      }
  }
}

pub fn reverse(comp: Comparator(a)) -> Comparator(a) {
  fn(x, y) {
    case comp(x, y) {
      Less -> Greater
      Greater -> Less
      Equal -> Equal
    }
  }
}

pub fn then(comp1: Comparator(a), comp2: Comparator(a)) -> Comparator(a) {
  fn(x, y) {
    case comp1(x, y) {
      Equal -> comp2(x, y)
      o -> o
    }
  }
}

pub fn by_int(key: fn(a) -> Int) -> Comparator(a) {
  fn(x, y) {
    natural_int(key(x), key(y))
  }
}

pub fn main() -> Nil {
  io.println("Hello from cmp!")
}
