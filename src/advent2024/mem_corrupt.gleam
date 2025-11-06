import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/result

pub type Mul {
  Mul(a: Int, b: Int, res: Int)
}

fn grab_ints_from_match(m: List(Option(String))) -> #(Int, Int) {
  let nums =
    option.values(m)
    |> list.map(fn(x) { result.unwrap(int.parse(x), -1) })

  case nums {
    [a, b] -> #(a, b)
    _ -> {
      io.print_error("Malformed mul, somehow?")
      #(0, 0)
    }
  }
}

// just return the sum
fn recover_muls(m: String) -> List(Mul) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  let matches = regexp.scan(re, m)
  list.map(matches, fn(x) {
    let options: List(Option(String)) = x.submatches
    let #(a, b) = grab_ints_from_match(options)
    Mul(a:, b:, res: a * b)
  })
}

pub fn sum_muls_from(m: String) -> Int {
  list.fold(recover_muls(m), 0, fn(acc, x) { acc + x.res })
}
