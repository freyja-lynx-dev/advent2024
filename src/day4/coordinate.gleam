import gleam/int

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

/// Creates an arbitrary coordinate given an X and a Y.
pub fn make(x: Int, y: Int) {
  Coordinate(x, y)
}

/// Subtract two coordinates arbitrarily.
pub fn subtract(this a: Coordinate, from b: Coordinate) -> Coordinate {
  Coordinate(b.x - a.x, b.y - a.y)
}

// Gets the magnitude between two coordinates.
pub fn magnitude_between(a: Coordinate, b: Coordinate) {
  let mx = int.absolute_value(b.x - a.x)
  let my = int.absolute_value(b.y - a.y)
  #(mx, my)
}

pub type Edge {
  Top
  Bottom
  Left
  Right
}

pub type Bounds {
  Bounds(x: Int, y: Int)
}

pub type Direction {
  Forwards
  Backwards
}

pub type EdgeCoordinate {
  EdgeCoordinate(
    x: Int,
    y: Int,
    edge: Edge,
    bounds: Bounds,
    direction: Direction,
  )
}

fn left_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.direction {
    Forwards ->
      case c.x, c.y, c.bounds {
        // left to bottom transition
        x, y, bounds if y == bounds.y ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: Bottom,
            bounds:,
            direction: c.direction,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
    Backwards ->
      case c.x, c.y, c.bounds {
        // left to top transition
        x, 0, bounds ->
          EdgeCoordinate(
            x: x + 1,
            y: 0,
            edge: Top,
            bounds:,
            direction: Forwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
  }
}

fn right_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.direction {
    Forwards ->
      case c.x, c.y, c.bounds {
        // right to bottom transition
        x, y, bounds if y == bounds.y ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: Bottom,
            bounds:,
            direction: Backwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
    Backwards ->
      case c.x, c.y, c.bounds {
        // right to top transition
        x, 0, bounds ->
          EdgeCoordinate(
            x: x - 1,
            y: 0,
            edge: Top,
            bounds:,
            direction: c.direction,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
  }
}

fn bottom_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.direction {
    Forwards ->
      case c.x, c.y, c.bounds {
        // bottom to right transition
        x, y, bounds if x == bounds.x ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: Right,
            bounds:,
            direction: Backwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
    Backwards ->
      case c.x, c.y, c.bounds {
        // bottom to left transition
        0, y, bounds ->
          EdgeCoordinate(
            x: 0,
            y: y - 1,
            edge: Left,
            bounds:,
            direction: c.direction,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
  }
}

fn top_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.direction {
    Forwards ->
      case c.x, c.y, c.bounds {
        // top to right transition
        x, y, bounds if x == bounds.x ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: Right,
            bounds:,
            direction: Forwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
    Backwards ->
      case c.x, c.y, c.bounds {
        // top to left transition
        0, 0, bounds ->
          EdgeCoordinate(x: 0, y: 1, edge: Left, bounds:, direction: Forwards)
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: c.edge,
            bounds:,
            direction: c.direction,
          )
      }
  }
}

pub fn edge_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.edge {
    Left -> left_increment(c)
    Right -> right_increment(c)
    Bottom -> bottom_increment(c)
    Top -> top_increment(c)
  }
}

/// Checks if a given coordinate is on any of the grid's edges
pub fn try_make_edge_coordinate(
  c: Coordinate,
  with b: Bounds,
  direction d: Direction,
) -> Result(EdgeCoordinate, Nil) {
  case c {
    // left edge
    Coordinate(0, y) -> Ok(EdgeCoordinate(0, y, Left, b, d))
    // right edge
    Coordinate(x, y) if x == b.x -> Ok(EdgeCoordinate(x, y, Right, b, d))
    // top edge
    Coordinate(x, 0) -> Ok(EdgeCoordinate(x, 0, Top, b, d))
    // bottom edge
    Coordinate(x, y) if y == b.y -> Ok(EdgeCoordinate(x, y, Bottom, b, d))
    _ -> Error(Nil)
  }
}

pub fn downcast_edge_coordinate(c: EdgeCoordinate) -> Coordinate {
  make(c.x, c.y)
}
