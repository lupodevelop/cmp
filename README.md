# cmp_gleam

[![Package Version](https://img.shields.io/hexpm/v/cmp_gleam)](https://hex.pm/packages/cmp_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cmp_gleam/)
[![CI](https://github.com/lupodevelop/cmp/workflows/test/badge.svg)](https://github.com/lupodevelop/cmp/actions)

A tiny, focused library for building small, composable comparators in Gleam. It intentionally avoids magic (no derives, no hidden behavior) so that comparison logic remains explicit, easy to test and easy to reason about.

## Features

- ✨ Small and predictable API
- 🔧 Composable building blocks for lexicographic and tie-breaker ordering
- 🎯 Optional normalization/folding integration (e.g., with [`str`](https://github.com/lupodevelop/str)) without runtime dependencies
- 🔒 Type-safe and total functions (no panics, no unsafe code)

> **Note**: [`str` documentation](https://hexdocs.pm/str/) is available on HexDocs.

## Why this approach?

The library favors explicitness over implicit derivation. By making comparators first-class and composable you get predictable behaviour, easier testing, and straightforward integration with normalization libraries when you need to handle real-world Unicode data.

## Installation

```sh
gleam add cmp_gleam
```

Then import the `cmp` module in your code:

```gleam
import cmp
```

## Quick examples

### 1. Sort integers

```gleam
import cmp
import gleam/list

pub fn sort_ints(xs: List(Int)) -> List(Int) {
  list.sort(xs, by: cmp.natural_int)
}
```

### 2. Sort records by a field (contramap pattern)

```gleam
import cmp
import gleam/list
import gleam/string

type User {
  User(name: String, age: Int)
}

pub fn sort_by_name(users: List(User)) -> List(User) {
  let cmp_name = cmp.by(fn(u) { case u { User(name, _) -> name } }, string.compare)
  list.sort(users, by: cmp_name)
}
```

### 3. Lexicographic ordering (chain / then / lazy_then)

Combine multiple comparators to sort by primary key, then by secondary key:

```gleam
let comparator = cmp.chain([
  cmp.by(fn(u) { case u { User(name, _) -> name } }, string.compare),
  cmp.by(fn(u) { case u { User(_, age) -> age } }, cmp.natural_int)
])
list.sort(users, by: comparator)
```

## Integration with `str` (optional)

The library does **not** depend on [`str`](https://github.com/lupodevelop/str), but you can pass [`str`](https://github.com/lupodevelop/str) functions to the APIs for Unicode normalization and folding.

### ASCII folding example

```gleam
import cmp
import gleam/list
import gleam/string
import str/extra

pub fn sort_by_name_ascii_fold(users: List(User)) -> List(User) {
  let normalize = str.extra.ascii_fold
  let comparator = cmp.by_normalized_string(
    fn(u) { case u { User(name, _) -> name } },
    normalize,
    string.compare
  )
  list.sort(users, by: comparator)
}
```

You can also combine normalization steps:

```gleam
let normalize = fn(s) { s |> str.extra.ascii_fold |> string.lowercase }
```

### Using similarity metrics (advanced)

⚠️ **Warning**: similarity/distance metrics don't guarantee transitivity (a < b and b < c doesn't always imply a < c). If you need a total order, sort by the metric value itself rather than using it directly as a comparator.

**Not recommended** (violates transitivity):

```gleam
import gleam/order

let similarity_cmp = fn(a, b) {
  let s = str.similarity(a, b)
  case s > 0.8 { True -> order.Lt False -> order.Gt }
}
```

**Better approach** (compute metric, then sort by it):

```gleam
let reference = "Alice"
let with_similarity = list.map(users, fn(u) {
  let sim = str.similarity(u.name, reference)
  #(u, sim)
})
let sorted = list.sort(with_similarity, by: cmp.by(fn(pair) { pair.1 }, float.compare))
```

## Unicode & normalization notes

- `string.compare` compares strings as-is; composed vs decomposed characters may behave differently if not normalized.
- For user-facing sorting (names, titles), it is recommended to **normalize** (NFC/NFD) or apply folding (remove accents) before comparing.
- [`str`](https://github.com/lupodevelop/str) provides useful primitives (`str.extra.ascii_fold`, `str.core.normalize_whitespace`, etc.) which you can pass directly to `cmp` functions.

### Performance tip: precompute normalized keys

When sorting large lists by normalized strings, calling `normalize` on every comparison is expensive. Use the decorate-sort-undecorate pattern:

```gleam
import gleam/list

// 1. Decorate: precompute normalized keys once
let decorated = list.map(users, fn(u) {
  let normalized_name = str.extra.ascii_fold(u.name)
  #(u, normalized_name)
})

// 2. Sort by the precomputed key
let sorted_decorated = list.sort(decorated, by: cmp.by(fn(pair) { pair.1 }, string.compare))

// 3. Undecorate: extract the original values
let sorted_users = list.map(sorted_decorated, fn(pair) { pair.0 })
```

## API overview

The library exports a single module `cmp` with the following main functions:

- **Basic comparators**: `natural_int`, `natural_string`, `natural_float`
- **Contramap helpers**: `by`, `by_int`, `by_string`, `by_float`, `by_string_with`, `by_normalized_string`
- **Composition**: `then`, `chain`, `lazy_then`, `reverse`
- **Containers**: `option`, `list_compare`, `pair`, `triple`

See the [full API documentation](https://hexdocs.pm/cmp_gleam/) for details.

## Development

```sh
gleam test  # Run the tests
gleam build # Build the project
```

## License

MIT License - see [LICENSE](LICENSE) file for details.