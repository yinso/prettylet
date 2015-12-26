# pretty print a sub-set of javascript as an example.

Pretty = require '../src/pretty'

class Expression extends Pretty.Tab
  @types: {}
  @register: (converter) ->
    if @types.hasOwnProperty(converter.name)
      throw new Error("Expression.duplicate: " + converter.name)
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
    VariableDeclaration: 'DefineGroup'
    VariableDeclarator: 'Decl'
    Program: 'Program'
  }
  @mapType: (key) ->
    @typeMaps[key]
  @get: (type) ->
    if @types.hasOwnProperty(type)
      @types[type]
    else
      throw new Error("Expression.unknownType: " + type)
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
Expression.register class Literal extends Pretty.Literal
  @convert: (obj) ->
    new @ obj.value
  precedence: () -> Infinity

Expression.register class Symbol extends Expression
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

Expression.register class Binary extends Expression
  @convert: (obj) ->
    lhs = Expression.convert(obj.lhs or obj.left)
    rhs = Expression.convert(obj.rhs or obj.right)
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

Expression.register class If extends Expression
  @convert: (obj) ->
    condExp = Expression.convert obj.test
    thenExp = Expression.convert obj.consequent
    elseExp = if obj.alternate then Expression.convert obj.alternate else undefined
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

Expression.register class Block extends Expression
  @convert: (obj) ->
    items =
      for item in obj.body
        Expression.convert item
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

Expression.register class Assign extends Expression
  @convert: (obj) ->
    name = Expression.convert obj.left
    value = Expression.convert obj.right
    new @ name, value
  constructor: (@name, @value) ->
  _oneLine: (buffer, level) ->
    @name.oneLine buffer, level
    buffer.push ' = '
    @value.oneLine buffer, level + 1
  _multiLine: (buffer, level) ->
    @name.multiLine buffer, level
    buffer.push ' = '
    @value.multiLine buffer, level + 1

Expression.register class Funcall extends Expression
  @convert: (obj) ->
    func = Expression.convert obj.callee
    args =
      for arg in obj.arguments
        Expression.convert arg
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

Expression.register class DefineGroup extends Expression
  @convert: (obj) ->
    inners =
      for decl in obj.declarations
        Expression.convert decl
    new @ inners
  constructor: (@decls, @kind = 'var') -> # kind can also be let or const.
  _oneLine: (buffer, level) ->
    buffer.pushOneLine @kind
    for decl, i in @decls
      if i > 0
        buffer.pushOneLine ','
      buffer.pushOneLine ' '
      decl.oneLine buffer, level + 1
    buffer.pushOneLine ';'
  _multiLine: (buffer, level) ->
    buffer.push @kind
    for decl, i in @decls
      if i > 0
        buffer.push ','
      buffer.fixedTab level + 1
      decl.multiLine buffer, level + 1
    buffer.pushOneLine ';'

Expression.register class Decl extends Expression
  @convert: (obj) ->
    name = Expression.convert obj.id
    value =
      if obj.init
        Expression.convert obj.init
      else
        undefined
    new @ name, value
  constructor: (@name, @value) ->
  _oneLine: (buffer, level) ->
    @name.oneLine buffer, level
    if @value
      buffer.push ' = '
      @value.oneLine buffer, level + 1
  _multiLine: (buffer, level) ->
    @name.multiLine buffer, level
    if @value
      buffer.push ' = '
      @value.multiLine buffer, level + 1

Expression.register class Program extends Pretty.Collection
  @convert: (obj) ->
    body =
      for item in obj.body
        Expression.convert item
    new @ body
  constructor: (@children) ->
    super @children, ''
  precedence: () -> Infinity
  multiLine: (buffer, level) ->
    @_multiLine buffer, level
  _multiLine: (buffer, level) ->
    for child, i in @children
      @_multiLineChild buffer, level, child, i

module.exports =
  prettify: Pretty.makePrinter(Expression)
  Expression: Expression

console.log module.exports.prettify
  type: 'Identifier'
  name: 'foo'

console.log module.exports.prettify
  type: 'BinaryExpression'
  operator: '*'
  left:
    type: 'Identifier'
    name: 'foo'
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
  type: 'Program'
  body: [
    {
      type: 'VariableDeclaration'
      declarations: [
        {
          type: 'VariableDeclarator'
          id: {
            type: 'Identifier'
            name: 'foo'
          }
          init: {
            type: 'Literal'
            value: 5
          }
        }
        {
          type: 'VariableDeclarator'
          id: {
            type: 'Identifier'
            name: 'bar'
          }
          init: {
            type: 'Literal'
            value: 10
          }
        }
      ]        
    }
    {
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
            left:
              type: 'Identifier'
              name: 'foo'
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
        left:
          type: 'Identifier'
          name: 'foo'
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
    }
  ]
