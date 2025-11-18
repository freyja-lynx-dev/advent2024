pub type Direction {
  Horizontal
  Vertical
  DiagonalRising
  DiagonalFalling
}

pub fn slope(for d: Direction) -> #(Int, Int) {
  case d {
    Horizontal -> #(1, 0)
    Vertical -> #(0, 1)
    // falling and rising are reversed as our grid perspective is
    // top to bottom... this is a bit confusing, but i'm not gonna change it
    DiagonalFalling -> #(1, 1)
    DiagonalRising -> #(1, -1)
  }
}
