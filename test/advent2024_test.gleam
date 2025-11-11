import advent2024/mem_corrupt
import advent2024/safe_check
import advent2024/total_dist
import gleam/list
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn total_distance_test() {
  let l1 = [3, 4, 2, 1, 3, 3]
  let l2 = [4, 3, 5, 3, 9, 3]

  assert 11 == total_dist.get_total_distance_between(l1, l2)
}

fn safe_check_test_data() -> List(List(Int)) {
  [
    // safe, all decreasing
    [7, 6, 4, 2, 1],
    // unsafe, 2->7 is 5
    [1, 2, 7, 8, 9],
    // unsafe, 6-> is -4
    [9, 7, 6, 2, 1],
    // unsafe, mixed decrease/increase
    [1, 3, 2, 4, 5],
    // unsafe, 4->4 is not decrease/increase
    [8, 6, 4, 4, 1],
    // safe, all increasing
    [1, 3, 6, 7, 9],
  ]
}

pub fn safe_check_is_ordered_test() {
  assert [True, True, True, False, False, True]
    == list.map(safe_check_test_data(), fn(x) {
      list.window_by_2(x)
      |> safe_check.is_ordered
    })
}

pub fn safe_check_differing_test() {
  assert [True, False, False, True, False, True]
    == list.map(safe_check_test_data(), fn(x) {
      list.window_by_2(x)
      |> safe_check.check_differing
    })
}

pub fn safe_check_is_report_safe_test() {
  assert [True, False, False, False, False, True]
    == list.map(safe_check_test_data(), safe_check.is_report_safe)
}

pub fn mem_corrupt_test() {
  let test_data =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

  assert 161 == mem_corrupt.sum_muls_from(test_data)
}

pub fn remove_donts_test() {
  let test_data =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  assert "xmul(2,4)&mul[3,7]!^do()?mul(8,5))"
    == mem_corrupt.remove_donts(test_data)
}

pub fn remove_donts_stdlib_murec_test() {
  let test_data =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  assert "xmul(2,4)&mul[3,7]!^?mul(8,5))"
    == mem_corrupt.remove_donts_stdlib_murec(test_data)
}

pub fn remove_donts_stdlib_non_tco_nor_murec_test() {
  let test_data =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  assert "xmul(2,4)&mul[3,7]!^?mul(8,5))"
    == mem_corrupt.remove_donts_stdlib_non_tco_nor_murec(test_data)
}

pub fn remove_donts_stdlib_tco_test() {
  let test_data =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  assert "xmul(2,4)&mul[3,7]!^?mul(8,5))"
    == mem_corrupt.remove_donts_stdlib_tco(test_data)
}
