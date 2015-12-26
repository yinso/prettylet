Buffer = require './buffer'
Tab = require './tab'
Collection = require './collection'
KeyVal = require './keyval'
Literal = require './literal'

prettify = (obj, converter) ->
  converted = converter.convert(obj)
  buffer = new Buffer(80)
  converted.multiLine buffer, 0
  buffer.join()

makePrinter = (converter) ->
  (obj) ->
    prettify obj, converter

module.exports =
  makePrinter: makePrinter
  prettify: prettify
  Buffer: Buffer
  Tab: Tab
  Collection: Collection
  Literal: Literal
  KeyVal: KeyVal

