import day4/grid.{type LineView}
import day4/pattern
import gleam/list
import gleam/string
import gleam/yielder

fn scan(for p: String, on line: LineView) -> Int {
  let pattern = pattern.make(p)
  let pattern_length = string.length(p)
  list.fold(
    over: grid.lineview_window(line, by: pattern_length),
    from: 0,
    with: fn(acc: Int, x: List(String)) -> Int {
      case string.concat(x) {
        x if x == pattern.forwards -> acc + 1
        x if x == pattern.backwards -> acc + 1
        _ -> acc + 0
      }
    },
  )
}

pub fn find_all(on s: String, of p: String) -> Result(Int, Nil) {
  case grid.make(s) {
    Error(_) -> Error(Nil)
    Ok(grid) -> {
      Ok(
        grid.line_views(on: grid)
        |> yielder.fold(from: 0, with: fn(acc, lv) {
          acc + scan(for: p, on: lv)
        }),
      )
    }
  }
}
