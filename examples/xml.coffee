pretty = require '../src/pretty'

class KeyValTab extends pretty.KeyVal
  constructor: (@key, val, @delim = '=') ->
    val = new pretty.Literal val, (v) -> JSON.stringify(v)
    super @key, val, @delim

class AttrListTab extends pretty.Collection
  constructor: (attrs) ->
    children =
      for key, val of attrs or {}
        new KeyValTab key, val, '='
    super children, ''
  _oneLineOpen: (buffer, level) ->
  _oneLineClose: (buffer, level) ->
  _multiLineOpen: (buffer, level) ->
  _multiLineClose: (buffer, level) ->
  _multiLineChildTab: (buffer, level, i) ->
    if i == 0
      buffer.push ' '
    else
      buffer.wordedTab level

class ElementTab extends pretty.Collection
  @convert: (obj) ->
    if typeof(obj) == 'string'
      new pretty.Literal(obj)
    else
      children =
        for child in obj.children or []
          @convert child
      new @ obj.tag, (obj.attrs or obj.attributes or {}), children
  constructor: (@tag, attrs = {}, @children = []) ->
    super @children, ''
    @attrs = new AttrListTab attrs
  _oneLineOpen: (buffer, level) ->    
    buffer.pushOneLine "<#{@tag}"
    @attrs.oneLine buffer, level
    if @children.length > 0
      buffer.pushOneLine ">"
  _oneLineChildTab: (buffer, level) ->
  _oneLineClose: (buffer, level) ->
    if @children.length > 0
      buffer.pushOneLine "</#{@tag}>"
    else
      buffer.pushOneLine " />"
  _multiLineOpen: (buffer, level) ->
    if @attrs.length == 0
      buffer.push "<#{@tag}>"
    else
      buffer.push "<#{@tag}"
      @attrs.multiLine buffer, level + 1
      buffer.push ">"
  _multiLineClose: (buffer, level) ->
    buffer.fixedTab level
    buffer.push "</#{@tag}>"
  
module.exports =
  prettify: (obj) ->
    pretty.prettify obj, ElementTab
  KeyVal: KeyValTab
  Element: ElementTab


console.log module.exports.prettify {
  tag: 'html'
  attrs: {
    test: 1
    class: 'test me out'
  }
  children: [
    {
      tag: 'body'
      attrs: {
        test: 1
        class: 'test me out'
        test2: 1
        class2: 'test me out'
        test3: 1
        class3: 'test me out'
        test4: 1
        class4: 'test me out'
        test5: 1
        class5: 'test me out'
        test6: 1
        class6: 'test me out'
      }
      children: [
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {
            class: 'foo bar'
            align: 'center'
          }
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'br'
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
            { tag: 'br' }
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
      ]
    }
  ]
}

