import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import splitter

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

// remove don'ts recursively
pub fn remove_donts(m: String) -> String {
  let dont_splitter = splitter.new(["don't()"])
  let do_splitter = splitter.new(["do()"])

  case splitter.split_before(dont_splitter, m) {
    // if all the memory is enabled, we're done
    #(enabled_mem, "") -> enabled_mem
    // if not, discard all memory up to the next enablement
    #(enabled_mem, rest) -> {
      let #(_, rest) = splitter.split_before(do_splitter, rest)

      // this should be tc optimized
      remove_donts(enabled_mem <> rest)
    }
  }
}

fn remove_until_do(rest: String) -> String {
  case string.split_once(rest, "do()") {
    Error(_) -> rest
    Ok(#(_, rest)) -> remove_donts_stdlib_murec(rest)
  }
}

// delete disabled memory from input
//
// this function does not get to benefit from tail-call optimization
// as it utilizes mutual recursion + concatenates lazily
pub fn remove_donts_stdlib_murec(m: String) -> String {
  case string.split_once(m, "don't()") {
    Error(_) -> m
    Ok(#(enabled_mem, rest)) -> enabled_mem <> remove_until_do(rest)
  }
}

// this function should benefit from tail-call optimization
// to accomplish this it eagerly concatenates, which... may or may not be bad
// i'm not sure
pub fn remove_donts_stdlib_tco(m: String) -> String {
  case string.split_once(m, "don't()") {
    Error(_) -> m
    Ok(#(enabled_mem, rest)) -> {
      case string.split_once(rest, "do()") {
        Error(_) -> enabled_mem
        Ok(#(_, rest)) -> remove_donts_stdlib_tco(enabled_mem <> rest)
      }
    }
  }
}

// this function is not mutually recursive, but may not benefit from tco
pub fn remove_donts_stdlib_non_tco_nor_murec(m: String) -> String {
  case string.split_once(m, "don't()") {
    Error(_) -> m
    Ok(#(enabled_mem, rest)) -> {
      case string.split_once(rest, "do()") {
        Error(_) -> enabled_mem
        Ok(#(_, rest)) ->
          enabled_mem <> remove_donts_stdlib_non_tco_nor_murec(rest)
      }
    }
  }
}

pub fn sum_do_muls_from(m: String) -> Int {
  // get only the muls after dos
  remove_donts_stdlib_tco(m)
  |> sum_muls_from()
}
