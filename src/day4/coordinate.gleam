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

// Add two coordinates arbitrarily
pub fn add(this a: Coordinate, to b: Coordinate) -> Coordinate {
  Coordinate(b.x + a.x, b.y + a.y)
}

// Convert a plain tuple of ints into a Coordinate
pub fn upcast(from t: #(Int, Int)) -> Coordinate {
  let #(x, y) = t
  Coordinate(x:, y:)
}

pub fn swap(c: Coordinate) -> Coordinate {
  Coordinate(x: c.y, y: c.x)
}

// Gets the magnitude between two coordinates.
pub fn magnitude_between(a: Coordinate, b: Coordinate) {
  let mx = int.absolute_value(b.x - a.x)
  let my = int.absolute_value(b.y - a.y)
  #(mx, my)
}
