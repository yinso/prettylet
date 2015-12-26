
class Tab
  depth: () -> 1
  oneLine: (buffer, level) ->
    temp = buffer.branch()
    @_oneLine temp, level
    buffer.merge temp
  #_oneLine: (buffer, level) ->
  multiLine: (buffer, level) ->
    try
      @oneLine buffer, level
    catch e
      @_multiLine buffer, level
  #_multiLine: (buffer, level) ->

module.exports = Tab

