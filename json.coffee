json = require './src/json'

console.log json.prettify {
  foo: 
    bar: 
      baz: 1
  bar: [ 
    1
    2
    {
      a: 1
      b: 2
      c: 3
    }
    3
    []
    4
    {}
  ]
}

