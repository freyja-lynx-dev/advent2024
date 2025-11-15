import ceres_search
import day4/coordinate.{type Coordinate, Coordinate}
import day4/grid.{type Grid, Grid}
import day4/line.{
  type Line, DiagonalFalling, DiagonalRising, Horizontal, Line, Vertical,
}
import day4/pattern.{type Pattern, Pattern}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/yielder
import gleeunit

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

pub fn string_to_coordinates_test() {
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

pub fn make_grid_from_test() {
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
      Line(Coordinate(0, 0), Coordinate(2, 0), Horizontal),
      Line(Coordinate(0, 1), Coordinate(2, 1), Horizontal),
      Line(Coordinate(0, 2), Coordinate(2, 2), Horizontal),
    ]
    == lines
}

pub fn get_vertical_lines_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let lines =
    grid.get_vertical_lines_for_grid(g)
    |> yielder.to_list()

  assert [
      Line(Coordinate(0, 0), Coordinate(0, 2), Vertical),
      Line(Coordinate(1, 0), Coordinate(1, 2), Vertical),
      Line(Coordinate(2, 0), Coordinate(2, 2), Vertical),
    ]
    == lines
}

pub fn get_diagonal_falling_lines_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let lines =
    grid.get_diagonal_falling_lines_for_grid(g)
    |> yielder.to_list()

  assert [
      Line(Coordinate(0, 1), Coordinate(1, 2), DiagonalFalling),
      Line(Coordinate(0, 0), Coordinate(2, 2), DiagonalFalling),
      Line(Coordinate(1, 0), Coordinate(2, 1), DiagonalFalling),
    ]
    == lines
}

pub fn get_diagonal_rising_lines_test() {
  let assert Ok(g) = grid.make(ceres_search_3x3_grid())

  let lines =
    grid.get_diagonal_rising_lines_for_grid(g)
    |> yielder.to_list()

  assert [
      Line(Coordinate(0, 1), Coordinate(1, 0), DiagonalRising),
      Line(Coordinate(0, 2), Coordinate(2, 0), DiagonalRising),
      Line(Coordinate(1, 2), Coordinate(2, 1), DiagonalRising),
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

  let #(h, v, df, dr) = grid.lines(g)

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

  let #(h, v, df, dr) = grid.lines(g)

  let lengths = [
    yielder.length(h),
    yielder.length(v),
    yielder.length(df),
    yielder.length(dr),
  ]

  // you might wonder: shouldn't we ensure the lines are what we expect
  // oh, but you poor thing myself, we're going to test line generation
  // in another unit test. so we don't need to double check our work.
  assert [4, 10, 11, 11] == lengths

  // we should yield all 54 lines from our four generators altogether
  assert total_lines == list.fold(lengths, 0, fn(acc, x) { acc + x })
}

pub fn ceres_search_test() {
  assert 18
    == option.unwrap(
      ceres_search.find_all_of_pattern(ceres_search_square_grid(), "XMAS"),
      0,
    )
}
