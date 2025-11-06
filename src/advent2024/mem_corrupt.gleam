import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/result

pub type Mul {
  Mul(a: Int, b: Int, res: Int)
}

fn make_mul_from_match(m: List(Option(String))) -> Option(Mul) {
  let nums =
    option.values(m)
    |> list.map(fn(x) { result.unwrap(int.parse(x), -1) })

  case nums {
    [a, b] -> option.Some(Mul(a:, b:, res: a * b))
    _ -> option.None
  }
}

// just return the sum
fn recover_muls(m: String) -> List(Option(Mul)) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  let matches = regexp.scan(re, m)
  list.map(matches, fn(x) {
    let options = x.submatches
    make_mul_from_match(options)
  })
}

pub fn sum_muls_from(m: String) -> Int {
  list.fold(recover_muls(m), 0, fn(acc, x) {
    case x {
      option.Some(Mul(_, _, res:)) -> acc + res
      option.None -> acc
    }
  })
}
