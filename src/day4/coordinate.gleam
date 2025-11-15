import gleam/int

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

// Creates an arbitrary coordinate given an X and a Y.
pub fn make(x: Int, y: Int) {
  Coordinate(x, y)
}

pub fn subtract(this a: Coordinate, from b: Coordinate) {
  Coordinate(b.x - a.x, b.y - a.y)
}

// Gets the magnitude between two coordinates.
pub fn magnitude_between(a: Coordinate, b: Coordinate) {
  let mx = int.absolute_value(b.x - a.x)
  let my = int.absolute_value(b.y - a.y)
  #(mx, my)
}
