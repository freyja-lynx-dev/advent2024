import day4/grid
import day4/pattern
import gleam/option.{type Option, None, Some}

pub fn find_all_of_pattern(s: String, p: String) -> Option(Int) {
  // here's how we're going to do this:
  // - create the grid
  // - get 4 line generators -- horizontal, vertical, diagonal falling, diagonal rising
  // - search for the pattern in each line
  // - accumulate instances
  let pattern = pattern.make(p)
  case grid.make(s) {
    Error(_) -> None
    Ok(grid) -> {
      grid.lines(grid)
      Some(0)
    }
  }
}
