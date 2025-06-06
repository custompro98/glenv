//// glenv is a library for type-sfe environment variable access.
////

import envoy
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result
import gleam/string
import glenv/internal/parse

/// Type represents the type of an environment variable.
/// This dictates how the environment variable is parsed.
pub type Type {
  /// Boolean type, represented by any casing of "true", "yes", or "1".
  Bool
  /// Float type, represented by values like "1.0" or "1.000".
  Float
  /// Integer type, represented by values like "1" or "100".
  Int
  /// String type, represented by any value.
  String
}

/// Definition represents a single environment variable, from key to type.
pub type Definition =
  #(String, Type)

/// EnvError represents an error that can occur when loading the environment.
pub type EnvError {
  /// The key was not found in the environment.
  MissingKeyError(key: String)
  /// The key was found in the environment but the value was not of the expected type.
  InvalidEnvValueError(key: String, expected: Type)
  /// The key was found in the environment of the correct type, but the provided definition did not match.
  DefinitionMismatchError(errors: List(decode.DecodeError))
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
    |> decode.run(decoder)
  {
    Ok(env) -> Ok(env)
    Error(err) -> {
      Error(DefinitionMismatchError(err))
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
        Error(_) -> Error(InvalidEnvValueError(key, Bool))
      }
    }
    #(key, Float) -> {
      case parse.float(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValueError(key, Float))
      }
    }
    #(key, Int) -> {
      case parse.int(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValueError(key, Int))
      }
    }
    #(key, String) -> {
      case parse.string(key, value) {
        Ok(resolution) -> Ok(resolution)
        Error(_) -> Error(InvalidEnvValueError(key, String))
      }
    }
  }
}
