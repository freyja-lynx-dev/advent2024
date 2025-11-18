import advent2024/mem_corrupt
import advent2024/safe_check
import advent2024/total_dist
import ceres_search
import gleam/result
import simplifile

pub fn main() -> Nil {
  total_dist.total_distance()
  safe_check.safe_check()
  let assert Ok(s) = simplifile.read("day3_data")
  echo mem_corrupt.sum_muls_from(s)
  echo mem_corrupt.sum_do_muls_from(s)
  let assert Ok(s) = simplifile.read("day4_data")
  echo result.unwrap(ceres_search.find_all(s, "XMAS"), -1)
  Nil
}
