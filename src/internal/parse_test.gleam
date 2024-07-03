import gleam/dynamic
import gleeunit
import gleeunit/should
import internal/parse

pub fn main() {
  gleeunit.main()
}

const key = "GLENV_TEST_VAR"

pub fn parse_bool_test() {
  parse.bool(key, "yes")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "YES")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "yEs")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "true")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "TRUE")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "trUE")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "1")
  |> should.equal(Ok(#(key, dynamic.from(True))))

  parse.bool(key, "no")
  |> should.equal(Ok(#(key, dynamic.from(False))))

  parse.bool(key, "false")
  |> should.equal(Ok(#(key, dynamic.from(False))))

  parse.bool(key, "0")
  |> should.equal(Ok(#(key, dynamic.from(False))))

  parse.bool(key, "anythingelse")
  |> should.equal(Ok(#(key, dynamic.from(False))))
}

pub fn parse_float_test() {
  parse.float(key, "1.0")
  |> should.equal(Ok(#(key, dynamic.from(1.0))))

  parse.float(key, "1.0001")
  |> should.equal(Ok(#(key, dynamic.from(1.0001))))

  parse.float(key, "1.000")
  |> should.equal(Ok(#(key, dynamic.from(1.0))))

  parse.float(key, "1")
  |> should.be_error

  parse.float(key, "abc")
  |> should.be_error
}

pub fn parse_int_test() {
  parse.int(key, "1")
  |> should.equal(Ok(#(key, dynamic.from(1))))

  parse.int(key, "2000000")
  |> should.equal(Ok(#(key, dynamic.from(2_000_000))))

  parse.int(key, "1.0")
  |> should.be_error

  parse.int(key, "abc")
  |> should.be_error

  parse.int(key, "2_000")
  |> should.be_error
}

pub fn parse_string_test() {
  parse.string(key, "1")
  |> should.equal(Ok(#(key, dynamic.from("1"))))

  parse.string(key, "2000000")
  |> should.equal(Ok(#(key, dynamic.from("2000000"))))

  parse.string(key, "1.0")
  |> should.equal(Ok(#(key, dynamic.from("1.0"))))

  parse.string(key, "abc")
  |> should.equal(Ok(#(key, dynamic.from("abc"))))

  parse.string(key, "2_000")
  |> should.equal(Ok(#(key, dynamic.from("2_000"))))
}
