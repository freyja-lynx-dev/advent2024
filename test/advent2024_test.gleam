import advent2024/total_dist
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
