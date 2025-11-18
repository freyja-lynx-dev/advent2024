import day4/bounds.{type Bounds}
import day4/coordinate.{type Coordinate, Coordinate}

/// EdgeCoordinates represent an arbitrary coordinate that exists on the edge of a Grid.
/// Since they have knowledge of their own bounds, they can be arbitrarily incremented
/// forwards and backwards along the perimeter of a grid, without having to do iteration
/// at the point of use. Unless you need the extra info, use Coordinate.
///
/// Since EdgeCoordinates only make sense in the context of Grids, why are they here?
/// I'm not sure. We'll see how I feel when I get to cleaning up this repo after I
/// actually solve day4...
///
/// I'm not super comfortable with EdgeCoordinates having to know their directionality.
/// It may be better to refactor edge coordinates to not have knowledge of their own direction,
/// but instead be provided the direction by the consumer. The consumer knows what they want
/// from the EdgeCoordinate, so they should be able to supply whichever direction
/// they need from the iteration... let's redesign this after we solve day4.
///
/// On the other hand, if edge coordinates don't have a sense of direction, this requires
/// the callers to handle the edge cases where a coordinate is iterated from left->top and
/// right -> bottom. We'd have to supply extra context with the return anyways -- instead
/// of just an EdgeCoordinate, we'd have to supply something like #(EdCo, Direction). Even
/// if we gave a prev() function, you'd still need to move that iteration logic into the consumer
/// end. It would make consumption more flexible, but for day4 purposes it's not really necessary?
/// Idk.
pub type EdgeCoordinate {
  EdgeCoordinate(
    x: Int,
    y: Int,
    edge: Edge,
    bounds: Bounds,
    orientation: Orientation,
  )
}

pub type Edge {
  Top
  Bottom
  Left
  Right
}

pub type Orientation {
  Forwards
  Backwards
}

fn left_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.orientation {
    Forwards ->
      case c.x, c.y, c.bounds {
        // left to bottom transition
        x, y, bounds if y == bounds.y ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: Bottom,
            bounds:,
            orientation: c.orientation,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
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
            orientation: Forwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
          )
      }
  }
}

fn right_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.orientation {
    Forwards ->
      case c.x, c.y, c.bounds {
        // right to bottom transition
        x, y, bounds if y == bounds.y ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: Bottom,
            bounds:,
            orientation: Backwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
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
            orientation: c.orientation,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
          )
      }
  }
}

fn bottom_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.orientation {
    Forwards ->
      case c.x, c.y, c.bounds {
        // bottom to right transition
        x, y, bounds if x == bounds.x ->
          EdgeCoordinate(
            x:,
            y: y - 1,
            edge: Right,
            bounds:,
            orientation: Backwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
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
            orientation: c.orientation,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
          )
      }
  }
}

fn top_increment(c: EdgeCoordinate) -> EdgeCoordinate {
  case c.orientation {
    Forwards ->
      case c.x, c.y, c.bounds {
        // top to right transition
        x, y, bounds if x == bounds.x ->
          EdgeCoordinate(
            x:,
            y: y + 1,
            edge: Right,
            bounds:,
            orientation: Forwards,
          )
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x + 1,
            y:,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
          )
      }
    Backwards ->
      case c.x, c.y, c.bounds {
        // top to left transition
        0, 0, bounds ->
          EdgeCoordinate(x: 0, y: 1, edge: Left, bounds:, orientation: Forwards)
        // general case
        x, y, bounds ->
          EdgeCoordinate(
            x: x - 1,
            y:,
            edge: c.edge,
            bounds:,
            orientation: c.orientation,
          )
      }
  }
}

/// Get the coordinate that comes after the given coordinate, relative to its current
/// direction.
pub fn next(to c: EdgeCoordinate) -> EdgeCoordinate {
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
  orientation d: Orientation,
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

pub fn downcast(c: EdgeCoordinate) -> Coordinate {
  coordinate.make(c.x, c.y)
}
