pub fn map_index(l: List(a), f: fn(Int, a) -> b) -> List(b) {
  map_index_loop(l, f, 0)
}

fn map_index_loop(l: List(a), f: fn(Int, a) -> b, index: Int) -> List(b) {
  case l {
    [] -> []
    [head, ..tail] -> [f(index, head), ..map_index_loop(tail, f, index + 1)]
  }
}
