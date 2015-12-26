// Generated by CoffeeScript 1.8.0
(function() {
  var Buffer, Collection, Literal, Tab, prettify;

  Buffer = require('./buffer');

  Tab = require('./tab');

  Collection = require('./collection');

  Literal = require('./literal');

  prettify = function(obj, converter) {
    var buffer, converted;
    converted = converter.convert(obj);
    buffer = new Buffer(80);
    converted.multiLine(buffer, 0);
    return buffer.join();
  };

  module.exports = {
    prettify: prettify,
    Buffer: Buffer,
    Tab: Tab,
    Collection: Collection,
    Literal: Literal
  };

}).call(this);