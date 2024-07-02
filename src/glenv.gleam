//// glenv is a library for type-sfe environment variable access.
//// It is inspried by a Typescript pattern using zod validators
//// to parse and validate environment variables.

import decode
import envoy
import gleam/dict
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string

/// Type represents the type of an environment variable.
/// This dictates how the environment variable is parsed.
pub type Type {
  Bool
  Float
  Int
  String
}

/// Definition represents a single environment variable, from key to type.
pub type Definition =
  #(String, Type)

type ResolvedType =
  dynamic.Dynamic

type Resolution =
  #(String, ResolvedType)

/// Load parses the environment variables and returns a Result containing the environment.
/// Takes a decoder from the gleam/decode library and a list of definitions.
/// 
/// ## Examples
///
/// ```gleam`
/// type Env {
///   Env(hello: String, foo: Float, count: Int, is_on: Bool)
/// }
///
/// let definitions = [
///   #("HELLO", glenv.String),
///   #("FOO", glenv.Float),
///   #("COUNT", glenv.Int),
///   #("IS_ON", glenv.Bool),
/// ]
/// let decoder =
///   decode.into({
///     use hello <- decode.parameter
///     use foo <- decode.parameter
///     use count <- decode.parameter
///     use is_on <- decode.parameter
///
///     Env(hello: hello, foo: foo, count: count, is_on: is_on)
///   })
///   |> decode.field("HELLO", decode.string)
///   |> decode.field("FOO", decode.float)
///   |> decode.field("COUNT", decode.int)
///   |> decode.field("IS_ON", decode.bool)
///
/// let assert Ok(env) = glenv.load(decoder, definitions)
/// env.hello // "world"
/// env.foo // 1.0
/// env.count // 1
/// env.is_on // True
/// ````
pub fn load(
  decoder: decode.Decoder(env),
  definitions: List(Definition),
) -> Result(env, Nil) {
  let assert Ok(parsed_env) = parse(definitions)

  case
    parsed_env
    |> dict.from_list
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

  Ok(#(definition.0, dynamic.from(resolution)))
}

fn parse_float(definition: Definition, value: String) -> Result(Resolution, Nil) {
  case float.parse(value) {
    Ok(resolution) -> Ok(#(definition.0, dynamic.from(resolution)))
    Error(_) -> Error(Nil)
  }
}

fn parse_int(definition: Definition, value: String) -> Result(Resolution, Nil) {
  case int.parse(value) {
    Ok(resolution) -> Ok(#(definition.0, dynamic.from(resolution)))
    Error(_) -> Error(Nil)
  }
}

fn parse_string(
  definition: Definition,
  value: String,
) -> Result(Resolution, Nil) {
  Ok(#(definition.0, dynamic.from(value)))
}
