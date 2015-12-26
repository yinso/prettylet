Buffer = require './buffer'
Tab = require './tab'
Collection = require './collection'
Literal = require './literal'

prettify = (obj, converter) ->
  converted = converter.convert(obj)
  buffer = new Buffer(80)
  converted.multiLine buffer, 0
  buffer.join()

module.exports =
  prettify: prettify
  Buffer: Buffer
  Tab: Tab
  Collection: Collection
  Literal: Literal

