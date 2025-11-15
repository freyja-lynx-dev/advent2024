import day4/bound.{type Bound, Bound}
import gleam/int

pub type Coordinate {
  // Arbitrary coordinate in arbitrary space.
  Coordinate(x: Int, y: Int)
  // Arbitrary coordinate in a defined space. 
  BoundedCoordinate(x: Int, y: Int, x_bounds: Bound, y_bounds: Bound)
}

// Creates an arbitrary coordinate given an X and a Y.
pub fn make(x: Int, y: Int) {
  Coordinate(x, y)
}

pub fn make_bounded(
  x_seed: Int,
  y_seed: Int,
  x_bounds: Bound,
  y_bounds: Bound,
) -> Coordinate {
  BoundedCoordinate(x_seed, y_seed, x_bounds, y_bounds)
}

/// Subtract two coordinates arbitrarily.
/// This ignores bounds! 
pub fn subtract(this a: Coordinate, from b: Coordinate) -> Coordinate {
  Coordinate(b.x - a.x, b.y - a.y)
}

// Subtract two coordinates, respecting their bounds
pub fn subtract_bounded(this a: Coordinate, from b: Coordinate) -> Coordinate {
  case a, b {
    Coordinate(ax, ay), Coordinate(bx, by) -> Coordinate(bx - ax, by - ay)
    BoundedCoordinate(ax, ay, ax_bounds, ay_bounds),
      BoundedCoordinate(bx, by, bx_bounds, by_bounds)
    -> {
      let candidate_coord = subtract(this: a, from: b)
      case candidate_coord {
        BoundedCoordinate(x:, y:, x_bounds:, y_bounds:) -> todo
        Coordinate(x:, y:) -> todo
      }
    }
    BoundedCoordinate(x:, y:, x_bounds:, y_bounds:), Coordinate(x:, y:) -> todo
    Coordinate(x:, y:), BoundedCoordinate(x:, y:, x_bounds:, y_bounds:) -> todo
  }
}

// Gets the magnitude between two coordinates.
pub fn magnitude_between(a: Coordinate, b: Coordinate) {
  let mx = int.absolute_value(b.x - a.x)
  let my = int.absolute_value(b.y - a.y)
  #(mx, my)
}
