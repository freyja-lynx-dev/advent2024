import day4/coordinate.{Coordinate}

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
