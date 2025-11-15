import day4/coordinate.{
  Backwards, Bottom, Bounds, Coordinate, EdgeCoordinate, Forwards, Left, Right,
  Top,
}

pub fn subtract_test() {
  let a = Coordinate(9, 9)
  let b = Coordinate(1, 1)
  let c = Coordinate(-2, 2)

  // positive result test
  assert Coordinate(8, 8) == coordinate.subtract(this: b, from: a)

  // negative result test
  assert Coordinate(-8, -8) == coordinate.subtract(this: a, from: b)

  // mixed test
  assert Coordinate(3, -1) == coordinate.subtract(this: c, from: b)
}

pub fn magnitude_test() {
  let a = Coordinate(1, 1)
  let b = Coordinate(2, 2)
  let c = Coordinate(-1, -1)
  let d = Coordinate(3, -3)

  // magnitude should be identical no matter orientation
  assert #(1, 1) == coordinate.magnitude_between(a, b)
  assert #(1, 1) == coordinate.magnitude_between(b, a)

  assert #(2, 2) == coordinate.magnitude_between(a, c)
  assert #(2, 2) == coordinate.magnitude_between(c, a)

  assert #(4, 2) == coordinate.magnitude_between(c, d)
  assert #(4, 2) == coordinate.magnitude_between(d, c)
}

pub fn edge_increment_test() {
  let bounds = Bounds(2, 2)

  // normal forwards top increment
  let c = EdgeCoordinate(x: 1, y: 0, edge: Top, bounds:, direction: Forwards)
  assert Coordinate(2, 0)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal forwards bottom increment
  let c = EdgeCoordinate(x: 0, y: 2, edge: Bottom, bounds:, direction: Forwards)
  assert Coordinate(1, 2)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal forwards left increment
  let c = EdgeCoordinate(x: 0, y: 1, edge: Left, bounds:, direction: Forwards)
  assert Coordinate(0, 2)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal forwards right increment
  let c = EdgeCoordinate(x: 2, y: 0, edge: Right, bounds:, direction: Forwards)
  assert Coordinate(2, 1)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal backwards top increment
  let c = EdgeCoordinate(x: 1, y: 0, edge: Top, bounds:, direction: Backwards)
  assert Coordinate(0, 0)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal backwards bottom increment
  let c =
    EdgeCoordinate(x: 1, y: 2, edge: Bottom, bounds:, direction: Backwards)
  assert Coordinate(0, 2)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal backwards left increment
  let c = EdgeCoordinate(x: 0, y: 1, edge: Left, bounds:, direction: Backwards)
  assert Coordinate(0, 0)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // normal backwards right increment
  let c = EdgeCoordinate(x: 2, y: 1, edge: Right, bounds:, direction: Backwards)
  assert Coordinate(2, 0)
    == coordinate.downcast_edge_coordinate(coordinate.edge_increment(c))

  // top to right transition
  let c = EdgeCoordinate(x: 2, y: 0, edge: Top, bounds:, direction: Forwards)
  assert EdgeCoordinate(2, 1, Right, bounds, Forwards)
    == coordinate.edge_increment(c)

  // top to left transition
  let c = EdgeCoordinate(x: 0, y: 0, edge: Top, bounds:, direction: Backwards)
  assert EdgeCoordinate(0, 1, Left, bounds, Forwards)
    == coordinate.edge_increment(c)

  // bottom to right transition
  let c = EdgeCoordinate(x: 2, y: 2, edge: Bottom, bounds:, direction: Forwards)
  assert EdgeCoordinate(2, 1, Right, bounds, Backwards)
    == coordinate.edge_increment(c)

  // bottom to left transition
  let c =
    EdgeCoordinate(x: 0, y: 2, edge: Bottom, bounds:, direction: Backwards)
  assert EdgeCoordinate(0, 1, Left, bounds, Backwards)
    == coordinate.edge_increment(c)

  // left to bottom transition
  let c = EdgeCoordinate(x: 0, y: 2, edge: Left, bounds:, direction: Forwards)
  assert EdgeCoordinate(1, 2, Bottom, bounds, Forwards)
    == coordinate.edge_increment(c)

  // left to top transition
  let c = EdgeCoordinate(x: 0, y: 0, edge: Left, bounds:, direction: Backwards)
  assert EdgeCoordinate(1, 0, Top, bounds, Forwards)
    == coordinate.edge_increment(c)

  // right to bottom transition
  let c = EdgeCoordinate(x: 2, y: 2, edge: Right, bounds:, direction: Forwards)
  assert EdgeCoordinate(1, 2, Bottom, bounds, Backwards)
    == coordinate.edge_increment(c)

  // right to top transition
  let c = EdgeCoordinate(x: 2, y: 0, edge: Right, bounds:, direction: Backwards)
  assert EdgeCoordinate(1, 0, Top, bounds, Backwards)
    == coordinate.edge_increment(c)
}
