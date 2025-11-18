import day4/coordinate.{type Coordinate}
import day4/grid.{type Grid}
import day4/line
import day4/pattern
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/yielder

pub fn coord_list_to_string(l: List(Coordinate), on g: Grid) -> String {
  list.try_map(l, fn(x) { dict.get(g.grid, x) })
  // i don't like this
  // we can probably leverage types to prevent this unwrapping
  // but for now lets see if it works
  |> result.unwrap(or: ["SOMETHING IS VERY VERY WRONG!!!!"])
  |> string.concat()
}

pub fn find_all_of_pattern(s: String, p: String) -> Result(Int, Nil) {
  // here's how we're going to do this:
  // - create the grid
  // - get 4 line generators -- horizontal, vertical, diagonal falling, diagonal rising
  // - search for the pattern in each line
  // - accumulate instances
  let pattern = pattern.make(p)
  let pattern_length = string.length(p)
  case grid.make(s) {
    Error(_) -> Error(Nil)
    Ok(grid) -> {
      let #(h, v, df, dh) = grid.lines(grid)
      let y =
        yielder.append(h, v)
        |> yielder.append(df)
        |> yielder.append(dh)

      Ok(
        yielder.fold(y, from: 0, with: fn(acc, element) {
          let string_windows =
            line.window(element, by: pattern_length)
            |> list.map(fn(a) { coord_list_to_string(a, on: grid) })

          list.fold(string_windows, 0, fn(acc, x) {
            case x {
              x if x == pattern.forwards -> acc + 1
              x if x == pattern.backwards -> acc + 1
              _ -> acc + 0
            }
          })
          |> int.add(acc)
        }),
      )
    }
  }
}
