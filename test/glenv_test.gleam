import envoy
import gleam/bool
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/string
import gleeunit
import gleeunit/should
import glenv

pub fn main() {
  gleeunit.main()
}

const hello_key = "HELLO"

const foo_key = "FOO"

const count_key = "COUNT"

const is_on_key = "IS_ON"

pub type TestEnv {
  TestEnv(hello: String, count: Int, foo: Float, is_on: Bool)
}

fn test_env_decoder() -> decode.Decoder(TestEnv) {
  use hello <- decode.field(hello_key, decode.string)
  use count <- decode.field(count_key, decode.int)
  use foo <- decode.field(foo_key, decode.float)
  use is_on <- decode.field(is_on_key, decode.bool)
  decode.success(TestEnv(hello:, count:, foo:, is_on:))
}

pub fn load_test() {
  let hello = "world"
  let foo = 1.0
  let count = 1
  let is_on = True

  envoy.set(hello_key, hello)
  envoy.set(foo_key, float.to_string(foo))
  envoy.set(count_key, int.to_string(count))
  envoy.set(is_on_key, bool.to_string(is_on))

  let definitions = [
    #(hello_key, glenv.String),
    #(foo_key, glenv.Float),
    #(count_key, glenv.Int),
    #(is_on_key, glenv.Bool),
  ]

  let result = glenv.load(test_env_decoder(), definitions)

  result
  |> should.equal(
    Ok(TestEnv(hello: hello, foo: foo, count: count, is_on: is_on)),
  )

  envoy.unset(hello_key)
  envoy.unset(foo_key)
  envoy.unset(count_key)
  envoy.unset(is_on_key)
}

pub fn load_incorrect_casing_test() {
  let hello = "world"
  let foo = 1.0
  let count = 1
  let is_on = True

  envoy.set(hello_key, hello)
  envoy.set(foo_key, float.to_string(foo))
  envoy.set(count_key, int.to_string(count))
  envoy.set(is_on_key, bool.to_string(is_on))

  let definitions = [
    // NOTE: we are lowercasing the key here to simulate failure
    #(string.lowercase(hello_key), glenv.String),
    #(foo_key, glenv.Float),
    #(count_key, glenv.Int),
    #(is_on_key, glenv.Bool),
  ]

  let result = glenv.load(test_env_decoder(), definitions)

  result
  |> should.equal(
    Ok(TestEnv(hello: hello, foo: foo, count: count, is_on: is_on)),
  )

  envoy.unset(hello_key)
  envoy.unset(foo_key)
  envoy.unset(count_key)
  envoy.unset(is_on_key)
}

pub fn load_missing_variable_test() {
  let foo = 1.0
  let count = 1
  let is_on = True

  // HELLO is not set
  envoy.set(foo_key, float.to_string(foo))
  envoy.set(count_key, int.to_string(count))
  envoy.set(is_on_key, bool.to_string(is_on))

  let definitions = [
    // NOTE: we are lowercasing the key here to simulate failure
    #(string.lowercase(hello_key), glenv.String),
    #(foo_key, glenv.Float),
    #(count_key, glenv.Int),
    #(is_on_key, glenv.Bool),
  ]

  let result = glenv.load(test_env_decoder(), definitions)

  result
  |> should.be_error
  |> should.equal(glenv.MissingKeyError("HELLO"))

  envoy.unset(foo_key)
  envoy.unset(count_key)
  envoy.unset(is_on_key)
}
