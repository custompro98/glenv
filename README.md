# glenv

[![Package Version](https://img.shields.io/hexpm/v/glenv)](https://hex.pm/packages/glenv)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glenv/)

Type-safe environment variables for Gleam.

Accessing environment variables doesn't give us the type of safety guarantees we'd like in a langauge like Gleam. glenv aims to guarantee that each environment variable is of the correct type AND is present.

```sh
gleam add glenv
```
```gleam
import gleam/decode
import glenv

pub type MyEnv {
  MyEnv(hello: String, foo: Float, count: Int, is_on: Bool)
}

pub fn main() {
  let definitions = [
    #("HELLO", glenv.String),
    #("FOO", glenv.Float),
    #("COUNT", glenv.Int),
    #("IS_ON", glenv.Bool),
  ]

  let decoder =
    decode.into({
      use hello <- decode.parameter
      use foo <- decode.parameter
      use count <- decode.parameter
      use is_on <- decode.parameter

      MyEnv(hello: hello, foo: foo, count: count, is_on: is_on)
    })
    |> decode.field("HELLO", decode.string)
    |> decode.field("FOO", decode.float)
    |> decode.field("COUNT", decode.int)
    |> decode.field("IS_ON", decode.bool)

  let assert Ok(env) = glenv.load(decoder, definitions)

  env.hello == "hello"
  env.foo == 1.0
  env.count == 1
  env.is_on == True
}
```

Further documentation can be found at <https://hexdocs.pm/glenv>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
