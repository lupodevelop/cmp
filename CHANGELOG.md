# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-03-20

### Fixed

- Improved `by_normalized_string` test: now uses a real normalizer (`string.lowercase`)
  and verifies that normalization actually changes the comparison result

### Added

- Test for `reverse/1`: covers `Lt↔Gt` inversion and `Eq` stability
- Test for `chain/1` with empty list: verifies it always returns `Eq`
- Expanded doc comment for `reverse/1` with example and explicit description of behaviour

## [1.0.0] - 2026-03-18

### Added

- `Comparator(a)` type alias (`fn(a, a) -> order.Order`)
- Basic comparators: `natural_int/2`, `natural_string/2`, `natural_float/2`
- Contramap helpers: `by/2`, `by_int/1`, `by_string/1`, `by_float/1`,
  `by_string_with/2`, `by_normalized_string/3`
- Composition: `then/2`, `chain/1`, `lazy_then/2`, `reverse/1`
- Container comparators: `option/2`, `pair/2`, `triple/3`, `list_compare/1`
- Full test suite with gleeunit
- README with design philosophy, usage examples, and Unicode normalization guide

[1.0.1]: https://github.com/lupodevelop/cmp/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/lupodevelop/cmp/releases/tag/v1.0.0
