import gleam/int
import gleam/list
import gleam/option
import gleam/regexp

pub type Mul {
  Mul(vals: #(Int, Int), res: Int)
}

fn make_mul_from_match(m: List(String)) -> Result(Mul, Nil) {
  let nums = list.map(m, int.parse)

  case nums {
    [Ok(a), Ok(b)] -> Ok(Mul(vals: #(a, b), res: a * b))
    // if this happens, lol
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
