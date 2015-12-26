
class Buffer
  constructor: (@limit, @tab = '  ') ->
    @lines = []
    @newLine()
  branch: () ->
    buffer = new Buffer(@limit)
    buffer.prev = @
    buffer.continuePreviousLine = true
    buffer
  merge: (sub) ->
    if sub.prev == @
      for line, i in sub.lines
        if sub.continuePreviousLine and i == 0
          @pushArray line
        else
          @lines.push line
      @lastLine = @lines[@lines.length - 2]
      @currentLine = @lines[@lines.length - 1]
    else
      throw { cannotMerge: 'Not_connected_to_current_buffer' }
  # the flex tab so far 
  flexTab: (level, precede...) ->
    #console.log 'Buffer.flexTab', level, precede, @currentLine[@currentLine.length - 1]
    if @currentLine[@currentLine.length - 1] in precede
      @pushOneLine ' '
    else
      @fixedTab level
  fixedTab: (level) ->
    if @currentLine.length > 0
      @newLine()
    @pushArray (@tab for i in [0...level])
  wordedTab: (level) ->
    if @currentLine.length > 0
      @newLine()
    for idx in [0...level]
      if @lastLine[idx]
        str = (' ' for i in [0...@lastLine[idx].length]).join('')
        @push str
  newLine: (currentLine = @currentLine) ->
    @lastLine = currentLine
    @currentLine = []
    @lines.push @currentLine
  pushOneLine: (items...) ->
    @pushArray items, true
  push: (items...) ->
    @pushArray items
  top: () ->
    @currentLine[@currentLine.length - 1]
  pushArray: (items, checkExceeds = false) ->
    for item in items
      if checkExceeds and @exceedsLimit(item)
        throw { exceedsLimit: @limit, item: item }
      #if item.indexOf('\n') == 0 # we are starting a new line.
      #  @newLine()
      @currentLine.push item
  currentLength: () ->
    @currentLine.join('').length
  exceedsLimit: (item) ->
    length = item.length + @currentLine.join('').length
    #console.log 'Buffer.exceedsItem', length, @limit, item
    length > @limit
  flatten: (acc = []) ->
    if @prev
      @prev.flatten acc
    for line in @lines
      #console.log 'Buffer.flatten', line, line.join('')
      acc.push line.join('')
    acc
  join: () ->
    acc = []
    @flatten(acc)
    acc.join('\n')

module.exports = Buffer

