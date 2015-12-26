Tab = require './tab'

class KeyValTab extends Tab
  constructor: (@key, @val, @delim = '=') ->
  depth: () ->
    if @val instanceof Tab
      @val.depth()
    else
      1
  _getKey: () ->
    @key
  _oneLine: (buffer, level) ->
    @_oneLineKey buffer, level
    @_oneLineDelim buffer, level
    @val.oneLine buffer, level
  _oneLineKey: (buffer, level) ->
    buffer.pushOneLine @_getKey()
  _oneLineDelim: (buffer, level) ->
    buffer.pushOneLine @delim
  multiLine: (buffer, level) ->
    @_multiLineKey buffer, level
    @_multiLineDelim buffer, level
    @val.multiLine buffer, level
  _multiLineKey: (buffer, level) ->
    buffer.push @_getKey()
  _multiLineDelim: (buffer, level) ->
    buffer.push @delim

module.exports = KeyValTab

