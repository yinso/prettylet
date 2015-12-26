# pretty print a sub-set of javascript as an example.

Pretty = require '../src/pretty'

class ExpressionTab extends Pretty.Tab
  @types: {}
  @register: (converter) ->
    if @types.hasOwnProperty(converter.name)
      throw new Error("ExpressionTab.duplicate: " + converter.name)
    else
      @types[converter.name] = converter
  @typeMaps: {
    Identifier: 'Symbol'
    CallExpression: 'Funcall'
    BinaryExpression: 'Binary'
    Literal: 'Literal'
    IfExpression: 'If'
    BlockExpression: 'Block'
    AssignmentExpression: 'Assign'
  }
  @mapType: (key) ->
    @typeMaps[key]
  @get: (type) ->
    if @types.hasOwnProperty(type)
      @types[type]
    else
      throw new Error("ExpressionTab.unknownType: " + type)
  @convert: (obj) ->
    if typeof(obj) == 'object'
      if obj == null
        new Pretty.Literal(obj)
      else
        converter = @get @mapType(obj.__type or obj.type)
        converter.convert obj
    else
      new Pretty.Literal(obj)
  precedence: () -> 1
  @preceLevel: {
    ',': 0
    '...': 1
    'yield': 2
    '|=': 3
    '^=': 3
    '&=': 3
    '>>>=': 3
    '>>=': 3
    '<<=': 3
    '%=': 3
    '/=': 3
    '*=': 3
    '**=': 3
    '-=': 3
    '+=': 3
    '=': 3
    '?': 4
    '||': 5
    '&&': 6
    '|': 7
    '^': 8
    '&': 9
    '!==': 10
    '===': 10
    '!=': 10
    '==': 10
    'instanceof': 11
    'in': 11
    '>=': 11
    '>': 11
    '<=': 11
    '<': 11
    '>>>': 12
    '>>': 12
    '<<': 12
    '-': 13
    '+': 13
    '%': 14
    '/': 14
    '*': 14
    '**': 14
    'delete': 15
    'void': 15
    'typeof': 15
    '--': 15
    '++': 15
    '~': 15
    '!': 15
    'new': 17
    '(': 17
  }
ExpressionTab.register class Literal extends Pretty.Literal
  @convert: (obj) ->
    new @ obj.value
  precedence: () -> Infinity

ExpressionTab.register class Symbol extends ExpressionTab
  @convert: (obj) ->
    if obj.name == 'undefined'
      new Pretty.Literal 'undefined'
    else
      new @ obj.name
  constructor: (@name) ->
  oneLine: (buffer, level) ->
    buffer.pushOneLine @name
  multiLine: (buffer, level) ->
    buffer.push @name
  precedence: () -> Infinity

ExpressionTab.register class Binary extends ExpressionTab
  @convert: (obj) ->
    lhs = ExpressionTab.convert(obj.lhs or obj.left)
    rhs = ExpressionTab.convert(obj.rhs or obj.right)
    new @ obj.operator, lhs, rhs
  @preceMap:
    ',': 0
    '...': 1
    'yield': 2
    '|=': 3
    '^=': 3
    '&=': 3
    '>>>=': 3
    '>>=': 3
    '<<=': 3
    '%=': 3
    '/=': 3
    '*=': 3
    '**=': 3
    '-=': 3
    '+=': 3
    '=': 3
    '?': 4
    '||': 5
    '&&': 6
    '|': 7
    '^': 8
    '&': 9
    '!==': 10
    '===': 10
    '!=': 10
    '==': 10
    'instanceof': 11
    'in': 11
    '>=': 11
    '>': 11
    '<=': 11
    '<': 11
    '>>>': 12
    '>>': 12
    '<<': 12
    '-': 13
    '+': 13
    '%': 14
    '/': 14
    '*': 14
    '**': 14
    'delete': 15
    'void': 15
    'typeof': 15
    '--': 15
    '++': 15
    '~': 15
    '!': 15
    'new': 17
    '(': 17
  constructor: (@op, @lhs, @rhs) ->
  precedence: () ->
    if Binary.preceMap.hasOwnProperty(@op)
      Binary.preceMap[@op]
    else
      throw new Error("unknown_binary_operator: " + @op)
  _oneLine: (buffer, level) ->
    higherThanLhs = @precedence() > @lhs.precedence()
    if higherThanLhs
      buffer.pushOneLine '('
    @lhs.oneLine buffer, level
    if higherThanLhs
      buffer.pushOneLine ')'
    buffer.pushOneLine ' ', @op, ' '
    higherThanRhs =  @precedence() > @rhs.precedence()
    if higherThanRhs
      buffer.pushOneLine '('
    @rhs.oneLine buffer, level
    if higherThanRhs
      buffer.pushOneLine ')'
  _multiLine: (buffer, level) ->
    higherThanLhs = @precedence() > @lhs.precedence()
    if higherThanLhs
      buffer.push '('
    @lhs.multiLine buffer, level
    if higherThanLhs
      buffer.push ')'
    buffer.push ' ', @op
    buffer.fixedTab level
    higherThanRhs =  @precedence() > @rhs.precedence()
    if higherThanRhs
      buffer.push '('
    @rhs.multiLine buffer, level
    if higherThanRhs
      buffer.push ')'

ExpressionTab.register class If extends ExpressionTab
  @convert: (obj) ->
    condExp = ExpressionTab.convert obj.test
    thenExp = ExpressionTab.convert obj.consequent
    elseExp = if obj.alternate then ExpressionTab.convert obj.alternate else undefined
    new @ condExp, thenExp, elseExp
  constructor: (@cond, @then, @else) ->
    if not (@then instanceof Block)
      @then = new Block [ @then ]
    if not (@else instanceof Block)
      @else = new Block [ @else ]
  multiLine: (buffer, level) ->
    buffer.push 'if ('
    @cond.multiLine buffer, level + 1
    buffer.push ') '
    @then.multiLine buffer, level
    if @else
      buffer.push ' else '
      @else.multiLine buffer, level

ExpressionTab.register class Block extends ExpressionTab
  @convert: (obj) ->
    items =
      for item in obj.body
        ExpressionTab.convert item
    new @ items
  constructor: (@body) ->
  multiLine: (buffer, level) ->
    buffer.push '{'
    for item in @body
      buffer.fixedTab level + 1
      item.multiLine buffer, level + 1
      buffer.push ';'
    buffer.fixedTab level
    buffer.push '}'

ExpressionTab.register class Assign extends ExpressionTab
  @convert: (obj) ->
    name = ExpressionTab.convert obj.left
    value = ExpressionTab.convert obj.right
    new @ name, value
  constructor: (@name, @value) ->
  multiLine: (buffer, level) ->
    @name.multiLine buffer, level
    buffer.push ' = '
    @value.multiLine buffer, level + 1

ExpressionTab.register class Funcall extends ExpressionTab
  @convert: (obj) ->
    func = ExpressionTab.convert obj.callee
    args =
      for arg in obj.arguments
        ExpressionTab.convert arg
    new @ func, args
  constructor: (@func, @args) ->
  _oneLine: (buffer, level) ->
    @func.oneLine buffer, level
    buffer.push '('
    for arg, i in @args
      if i > 0
        buffer.push ', '
      arg.oneLine buffer, level
    buffer.push ')'
  _multiLine: (buffer, level) ->
    @func.multiLine buffer, level
    buffer.push '('
    for arg, i in @args
      if i > 0
        buffer.push ','
        buffer.fixedTab level + 1
      arg.multiLine buffer, level + 1
    buffer.push ')'

module.exports =
  prettify: Pretty.makePrinter(ExpressionTab)
  Expression: ExpressionTab

console.log module.exports.prettify {
  type: 'Identifier'
  name: 'foo'
}

console.log module.exports.prettify
  type: 'BinaryExpression'
  operator: '*'
  left: {
    type: 'Identifier'
    name: 'foo'
  }
  right:
    type: 'BinaryExpression'
    operator: '+'
    left:
      type: 'Identifier'
      name: 'bar'
    right:
      type: 'Literal'
      value: 3

console.log module.exports.prettify
  type: 'IfExpression'
  test:
    type: 'BinaryExpression'
    operator: '>'
    left:
      type: 'Identifier'
      name: 'foo'
    right:
      type: 'Identifier'
      name: 'bar'
  consequent:
    type: 'BlockExpression'
    body: [
      {
        type: 'BinaryExpression'
        operator: '*'
        left: {
          type: 'Identifier'
          name: 'foo'
        }
        right:
          type: 'BinaryExpression'
          operator: '+'
          left:
            type: 'Identifier'
            name: 'bar'
          right:
            type: 'Literal'
            value: 3
      }
    ]
  alternate:
    type: 'AssignmentExpression'
    operator: '='
    left: {
      type: 'Identifier'
      name: 'foo'
    }
    right:
      type: 'CallExpression'
      callee:
        type: 'Identifier'
        name: 'baz'
      arguments: [
        {
          type: 'Identifier'
          name: 'foo'
        }
        {
          type: 'Identifier'
          name: 'bar'
        }
      ]

