import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub type Pattern {
  Pattern(forwards: String, backwards: String)
}

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub type Instance {
  Instance(coordinates: List(Coordinate))
}

pub type Grid {
  Grid(grid: #(Coordinate, String))
}

// we treat a string as a row of letters
// starting from (0,y) we recursively deconstruct the string
// saving it in the provided dictionary keyed by its coordinates
pub fn string_to_coordinates(
  // dependent
  x: Int,
  // static
  y: Int,
  s: String,
  d: Dict(Coordinate, String),
) -> Dict(Coordinate, String) {
  let coordinate: Coordinate = Coordinate(x:, y:)
  case string.pop_grapheme(s) {
    // we should never get here but it won't change anything if we do
    Error(_) -> d
    // true base case, we can just avoid calling on empty string
    Ok(#(c, "")) -> dict.insert(into: d, for: coordinate, insert: c)
    Ok(#(c, rest)) -> {
      string_to_coordinates(
        // we're working horizontally
        x + 1,
        y,
        rest,
        dict.insert(into: d, for: coordinate, insert: c),
      )
    }
  }
}

pub fn make_grid_from(i: String) -> Result(Grid, Nil) {
  string.split("\n", on: i)
  // transform each row into a dict
  // then verify each row is the same length
  // then make it into a grid
  |> list.map(fn(x) { todo })
  Error(Nil)
}

pub fn find_all_of_pattern(s: String, pattern: String) -> Int {
  // we must look for the pattern forwards and backwards in each row, column, and diagonal
  // so what's the best way of doing this
  //
  // we could make three lists:
  //   - list of rows
  //   - list of columns
  //   - list of diagonals
  //
  // then it is as simple as mapping the search function over each row/column/diagonal,
  //   once for each pattern
  //
  // we will have n rows, m columns, and 2((n*m)-1) diagonals
  // so we could derive the coordinates to check, then simply iterate over them
  0
}
