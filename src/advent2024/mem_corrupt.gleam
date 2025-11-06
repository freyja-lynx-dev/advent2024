import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/result

pub type Mul {
  Mul(vals: #(Int, Int), res: Int)
}

fn make_mul_from_match(m: List(String)) -> Result(Mul, Nil) {
  let nums = list.map(m, fn(x) { result.unwrap(int.parse(x), -1) })

  case nums {
    // explicit failure case in case of invalid submatches, should never happen
    // we want to catch this before the general pair case as guards aren't valid
    // in gleam case expressions
    //
    // note: theoretically this might happen on an input with an int too large to
    // represent, on javascript runtime, which we aren't using
    [-1, -1] -> Error(Nil)
    // valid pair of ints, make the mul
    [a, b] -> Ok(Mul(vals: #(a, b), res: a * b))
    // implicit failure case that should never happen
    _ -> Error(Nil)
  }
}

fn recover_muls(m: String) -> List(Mul) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  let matches = regexp.scan(re, m)

  list.filter_map(matches, fn(x) {
    option.values(x.submatches)
    |> make_mul_from_match()
  })
}

pub fn sum_muls_from(m: String) -> Int {
  recover_muls(m)
  |> list.fold(0, fn(acc, mul) { acc + mul.res })
}
