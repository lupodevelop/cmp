# cmp_gleam

[![Package Version](https://img.shields.io/hexpm/v/cmp_gleam)](https://hex.pm/packages/cmp_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cmp_gleam/)
[![CI](https://github.com/lupodevelop/cmp/workflows/test/badge.svg)](https://github.com/lupodevelop/cmp/actions)

cmp_gleam: explicit comparator helpers for Gleam

cmp_gleam is a tiny, focused library for building small, composable comparators in Gleam. It intentionally avoids magic (no derives, no hidden behavior) so that comparison logic remains explicit, easy to test and easy to reason about.

Key goals:

- Keep the API small and predictable
- Provide composable building blocks for lexicographic and tie-breaker ordering
- Allow optional normalization/folding (for example using the `str` library) without adding runtime dependencies

Why this approach?

`cmp` favors explicitness over implicit derivation. By making comparators first-class and composable you get predictable behaviour, easier testing, and straightforward integration with normalization libraries when you need to handle real-world Unicode data.

Install

```sh
gleam add cmp_gleam
```

Quick examples 🔧

1. Sort integers

```gleam
import cmp
import gleam/list

pub fn sort_ints(xs: List(Int)) -> List(Int) {
  list.sort(xs, by: cmp.natural_int)
}
```

2. Sort records by a string field (contramap)

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

3. Lexicographic ordering / tie-breakers (chain / then / lazy_then)

```gleam
let cmp = cmp.chain([
  cmp.by(fn(u) { case u { User(name, _) -> name } }, string.compare),
  cmp.by(fn(u) { case u { User(_, age) -> age } }, cmp.natural_int)
])
list.sort(users, by: cmp)
```

4. Integrating with `str` for normalization (e.g. ASCII-fold)

`str` is optional — `cmp` does not import it. You can pass `str` functions to `cmp` APIs such as `by_normalized_string` to fold/normalize before comparing:

```gleam
import cmp
import gleam/list
import gleam/string
import str.extra

pub fn sort_by_name_ascii_fold(users: List(User)) -> List(User) {
  let normalize = str.extra.ascii_fold
  let cmp_name = cmp.by_normalized_string(fn(u) { case u { User(name, _) -> name } }, normalize, string.compare)
  list.sort(users, by: cmp_name)
}
```

You can also combine normalization steps (for example: fold + lowercase):

```gleam
let normalize = fn(s) { s |> str.extra.ascii_fold |> string.lowercase }
```

5. Using metrics (similarity/distance) to order items (advanced example)

⚠️ **Warning**: similarity/distance metrics don't guarantee transitivity (a < b and b < c doesn't always imply a < c). If you need a total order, sort by the metric value itself rather than using it directly as a comparator.

```gleam
import gleam/order

// Example: sort by similarity to a reference string (careful: not a total order!)
let similarity_cmp = fn(a, b) {
  let s = str.similarity(a, b)
  case s > 0.8 { True -> order.Lt False -> order.Gt }
}
let cmp_sim = cmp.by(fn(u) { case u { User(name, _) -> name } }, similarity_cmp)
```

Better approach for metrics:

```gleam
// Compute similarity as Float, then sort by that value
let reference = "Alice"
let with_similarity = list.map(users, fn(u) {
  let sim = str.similarity(u.name, reference)
  #(u, sim)
})
let sorted = list.sort(with_similarity, by: cmp.by(fn(pair) { pair.1 }, float.compare))
```

Unicode & normalization notes ⚠️

- `string.compare` compares strings as-is; composed vs decomposed characters may behave differently if not normalized.
- For user-facing sorting (names, titles), it is recommended to **normalize** (NFC/NFD) or apply folding (remove accents) before comparing.
- `str` provides useful primitives (`str.extra.ascii_fold`, `str.core.normalize_whitespace`, etc.) which you can pass directly to `cmp`.

Performance tip: for large lists, precompute normalized keys

When sorting large lists by normalized strings, calling `normalize` on every comparison is expensive. Use the decorate-sort-undecorate pattern:

```gleam
import gleam/list

// Precompute normalized keys once
let decorated = list.map(users, fn(u) {
  let normalized_name = str.extra.ascii_fold(u.name)
  #(u, normalized_name)
})

// Sort by the precomputed key
let sorted_decorated = list.sort(decorated, by: cmp.by(fn(pair) { pair.1 }, string.compare))

// Extract the original values
let sorted_users = list.map(sorted_decorated, fn(pair) { pair.0 })
```

Further documentation and examples will be published on <https://hexdocs.pm/cmp_gleam>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```