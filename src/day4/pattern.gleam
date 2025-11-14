import gleam/string

pub type Pattern {
  Pattern(forwards: String, backwards: String)
}

pub fn make(p: String) -> Pattern {
  Pattern(p, string.reverse(p))
}
