import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn get_total_distance_between(arg1: List(Int), arg2: List(Int)) -> Int {
  let arg1 = list.sort(arg1, int.compare)
  let arg2 = list.sort(arg2, int.compare)
  list.map2(arg1, arg2, distance)
  |> list.fold(0, int.add)
}

fn distance(x: Int, y: Int) -> Int {
  int.absolute_value(x - y)
}

pub fn total_distance() -> Nil {
  let assert Ok(day1_data) = simplifile.read(from: "day1_data")
  let #(parsed_l1, parsed_l2) =
    split_string_by_newline(day1_data)
    |> list.map(split_string_by_triple_spaces)
    |> list.map(parse_string_into_ints)
    |> list.map(unwrap_results_to_ints)
    |> list.unzip()
  echo get_total_distance_between(parsed_l1, parsed_l2)

  Nil
}

fn unwrap_results_to_ints(l: List(Result(Int, a))) -> #(Int, Int) {
  case l {
    [Ok(x), Ok(y)] -> #(x, y)
    _ -> #(0, 0)
  }
}

fn split_string_by_newline(l: String) -> List(String) {
  string.split(l, "\n")
}

fn split_string_by_triple_spaces(l: String) -> List(String) {
  string.split(l, "   ")
}

fn parse_string_into_ints(l: List(String)) -> List(Result(Int, Nil)) {
  list.map(l, int.parse)
}
