import gleam/dynamic
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub fn bool(
  key: String,
  value: String,
) -> Result(#(String, dynamic.Dynamic), Nil) {
  let resolution =
    ["true", "yes", "1"] |> list.contains(string.lowercase(value))

  Ok(#(key, dynamic.from(resolution)))
}

pub fn float(
  key: String,
  value: String,
) -> Result(#(String, dynamic.Dynamic), Nil) {
  case float.parse(value) {
    Ok(resolution) -> Ok(#(key, dynamic.from(resolution)))
    Error(_) -> Error(Nil)
  }
}

pub fn int(
  key: String,
  value: String,
) -> Result(#(String, dynamic.Dynamic), Nil) {
  case int.parse(value) {
    Ok(resolution) -> Ok(#(key, dynamic.from(resolution)))
    Error(_) -> Error(Nil)
  }
}

pub fn string(
  key: String,
  value: String,
) -> Result(#(String, dynamic.Dynamic), Nil) {
  Ok(#(key, dynamic.from(value)))
}
