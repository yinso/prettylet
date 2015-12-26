Tab = require './tab'

class CollectionTab extends Tab
  constructor: (@children, @delim) ->
  depth: () ->
    depths =
      for child in @children
        if child instanceof Tab
          child.depth()
        else
          1
    1 + Math.max.apply(Math, depths)
  _oneLine: (buffer, level) ->
    @_oneLineOpen buffer, level
    @_oneLineChildren buffer, level + 1
    @_oneLineClose buffer, level
  #_oneLineOpen: (buffer, level) ->
  _oneLineChildren: (buffer, level) ->
    for child, i in @children
      @_oneLineChild buffer, level + 1, child, i
  _oneLineChild: (buffer, level, child, i) ->
    @_oneLineChildTab buffer, level, i
    child.oneLine buffer, level
    @_oneLineDelim buffer, level, i
  _oneLineChildTab: (buffer, level, i) ->
    buffer.pushOneLine ' '
  _oneLineDelim: (buffer, level, i) ->
    if i < @children.length - 1
      buffer.pushOneLine @delim
  #_oneLineClose: (buffer, level) ->
  _multiLine: (buffer, level) ->
    @_multiLineOpen(buffer, level)
    @_multiLineChildren(buffer, level)
    @_multiLineClose(buffer, level)
  #_multiLineOpen: (buffer, level) ->
  _multiLineChildren: (buffer, level) ->
    for child, i in @children
      @_multiLineChild buffer, level + 1, child, i
  _multiLineChild: (buffer, level, child, i) ->
    @_multiLineChildTab buffer, level, i
    child.multiLine buffer, level
    @_multiLineDelim buffer, level, i
  _multiLineChildTab: (buffer, level, i) ->
    buffer.fixedTab level
  _multiLineDelim: (buffer, level, i) ->
    if i < @children.length - 1
      buffer.push @delim
  #_multiLineClose: (buffer, level) ->

module.exports = CollectionTab

