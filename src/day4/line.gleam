import day4/coordinate.{type Coordinate}
import gleam/list
import gleam/yielder.{type Yielder, Done, Next}

pub type Line {
  Line(origin: Coordinate, end: Coordinate, direction: Direction)
}

pub fn make(
  origin o: Coordinate,
  end e: Coordinate,
  direction d: Direction,
) -> Line {
  Line(origin: o, end: e, direction: d)
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
    DiagonalRising -> #(1, -1)
  }
}

pub fn points(from l: Line) -> Yielder(Coordinate) {
  let line_slope = slope_for_direction(l.direction)
  let endplus =
    line_slope
    |> coordinate.upcast()
    |> coordinate.add(to: l.end)

  yielder.unfold(from: l.origin, with: fn(c) {
    case c {
      c if c == endplus -> Done
      c -> {
        Next(
          c,
          accumulator: coordinate.add(
            this: coordinate.upcast(line_slope),
            to: c,
          ),
        )
      }
    }
  })
}

/// Returns a sliding list of coordinate windows.
pub fn window(l: Line, by n: Int) -> List(List(Coordinate)) {
  points(l)
  |> yielder.to_list()
  |> list.window(by: n)
}
