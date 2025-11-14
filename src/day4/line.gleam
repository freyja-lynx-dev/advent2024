import day4/coordinate.{type Coordinate}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder.{type Step, type Yielder, Done, Next}

pub type Line {
  Line(origin: Coordinate, end: Coordinate, direction: Direction)
}

pub type Direction {
  Horizontal
  Vertical
  DiagonalRising
  DiagonalFalling
}

fn slope_for_direction(d: Direction) -> #(Int, Int) {
  case d {
    Horizontal -> #(1, 0)
    Vertical -> #(0, 1)
    // falling and rising are reversed as our grid perspective is
    // top to bottom... this is a bit confusing, but i'm not gonna change it
    DiagonalFalling -> #(1, 1)
    DiagonalRising -> #(-1, -1)
  }
}
