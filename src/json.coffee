###
# simple JSON prettifier
###

pretty = require './pretty'

class KeyValTab extends pretty.KeyVal
  constructor: (key, val) ->
    super key, val, ':'
  _getKey: () ->
    JSON.stringify(@key)
  _oneLineDelim: (buffer, level) ->
    buffer.pushOneLine @delim, ' '
  _multiLineDelim: (buffer, level) ->
    buffer.push @delim, ' '

###
class KeyValTab extends pretty.Tab
  constructor: (@key, @val, @delim = ':') ->
  depth: () ->
    if @val instanceof pretty.Tab
      @val.depth()
    else
      1
  _oneLine: (buffer, level) ->
    buffer.pushOneLine @key, @delim, ' '
    if typeof(@val) == 'string'
      buffer.pushOneLine JSON.stringify(@val)
    else
      @val.oneLine buffer, level
  multiLine: (buffer, level) ->
    buffer.push JSON.stringify(@key), @delim, ' '
    @val.multiLine buffer, level
###

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

#
###
class Prettify
  constructor: () ->
    if not (this instanceof Prettify)
      return new Prettify()
  pretty: (obj, level = 0) ->
    switch typeof(obj)
      when 'undefined'
        [ pretty.tabLevel(level), 'undefined' ]
      when 'boolean'
        [ pretty.tabLevel(level), if obj then 'true' else 'false' ]
      when 'number'
        [ pretty.tabLevel(level), obj.toString() ]
      when 'string'
        [ pretty.tabLevel(level), JSON.stringify(obj) ]
      else
        if obj == null
          [ 'null' ]
        else if obj instanceof Array
          @array obj, level
        else
          @object obj, level
  object: (obj, level) ->
    keys = Object.keys(obj)
    itemList = 
      for key, i in keys
        [
          @keyVal(key, obj[key], level + 1)
          if i < keys.length - 1
            ','
          else
            ''
        ]
    pretty.coll level, '{', itemList, '}'
  keyVal: (key, val, level) ->
    pretty.keyval level, key, @pretty(val, level)
  array: (ary, level) ->
    itemList =
      for item, i in ary
        [
          @pretty(item, level + 1)
          if i < ary.length - 1
            ','
          else
            ''
        ]
    pretty.coll level, '[', itemList, ']'

algo = Prettify()

_prettify = (obj) ->
  algo.pretty(obj)

prettify = (obj) ->
  pretty.prettify obj, _prettify

module.exports =
  prettify: prettify

####

