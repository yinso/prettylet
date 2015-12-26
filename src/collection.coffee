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
    @_oneLineChildren buffer, level
    @_oneLineClose buffer, level
  #_oneLineOpen: (buffer, level) ->
  _oneLineChildren: (buffer, level) ->
    for child, i in @children
      @_oneLineChildTab buffer, level + 1, i
      child.oneLine buffer, level + 1
      @_oneLineDelim buffer, level + 1, i
  _oneLineChildTab: (buffer, level, i) ->
    buffer.push ' '
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
      @_multiLineChildTab buffer, level + 1, i
      child.multiLine buffer, level + 1
      @_multiLineDelim buffer, level + 1, i
  _multiLineChildTab: (buffer, level, i) ->
    buffer.fixedTab level + 1
  _multiLineDelim: (buffer, level, i) ->
    if i < @children.length - 1
      buffer.push @delim
  #_multiLineClose: (buffer, level) ->

###
class CollectionTab extends Tab
  constructor: (@children = []) ->
  depth: () ->
    depths =
      for child in @children
        if child instanceof Tab
          child.depth()
        else
          1
    1 + Math.max.apply(Math, depths)
  addChild: (child) ->
    if typeof(child) == 'string'
      @children.push child
    else if child instanceof Tab
      @children.push child
    else
      throw new Error("invalid_tab_object: #{child}")
  oneLine: (buffer, level) ->
    if @children.length == 0
      @oneLineNoChildren buffer, level
    else
      @oneLineChildren buffer, level
  oneLineChildren: (buffer, level) ->
    for child in @children
      if child instanceof Tab
        child.oneLine buffer, level + 1
      else
        buffer.pushOneLine child
  oneLineNoChildren: (buffer, level) ->
  multiLine: (buffer, level) -> # the multi-level thing needs to be rethought.
    @multiLineChildren buffer, level
  multiLineChildren: (buffer, level) ->
    for child in @children
      if child instanceof Tab
        child.multiLine buffer, level + 1
      else
        buffer.fixedTab(level + 1)
        buffer.push child
    buffer
###
module.exports = CollectionTab

