import ceres_search
import day4/bounds
import day4/coordinate.{type Coordinate, Coordinate}
import day4/direction.{DiagonalFalling, DiagonalRising, Horizontal, Vertical}
import day4/edge_coordinate.{Bottom, EdgeCoordinate, Forwards, Left, Right, Top}
import day4/grid.{Grid, GridLine}
import day4/line.{Line}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/yielder

fn ceres_search_square_grid() -> String {
  "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"
}

fn ceres_search_rectangle_grid() -> String {
  "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX"
}

pub fn grid_string_to_coordinates_test() {
  let row_data = "MMMSXXMASM"
  let row =
    dict.from_list([
      #(coordinate.make(0, 0), "M"),
      #(coordinate.make(1, 0), "M"),
      #(coordinate.make(2, 0), "M"),
      #(coordinate.make(3, 0), "S"),
      #(coordinate.make(4, 0), "X"),
      #(coordinate.make(5, 0), "X"),
      #(coordinate.make(6, 0), "M"),
      #(coordinate.make(7, 0), "A"),
      #(coordinate.make(8, 0), "S"),
      #(coordinate.make(9, 0), "M"),
    ])

  let constructed_row = grid.string_to_coordinates(0, 0, row_data, dict.new())
  assert row == constructed_row
}

pub fn grid_make_test() {
  let row_data =
    "MMMSXXMASM
MSAMXMSMSA"
  let parsed_rows: Dict(Coordinate, String) =
    dict.from_list([
      #(Coordinate(0, 0), "M"),
      #(Coordinate(1, 0), "M"),
      #(Coordinate(2, 0), "M"),
      #(Coordinate(3, 0), "S"),
      #(Coordinate(4, 0), "X"),
      #(Coordinate(5, 0), "X"),
      #(Coordinate(6, 0), "M"),
      #(Coordinate(7, 0), "A"),
      #(Coordinate(8, 0), "S"),
      #(Coordinate(9, 0), "M"),
      #(Coordinate(0, 1), "M"),
      #(Coordinate(1, 1), "S"),
      #(Coordinate(2, 1), "A"),
      #(Coordinate(3, 1), "M"),
      #(Coordinate(4, 1), "X"),
      #(Coordinate(5, 1), "M"),
      #(Coordinate(6, 1), "S"),
      #(Coordinate(7, 1), "M"),
      #(Coordinate(8, 1), "S"),
      #(Coordinate(9, 1), "A"),
    ])
  let grid = Grid(grid: parsed_rows, rows: 2, columns: 10)
  let assembled_grid = grid.make(row_data)

  assert grid == result.unwrap(assembled_grid, Grid(dict.new(), 0, 0))
}

fn ceres_search_3x3_grid() -> String {
  "XXX
XXX
XXX"
}

pub fn get_horizontal_lines_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let lines =
    grid.get_horizontal_lines_for_grid(g)
    |> yielder.to_list()

  assert [
      GridLine(Line(Coordinate(0, 0), Coordinate(2, 0), Horizontal)),
      GridLine(Line(Coordinate(0, 1), Coordinate(2, 1), Horizontal)),
      GridLine(Line(Coordinate(0, 2), Coordinate(2, 2), Horizontal)),
    ]
    == lines
}

pub fn get_vertical_lines_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let lines =
    grid.get_vertical_lines_for_grid(g)
    |> yielder.to_list()

  assert [
      GridLine(Line(Coordinate(0, 0), Coordinate(0, 2), Vertical)),
      GridLine(Line(Coordinate(1, 0), Coordinate(1, 2), Vertical)),
      GridLine(Line(Coordinate(2, 0), Coordinate(2, 2), Vertical)),
    ]
    == lines
}

// pub fn is_on_edge_test() {
//   let assert Ok(g) = grid.make(ceres_search_3x3_grid())

//   let a = Coordinate(1, 2)
//   let b = Coordinate(0, 1)
//   let c = Coordinate(2, 1)
//   let d = Coordinate(1, 0)
//   let e = Coordinate(1, 1)

//   assert True == grid.coordinate_on_edge(a, of: g)
//   assert True == grid.coordinate_on_edge(b, of: g)
//   assert True == grid.coordinate_on_edge(c, of: g)
//   assert True == grid.coordinate_on_edge(d, of: g)
//   assert False == grid.coordinate_on_edge(e, of: g)
// }

/// ok so we're trying a new approach for generating diagonal lines:
/// make a yielder that yields every coordinate on the edge of a grid between
/// two edge points
///
/// this allows us to create the diagonal lines by simply zipping the coordinates
/// on opposite edges of the grid. example:
///   1,0 to 3,2 -> [(1,0), (2,0), (3,0), (3,1), (3,2)]  
///   0,1 to 2,3 -> [(0,1), (0,2), (0,3), (1,3), (2,3)]
///
/// as you can see, yielding the coordinates in-step allows us to create the diagonal lines
///
/// the question is, how do we best define this as a type
///
/// maybe the answer is an EdgeLine type that has knowledge of the grid's bounds,
/// and thus can increment its coordinates with a simple int, knowing when to
/// switch from adding to x/y to y/x
///
pub fn make_edgeline_test() {
  let edge_x =
    result.unwrap(
      grid.edge_line(
        from: EdgeCoordinate(1, 0, Top, bounds.make(2, 2), Forwards),
        to: EdgeCoordinate(2, 1, Right, bounds.make(2, 2), Forwards),
      ),
      yielder.empty(),
    )
  assert [Coordinate(1, 0), Coordinate(2, 0), Coordinate(2, 1)]
    == list.map(yielder.to_list(edge_x), fn(x) { edge_coordinate.upcast(x) })

  let edge_y =
    result.unwrap(
      grid.edge_line(
        from: EdgeCoordinate(0, 1, Left, bounds.make(2, 2), Forwards),
        to: EdgeCoordinate(1, 2, Bottom, bounds.make(2, 2), Forwards),
      ),
      yielder.empty(),
    )
  assert [Coordinate(0, 1), Coordinate(0, 2), Coordinate(1, 2)]
    == list.map(yielder.to_list(edge_y), fn(x) { edge_coordinate.upcast(x) })
}

pub fn get_diagonal_falling_lines_for_square_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let assert Ok(lines) = grid.diagonal_falling_lines(g)
  let lines = yielder.to_list(lines)

  assert [
      GridLine(Line(Coordinate(0, 1), Coordinate(1, 2), DiagonalFalling)),
      GridLine(Line(Coordinate(0, 0), Coordinate(2, 2), DiagonalFalling)),
      GridLine(Line(Coordinate(1, 0), Coordinate(2, 1), DiagonalFalling)),
    ]
    == lines
}

pub fn get_diagonal_rising_lines_for_square_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let assert Ok(lines) = grid.diagonal_rising_lines(g)
  let lines = yielder.to_list(lines)

  assert [
      GridLine(Line(Coordinate(0, 1), Coordinate(1, 0), DiagonalRising)),
      GridLine(Line(Coordinate(0, 2), Coordinate(2, 0), DiagonalRising)),
      GridLine(Line(Coordinate(1, 2), Coordinate(2, 1), DiagonalRising)),
    ]
    == lines
}

pub fn get_diagonal_falling_lines_for_rectangle_test() {
  let assert Ok(g) = grid.make(ceres_search_rectangle_grid())

  let assert Ok(lines) = grid.diagonal_falling_lines(g)
  let lines = yielder.to_list(lines)

  assert [
      GridLine(Line(Coordinate(0, 2), Coordinate(1, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(0, 1), Coordinate(2, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(0, 0), Coordinate(3, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(1, 0), Coordinate(4, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(2, 0), Coordinate(5, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(3, 0), Coordinate(6, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(4, 0), Coordinate(7, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(5, 0), Coordinate(8, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(6, 0), Coordinate(9, 3), DiagonalFalling)),
      GridLine(Line(Coordinate(7, 0), Coordinate(9, 2), DiagonalFalling)),
      GridLine(Line(Coordinate(8, 0), Coordinate(9, 1), DiagonalFalling)),
    ]
    == lines
}

pub fn get_diagonal_rising_lines_for_rectangle_test() {
  let assert Ok(g) = grid.make(ceres_search_rectangle_grid())

  let assert Ok(lines) = grid.diagonal_rising_lines(g)
  let lines = yielder.to_list(lines)

  assert [
      GridLine(Line(Coordinate(0, 1), Coordinate(1, 0), DiagonalRising)),
      GridLine(Line(Coordinate(0, 2), Coordinate(2, 0), DiagonalRising)),
      GridLine(Line(Coordinate(0, 3), Coordinate(3, 0), DiagonalRising)),
      GridLine(Line(Coordinate(1, 3), Coordinate(4, 0), DiagonalRising)),
      GridLine(Line(Coordinate(2, 3), Coordinate(5, 0), DiagonalRising)),
      GridLine(Line(Coordinate(3, 3), Coordinate(6, 0), DiagonalRising)),
      GridLine(Line(Coordinate(4, 3), Coordinate(7, 0), DiagonalRising)),
      GridLine(Line(Coordinate(5, 3), Coordinate(8, 0), DiagonalRising)),
      GridLine(Line(Coordinate(6, 3), Coordinate(9, 0), DiagonalRising)),
      GridLine(Line(Coordinate(7, 3), Coordinate(9, 1), DiagonalRising)),
      GridLine(Line(Coordinate(8, 3), Coordinate(9, 2), DiagonalRising)),
    ]
    == lines
}

pub fn get_all_lines_for_square_grid_test() {
  let data = ceres_search_square_grid()
  let assert Ok(g) = grid.make(data)
  // we can infer the amount of lines from
  let total_lines =
    // n+m - 3 unique diagonals (as we exclude single point lines for irrelevancy)
    g.rows + g.columns
    |> int.add(-3)
    // both rising and falling diagonals
    |> int.multiply(2)
    // plus horizontal lines (rows)
    |> int.add(g.rows)
    // plus vertical lines (columns)
    |> int.add(g.columns)

  // check our math with a worked out paper example
  assert 54 == total_lines

  let h = grid.get_horizontal_lines_for_grid(g)
  let v = grid.get_vertical_lines_for_grid(g)
  let assert Ok(df) = grid.diagonal_falling_lines(g)
  let assert Ok(dr) = grid.diagonal_rising_lines(g)

  let lengths = [
    yielder.length(h),
    yielder.length(v),
    yielder.length(df),
    yielder.length(dr),
  ]

  // you might wonder: shouldn't we ensure the lines are what we expect
  // oh, but you poor thing myself, we're going to test line generation
  // in another unit test. so we don't need to double check our work.
  assert [10, 10, 17, 17] == lengths

  // we should yield all 54 lines from our four generators altogether
  assert total_lines == list.fold(lengths, 0, fn(acc, x) { acc + x })
}

pub fn get_all_lines_for_rectangular_grid_test() {
  // 4x10 grid
  let data = ceres_search_rectangle_grid()
  let assert Ok(g) = grid.make(data)
  // we can infer the amount of lines from
  let total_lines =
    // n+m - 3 unique diagonals (as we exclude single point lines for irrelevancy)
    g.rows + g.columns
    |> int.add(-3)
    // both rising and falling diagonals
    |> int.multiply(2)
    // plus horizontal lines (rows)
    |> int.add(g.rows)
    // plus vertical lines (columns)
    |> int.add(g.columns)

  // check our math with a worked out paper example
  // 4 + 10 + 11 + 11 -> 14 + 22 -> 36
  assert 36 == total_lines

  let h = grid.get_horizontal_lines_for_grid(g)
  let v = grid.get_vertical_lines_for_grid(g)
  let assert Ok(df) = grid.diagonal_falling_lines(g)
  let assert Ok(dr) = grid.diagonal_rising_lines(g)

  let lengths = [
    yielder.length(h),
    yielder.length(v),
    yielder.length(df),
    yielder.length(dr),
  ]

  assert [4, 10, 11, 11] == lengths

  // we should yield all 54 lines from our four generators altogether
  assert total_lines == list.fold(lengths, 0, fn(acc, x) { acc + x })
}

pub fn line_points_test() {
  let origin = coordinate.from_tuple(#(0, 0))
  let h_end = coordinate.from_tuple(#(3, 0))
  let v_end = coordinate.from_tuple(#(0, 3))
  let df_end = coordinate.from_tuple(#(3, 3))

  let h_line = line.make(origin, h_end, Horizontal)
  let v_line = line.make(origin, v_end, Vertical)
  let df_line = line.make(origin, df_end, DiagonalFalling)
  let dr_line = line.make(v_end, h_end, DiagonalRising)

  assert [
      Coordinate(0, 0),
      Coordinate(1, 0),
      Coordinate(2, 0),
      Coordinate(3, 0),
    ]
    == line.points(h_line)
    |> yielder.to_list()

  assert [
      Coordinate(0, 0),
      Coordinate(0, 1),
      Coordinate(0, 2),
      Coordinate(0, 3),
    ]
    == line.points(v_line)
    |> yielder.to_list()

  assert [
      Coordinate(0, 0),
      Coordinate(1, 1),
      Coordinate(2, 2),
      Coordinate(3, 3),
    ]
    == line.points(df_line)
    |> yielder.to_list()

  assert [
      Coordinate(0, 3),
      Coordinate(1, 2),
      Coordinate(2, 1),
      Coordinate(3, 0),
    ]
    == line.points(dr_line)
    |> yielder.to_list()
}

pub fn line_window_test() {
  let l =
    line.make(
      Coordinate(0, 0),
      end: Coordinate(3, 3),
      direction: DiagonalFalling,
    )
  assert [
      [Coordinate(0, 0), Coordinate(1, 1)],
      [Coordinate(1, 1), Coordinate(2, 2)],
      [Coordinate(2, 2), Coordinate(3, 3)],
    ]
    == line.window(l, by: 2)
}

pub fn ceres_search_test() {
  assert 18
    == result.unwrap(
      ceres_search.find_all(ceres_search_square_grid(), "XMAS"),
      0,
    )
}
