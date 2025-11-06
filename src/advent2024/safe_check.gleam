import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn safe_check() {
  let assert Ok(day2_data) = simplifile.read(from: "day2_data")
  day2_data
  |> string.split("\n")
  |> list.filter(fn(x) { string.length(x) > 0 })
  |> list.map(fn(x) { string.split(x, " ") })
  |> list.map(parse_string_into_ints)
  |> list.map(result.values)
  |> list.fold(0, fn(acc, x) {
    case is_report_safe(x) {
      True -> acc + 1
      False -> acc
    }
  })
  |> echo
  Nil
}

fn parse_string_into_ints(l: List(String)) -> List(Result(Int, Nil)) {
  list.map(l, int.parse)
}

pub fn is_report_safe(l: List(Int)) -> Bool {
  check_report_safe(l)
}

fn check_report_safe(l: List(Int)) -> Bool {
  // Levels must be all increasing or decreasing
  // Any two adjacent levels must differ by no more than 3 and no less than 1
  let l = list.window_by_2(l)
  is_ordered(l) && check_differing(l)
}

pub fn is_ordered(l: List(#(Int, Int))) -> Bool {
  // transform windows into comparisons
  let l_comps =
    list.map(l, fn(x) {
      case x {
        #(a, b) -> int.compare(a, b)
      }
    })

  let comparisons: Set(Order) = set.from_list(l_comps)

  let has_eq = set.contains(comparisons, order.Eq)

  case set.size(comparisons) {
    _ if has_eq -> False
    1 -> True
    _ -> False
  }
}

pub fn check_differing(l: List(#(Int, Int))) -> Bool {
  list.map(l, fn(x) {
    let #(a, b) = x
    int.absolute_value(a - b)
  })
  |> list.fold(True, fn(acc, x) {
    case x {
      1 -> acc
      2 -> acc
      3 -> acc
      _ -> acc && False
    }
  })
}
