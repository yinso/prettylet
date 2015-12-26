Tab = require './tab'

class LiteralTab extends Tab
  constructor: (@inner, @transform = (v) -> v) ->
    if typeof(@inner) == 'object' and @inner != null
      throw new Error("Literal_cannot_hold_objects: " + @inner)
  oneLine: (buffer, level) ->
    buffer.pushOneLine @convert()
  multiLine: (buffer, level) ->
    buffer.push @convert()
  convert: () ->
    val =
      switch typeof(@inner)
        when 'undefined'
          'undefined'
        else
          if @inner == null
            'null'
          else
            @inner.toString()
    @transform val

module.exports = LiteralTab

