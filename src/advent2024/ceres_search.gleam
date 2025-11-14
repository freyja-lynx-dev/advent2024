import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder.{type Step, type Yielder, Done, Next}

pub type Pattern {
  Pattern(forwards: String, backwards: String)
}

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub type Direction {
  Horizontal
  Vertical
  DiagonalRising
  DiagonalFalling
}

// we can use gleam/yielder to infer the midpoints
pub type Line {
  Line(origin: Coordinate, end: Coordinate, direction: Direction)
}

pub type Grid {
  Grid(grid: Dict(Coordinate, String), rows: Int, columns: Int)
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

// Creates a dict by merging all dicts in the given list
fn merge_dicts_from(l: List(Dict(a, b))) -> Dict(a, b) {
  list.fold(over: l, from: dict.new(), with: fn(acc, x) { dict.merge(acc, x) })
}

// Attempts to make a grid, failing if rows are not evenly sized
fn try_grid_assemble(
  from: List(#(Int, Dict(Coordinate, String))),
) -> Result(Grid, Nil) {
  let #(sizes, dicts) = list.unzip(from)

  case list.unique(sizes) {
    // if we only get one unique size, all the rows are the same size
    [row_length] -> {
      Ok(Grid(
        grid: merge_dicts_from(dicts),
        columns: row_length,
        rows: list.length(dicts),
      ))
    }
    // otherwise, we don't have a proper grid
    _ -> Error(Nil)
  }
}

// 
pub fn make_grid_from(input: String) -> Result(Grid, Nil) {
  string.split(input, on: "\n")
  |> list.index_map(with: fn(row, y) {
    // transform each row into a #(size_of_dict, dict)
    let row_dict = string_to_coordinates(0, y, row, dict.new())
    let size_of_dict = dict.size(row_dict)

    #(size_of_dict, row_dict)
  })
  |> try_grid_assemble()
}

fn make_pattern(p: String) -> Pattern {
  Pattern(p, string.reverse(p))
}

pub fn get_horizontal_lines_for_grid(grid: Grid) -> Yielder(Line) {
  yielder.unfold(from: 0, with: fn(n) {
    case n {
      n if n == grid.rows -> Done
      n ->
        Next(
          element: Line(
            origin: Coordinate(0, n),
            end: Coordinate(grid.columns - 1, n),
            direction: Horizontal,
          ),
          accumulator: n + 1,
        )
    }
  })
}

pub fn get_vertical_lines_for_grid(grid: Grid) -> Yielder(Line) {
  yielder.unfold(from: 0, with: fn(n) {
    case n {
      n if n == grid.columns -> Done
      n ->
        Next(
          element: Line(
            origin: Coordinate(n, 0),
            end: Coordinate(n, grid.columns - 1),
            direction: Vertical,
          ),
          accumulator: n + 1,
        )
    }
  })
}

pub fn get_diagonal_falling_lines_for_grid(grid: Grid) -> Yielder(Line) {
  // we start from (x,y) on the grid
  // iterate each point (1,1) until we run out of grid
  // the point that we end on, is the endpoint of the line
  // 3x3 grid example:
  // 0 1 2
  // 1
  // 2
  // |> [Line((0,0), (2,2)), Line((0,1),(1,2)), Line((1,0),(2,1))]
  //
  // origins: (0, 0 <= y < rows, step: (0,1)) and (1 <= x < columns, 0, step: (1,0))
  // ends: (columns > x >= 0 , y = rows-1, step: (-1,0)) and (x = columns-1, rows > y >= 0, step: (0,-1))
  let midline = [
    Line(
      Coordinate(0, 0),
      Coordinate(grid.columns - 1, grid.rows - 1),
      DiagonalFalling,
    ),
  ]
  let bottom_lines = []
  let top_lines = []

  top_lines
  |> list.prepend(this: midline)
  |> list.prepend(this: bottom_lines)
  |> list.flatten()
  |> yielder.from_list()
}

pub fn get_diagonal_rising_lines_for_grid(grid: Grid) -> Yielder(Line) {
  // we start from (x,y) on the grid
  // iterate each point (1,1) until we run out of grid
  // the point that we end on, is the endpoint of the line
  // 3x3 grid example:
  // 0 1 2
  // 1
  // 2
  // |> [Line((0,2), (2,0)), Line((0,1),(1,0)), Line((1,2),(2,1))]
  //
  // origins: (x=0, rows > y >= 0, step: (0,-1)) and (1 <= x < columns, y = rows-1, step: (1,0))
  // ends: (columns > x > 0, y = 0, step: (-1, 0)) and (x = columns-1, rows > y > 0, step: (0,-1))
  let midline = [
    Line(
      Coordinate(0, grid.rows - 1),
      Coordinate(grid.columns - 1, 0),
      DiagonalRising,
    ),
  ]
  let bottom_lines = []
  let top_lines = []

  top_lines
  |> list.prepend(this: midline)
  |> list.prepend(this: bottom_lines)
  |> list.flatten()
  |> yielder.from_list()
}

pub fn get_all_lines_for_grid(
  grid: Grid,
) -> #(Yielder(Line), Yielder(Line), Yielder(Line), Yielder(Line)) {
  let horizontal_lines = get_horizontal_lines_for_grid(grid)
  echo yielder.to_list(horizontal_lines)
  let vertical_lines = get_vertical_lines_for_grid(grid)
  echo yielder.to_list(vertical_lines)
  let diagonal_falling_lines = get_diagonal_falling_lines_for_grid(grid)
  echo yielder.to_list(diagonal_falling_lines)
  let diagonal_rising_lines = get_diagonal_rising_lines_for_grid(grid)
  echo yielder.to_list(diagonal_rising_lines)
  #(
    horizontal_lines,
    vertical_lines,
    diagonal_falling_lines,
    diagonal_rising_lines,
  )
}

pub fn find_all_of_pattern(s: String, pattern: String) -> Option(Int) {
  // here's how we're going to do this:
  // - create the grid
  // - get 4 line generators -- horizontal, vertical, diagonal falling, diagonal rising
  // - search for the pattern in each line
  // - accumulate instances
  let pattern = make_pattern(pattern)
  case make_grid_from(s) {
    Error(_) -> None
    Ok(grid) -> {
      get_all_lines_for_grid(grid)
      Some(0)
    }
  }
}
