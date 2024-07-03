//// glenv is a library for type-sfe environment variable access.
////

import decode
import envoy
import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/result
import glenv/internal/parse
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

/// EnvError represents an error that can occur when loading the environment.
pub type EnvError {
  MissingKeyError(key: String)
  InvalidEnvValue(key: String, expected: Type)
  ValidationError(errors: List(dynamic.DecodeError))
}

type Resolution =
  #(String, dynamic.Dynamic)

/// Load parses the environment variables and returns a Result containing the environment.
/// Takes a decoder from the gleam/decode library and a list of definitions.
/// 
/// ## Examples
///
/// ```gleam
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
///
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
///
/// env.hello // "world"
/// env.foo // 1.0
/// env.count // 1
/// env.is_on // True
/// ```
pub fn load(
  decoder: decode.Decoder(env),
  definitions: List(Definition),
) -> Result(env, EnvError) {
  use parsed_env <- result.try(parse(definitions))

  case
    parsed_env
    |> dict.from_list
    |> dynamic.from
    |> decode.from(decoder, _)
  {
    Ok(env) -> Ok(env)
    Error(err) -> {
      Error(ValidationError(err))
    }
  }
}

fn parse(definitions: List(Definition)) -> Result(List(Resolution), EnvError) {
  let env = envoy.all()

  list.try_map(definitions, fn(definition) {
    let normalized_definition = #(string.uppercase(definition.0), definition.1)
    case dict.get(env, normalized_definition.0) {
      Ok(value) -> do_parse(normalized_definition, value)
      Error(_) -> Error(MissingKeyError(normalized_definition.0))
    }
  })
}

fn do_parse(
  definition: Definition,
  value: String,
) -> Result(Resolution, EnvError) {
  case definition {
    #(key, Bool) -> {
      case parse.bool(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValue(key, Bool))
      }
    }
    #(key, Float) -> {
      case parse.float(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValue(key, Float))
      }
    }
    #(key, Int) -> {
      case parse.int(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValue(key, Int))
      }
    }
    #(key, String) -> {
      case parse.string(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValue(key, String))
      }
    }
  }
}
