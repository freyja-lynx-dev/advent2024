import day4/coordinate.{type Coordinate}
import day4/direction.{type Direction}
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

pub fn points(from l: Line) -> Yielder(Coordinate) {
  let line_slope = direction.slope(for: l.direction)
  let endplus =
    line_slope
    |> coordinate.from_tuple()
    |> coordinate.add(to: l.end)

  yielder.unfold(from: l.origin, with: fn(c) {
    case c {
      c if c == endplus -> Done
      c -> {
        Next(
          c,
          accumulator: coordinate.add(
            this: coordinate.from_tuple(line_slope),
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
