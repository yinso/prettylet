###
# simple JSON prettifier
###

pretty = require '../src/pretty'

class KeyValTab extends pretty.KeyVal
  constructor: (key, val) ->
    super key, val, ':'
  _getKey: () ->
    JSON.stringify(@key)
  _oneLineDelim: (buffer, level) ->
    buffer.pushOneLine @delim, ' '
  _multiLineDelim: (buffer, level) ->
    buffer.push @delim, ' '

class JsonTab extends pretty.Collection
  @convert: (obj) ->
    if typeof(obj) == 'object'
      if obj == null
        new pretty.Literal obj
      else if obj instanceof Array
        @convertArray obj
      else
        @convertObject obj
    else
      new pretty.Literal obj
  @convertArray: (ary) ->
    items =
      for item in ary
        @convert item
    new @ items, 'array'
  @convertObject: (obj) ->
    keyVals =
      for key, val of obj
        if obj.hasOwnProperty(key)
          @convertKeyVal key, val
    new @ keyVals, 'object'
  @convertKeyVal: (key, val) ->
    new KeyValTab key, @convert(val)
  constructor: (@children, @type) ->
    super @children, ','
  openTag: () ->
    (if @type == 'array' then '[' else '{')
  closeTag: () ->
    (if @type == 'array' then ']' else '}')
  _oneLineOpen: (buffer, level) ->
    buffer.push @openTag()
  _oneLineClose: (buffer, level) ->
    buffer.push ' ', @closeTag()
  multiLine: (buffer, level) ->
    if @depth() < 3
      try
        @oneLine buffer, level
      catch e
        console.error 'JSON.multiLine:error', e
        @_multiLine buffer, level
    else
      @_multiLine buffer, level
  _multiLineOpen: (buffer, level) ->
    buffer.push @openTag()
  _multiLineClose: (buffer, level) ->
    buffer.fixedTab level
    buffer.push @closeTag()

module.exports =
  prettify: (obj) ->
    pretty.prettify obj, JsonTab

console.log module.exports.prettify {
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

