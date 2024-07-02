import decode
import envoy
import gleam/dict
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Type {
  Bool
  Float
  Int
  String
}

pub type ResolvedType {
  RBool(value: Bool)
  RFloat(value: Float)
  RInt(value: Int)
  RString(value: String)
}

pub type Definition =
  #(String, Type)

pub type Resolution =
  #(String, ResolvedType)

// Given a dict from the environment
// - dot_env.load in the main app
// - envoy.all() (internally?) loads the environment into a dict
// Accept a tuple of #(KEY, <Type>) 
// Return (something) that represents everything
// - Can I use a dynamic here?
// - Maybe I don't return anything, but instead access
//    comes from this package?

pub fn load(
  decoder: decode.Decoder(env),
  definitions: List(Definition),
) -> Result(env, Nil) {
  let assert Ok(parsed_env) = parse(definitions)

  case
    parsed_env
    |> list_to_dict
    |> dynamic.from
    |> decode.from(decoder, _)
  {
    Ok(env) -> Ok(env)
    Error(err) -> {
      io.debug(err)
      Error(Nil)
    }
  }
}

pub fn parse(definitions: List(Definition)) -> Result(List(Resolution), Nil) {
  let env = envoy.all()

  list.try_map(definitions, fn(definition) {
    let normalized_definition = #(string.uppercase(definition.0), definition.1)
    case dict.get(env, normalized_definition.0) {
      Ok(value) -> do_parse(normalized_definition, value)
      Error(_) -> Error(Nil)
    }
  })
}

fn do_parse(definition: Definition, value: String) -> Result(Resolution, Nil) {
  case definition {
    #(_, Bool) -> parse_bool(definition, value)
    #(_, Float) -> parse_float(definition, value)
    #(_, Int) -> parse_int(definition, value)
    #(_, String) -> parse_string(definition, value)
  }
}

fn parse_bool(definition: Definition, value: String) -> Result(Resolution, Nil) {
  let resolution =
    ["true", "yes", "1"] |> list.contains(string.lowercase(value))

  Ok(#(definition.0, RBool(resolution)))
}

fn parse_float(definition: Definition, value: String) -> Result(Resolution, Nil) {
  case float.parse(value) {
    Ok(resolution) -> Ok(#(definition.0, RFloat(resolution)))
    Error(_) -> Error(Nil)
  }
}

fn parse_int(definition: Definition, value: String) -> Result(Resolution, Nil) {
  case int.parse(value) {
    Ok(resolution) -> Ok(#(definition.0, RInt(resolution)))
    Error(_) -> Error(Nil)
  }
}

fn parse_string(
  definition: Definition,
  value: String,
) -> Result(Resolution, Nil) {
  Ok(#(definition.0, RString(value)))
}

fn list_to_dict(in: List(Resolution)) {
  in
  |> list.map(fn(tup) {
    #(tup.0, case tup.1 {
      RBool(value) -> dynamic.from(value)
      RFloat(value) -> dynamic.from(value)
      RInt(value) -> dynamic.from(value)
      RString(value) -> dynamic.from(value)
    })
  })
  |> dict.from_list
}
