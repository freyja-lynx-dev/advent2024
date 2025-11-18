import day4/coordinate.{
  type Bounds, type Coordinate, type EdgeCoordinate, Backwards, Forwards,
}
import day4/line.{type Line, DiagonalFalling, DiagonalRising, Line, Vertical}
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder, Done, Next, empty}

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
  let coordinate: Coordinate = coordinate.Coordinate(x:, y:)
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
pub fn make(input: String) -> Result(Grid, Nil) {
  string.split(input, on: "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.index_map(with: fn(row, y) {
    // transform each row into a #(size_of_dict, dict)
    let row_dict = string_to_coordinates(0, y, row, dict.new())
    let size_of_dict = dict.size(row_dict)

    #(size_of_dict, row_dict)
  })
  |> try_grid_assemble()
}

pub fn get_horizontal_lines_for_grid(grid: Grid) -> Yielder(Line) {
  yielder.unfold(from: 0, with: fn(n) {
    case n {
      n if n == grid.rows -> Done
      n ->
        Next(
          element: Line(
            origin: coordinate.Coordinate(0, n),
            end: coordinate.Coordinate(grid.columns - 1, n),
            direction: line.Horizontal,
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
            origin: coordinate.Coordinate(n, 0),
            end: coordinate.Coordinate(n, grid.columns - 1),
            direction: Vertical,
          ),
          accumulator: n + 1,
        )
    }
  })
}

fn make_bounds(from g: Grid) -> Bounds {
  let x_bound = g.columns - 1
  let y_bound = g.rows - 1
  coordinate.make_bounds(x_bound, y_bound)
}

pub fn diagonal_falling_lines(for g: Grid) -> Result(Yielder(Line), Nil) {
  // so now that we have edge lines:
  // > make edge lines for origin and antiorigin
  // > zip the coordinate pairs together as a yielder

  // get bounds for grid
  let grid_bounds = make_bounds(from: g)

  // in order to get the prime origin, we need the coordinate at 0,rows-2
  use origins_start <- result.try(
    coordinate.make(0, g.rows - 2)
    |> coordinate.try_make_edge_coordinate(
      with: grid_bounds,
      direction: Backwards,
    ),
  )

  use ends_start <- result.try(
    coordinate.make(1, g.rows - 1)
    |> coordinate.try_make_edge_coordinate(
      with: grid_bounds,
      direction: Forwards,
    ),
  )
  // let origins_end = coordinate.make(g.columns - 2, 0)

  // let ends_end = coordinate.make(g.columns - 1, 1)

  Ok(
    yielder.unfold(from: #(origins_start, ends_start), with: fn(coordinates) {
      let #(next_origin, next_end) = coordinates
      let origin = coordinate.downcast_edge_coordinate(next_origin)
      let end = coordinate.downcast_edge_coordinate(next_end)
      case coordinate.magnitude_between(origin, end) {
        // the corners are the base case and they have magnitude 0,0
        #(0, 0) -> Done
        #(_, _) ->
          Next(
            Line(origin: origin, end: end, direction: DiagonalFalling),
            accumulator: #(
              coordinate.next(next_origin),
              coordinate.next(next_end),
            ),
          )
      }
    }),
  )
}

pub fn diagonal_rising_lines(for g: Grid) -> Result(Yielder(Line), Nil) {
  let grid_bounds = make_bounds(from: g)

  // in order to get the prime origin, we need the coordinate at 0,rows-2
  use origins_start <- result.try(
    coordinate.make(0, 1)
    |> coordinate.try_make_edge_coordinate(
      with: grid_bounds,
      direction: Forwards,
    ),
  )

  use ends_start <- result.try(
    coordinate.make(1, 0)
    |> coordinate.try_make_edge_coordinate(
      with: grid_bounds,
      direction: Forwards,
    ),
  )

  Ok(
    yielder.unfold(from: #(origins_start, ends_start), with: fn(coordinates) {
      let #(next_origin, next_end) = coordinates
      let origin = coordinate.downcast_edge_coordinate(next_origin)
      let end = coordinate.downcast_edge_coordinate(next_end)
      case coordinate.magnitude_between(origin, end) {
        // the corners are the base case and they have magnitude 0,0
        #(0, 0) -> Done
        #(_, _) ->
          Next(
            Line(origin: origin, end: end, direction: DiagonalRising),
            accumulator: #(
              coordinate.next(next_origin),
              coordinate.next(next_end),
            ),
          )
      }
    }),
  )
}

// Returns all possible lines for the given grid
pub fn lines(
  grid: Grid,
) -> #(Yielder(Line), Yielder(Line), Yielder(Line), Yielder(Line)) {
  let horizontal_lines = get_horizontal_lines_for_grid(grid)
  let vertical_lines = get_vertical_lines_for_grid(grid)
  let diagonal_falling_lines =
    result.unwrap(diagonal_falling_lines(grid), empty())
  //echo yielder.to_list(diagonal_falling_lines)
  let diagonal_rising_lines =
    result.unwrap(diagonal_rising_lines(grid), empty())
  //echo yielder.to_list(diagonal_rising_lines)

  // todo: just return a single yielder, we don't need to know the internal
  // representation outside of this module
  #(
    horizontal_lines,
    vertical_lines,
    diagonal_falling_lines,
    diagonal_rising_lines,
  )
}

// 
fn make_edge_line(
  from start: EdgeCoordinate,
  to end: EdgeCoordinate,
) -> Yielder(EdgeCoordinate) {
  let end_plus = coordinate.next(end)
  echo end_plus
  yielder.unfold(from: start, with: fn(cur) {
    let next_coordinate = coordinate.next(cur)
    case next_coordinate {
      c if c == end_plus -> Done
      c -> Next(element: cur, accumulator: c)
    }
  })
}

pub fn edge_line(
  from a: EdgeCoordinate,
  to b: EdgeCoordinate,
) -> Result(Yielder(EdgeCoordinate), Nil) {
  let end = coordinate.next(b)
  case a, b {
    // if the coordinates are the same, it doesn't make sense to make an edgeline
    _, _ if a == b -> Error(Nil)
    // the happy case :)
    start, _ -> Ok(make_edge_line(from: start, to: end))
  }
}
