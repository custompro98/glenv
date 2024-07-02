import decode
import envoy
import gleam/bool
import gleam/float
import gleam/int
import gleam/string
import gleeunit
import gleeunit/should
import glenv

pub fn main() {
  gleeunit.main()
}

const key = "GLENV_TEST_VAR"

const hello_key = "HELLO"

const foo_key = "FOO"

const count_key = "COUNT"

const is_on_key = "IS_ON"

pub fn parse_bool_test() {
  envoy.set(key, "yes")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "YES")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "yEs")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "true")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "TRUE")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "trUE")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "1")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(True))]))

  envoy.set(key, "no")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(False))]))

  envoy.set(key, "false")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(False))]))

  envoy.set(key, "0")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(False))]))

  envoy.set(key, "anythingelse")
  glenv.parse([#(key, glenv.Bool)])
  |> should.equal(Ok([#(key, glenv.RBool(False))]))

  envoy.unset(key)
}

pub fn parse_float_test() {
  envoy.set(key, "1.0")
  glenv.parse([#(key, glenv.Float)])
  |> should.equal(Ok([#(key, glenv.RFloat(1.0))]))

  envoy.set(key, "1.0001")
  glenv.parse([#(key, glenv.Float)])
  |> should.equal(Ok([#(key, glenv.RFloat(1.0001))]))

  envoy.set(key, "1.000")
  glenv.parse([#(key, glenv.Float)])
  |> should.equal(Ok([#(key, glenv.RFloat(1.0))]))

  envoy.set(key, "1")
  glenv.parse([#(key, glenv.Float)])
  |> should.be_error

  envoy.set(key, "abc")
  glenv.parse([#(key, glenv.Float)])
  |> should.be_error

  envoy.unset(key)
}

pub fn parse_int_test() {
  envoy.set(key, "1")
  glenv.parse([#(key, glenv.Int)])
  |> should.equal(Ok([#(key, glenv.RInt(1))]))

  envoy.set(key, "2000000")
  glenv.parse([#(key, glenv.Int)])
  |> should.equal(Ok([#(key, glenv.RInt(2_000_000))]))

  envoy.set(key, "1.0")
  glenv.parse([#(key, glenv.Int)])
  |> should.be_error

  envoy.set(key, "abc")
  glenv.parse([#(key, glenv.Int)])
  |> should.be_error

  envoy.set(key, "2_000")
  glenv.parse([#(key, glenv.Int)])
  |> should.be_error

  envoy.unset(key)
}

pub fn parse_string_test() {
  envoy.set(key, "1")
  glenv.parse([#(key, glenv.String)])
  |> should.equal(Ok([#(key, glenv.RString("1"))]))

  envoy.set(key, "2000000")
  glenv.parse([#(key, glenv.String)])
  |> should.equal(Ok([#(key, glenv.RString("2000000"))]))

  envoy.set(key, "1.0")
  glenv.parse([#(key, glenv.String)])
  |> should.equal(Ok([#(key, glenv.RString("1.0"))]))

  envoy.set(key, "abc")
  glenv.parse([#(key, glenv.String)])
  |> should.equal(Ok([#(key, glenv.RString("abc"))]))

  envoy.set(key, "2_000")
  glenv.parse([#(key, glenv.String)])
  |> should.equal(Ok([#(key, glenv.RString("2_000"))]))

  envoy.unset(key)
}

pub type TestEnv {
  TestEnv(hello: String, count: Int, foo: Float, is_on: Bool)
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
  let decoder =
    decode.into({
      use hello <- decode.parameter
      use foo <- decode.parameter
      use count <- decode.parameter
      use is_on <- decode.parameter

      TestEnv(hello: hello, foo: foo, count: count, is_on: is_on)
    })
    |> decode.field(hello_key, decode.string)
    |> decode.field(foo_key, decode.float)
    |> decode.field(count_key, decode.int)
    |> decode.field(is_on_key, decode.bool)

  let result = glenv.load(decoder, definitions)

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
  let decoder =
    decode.into({
      use hello <- decode.parameter
      use foo <- decode.parameter
      use count <- decode.parameter
      use is_on <- decode.parameter

      TestEnv(hello: hello, foo: foo, count: count, is_on: is_on)
    })
    |> decode.field(hello_key, decode.string)
    |> decode.field(foo_key, decode.float)
    |> decode.field(count_key, decode.int)
    |> decode.field(is_on_key, decode.bool)

  let result = glenv.load(decoder, definitions)

  result
  |> should.equal(
    Ok(TestEnv(hello: hello, foo: foo, count: count, is_on: is_on)),
  )

  envoy.unset(hello_key)
  envoy.unset(foo_key)
  envoy.unset(count_key)
  envoy.unset(is_on_key)
}
