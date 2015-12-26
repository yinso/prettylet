'use strict';

// pretty-print yaml structure

var pretty = require('../lib/pretty');

function Literal(val) {
  pretty.Literal.call(this, val);
}

Literal.prototype = new pretty.Literal();

Literal.prototype.convert = function () {
  if (typeof(this.val) == 'string') {
    return "'" + this.val.replace(/\'/g, "\\'") + "'";
  } else {
    return pretty.Literal.prototype.convert.call(this);
  }
};

function KeyVal(key, val) {
  pretty.KeyVal.call(this, key, val, ':');
}

KeyVal.prototype = new pretty.KeyVal('foo', 'bar', ':');

KeyVal.prototype._multiLineDelim = function (buffer, level) {
  buffer.push(this.delim, ' ');
}

function ArrayItemTab(inner) {
  this.inner = inner;
}

ArrayItemTab.prototype = new pretty.Tab();

ArrayItemTab.prototype.multiLine = function (buffer, level) {
  buffer.push('- ');
  this.inner.multiLine(buffer, level);
}


function YamlTab(children, type) {
  pretty.Collection.call(this, children, '');
  this.type = type || 'object';
}

YamlTab.convert = function (obj) {
  switch (typeof(obj)) {
    case 'object':
      if (obj == null) {
        return new Literal(obj);
      } else if (obj instanceof Array) {
        return convertArray(obj);
      } else {
        return convertObject(obj);
      }
    default:
      return new Literal(obj);
  }
}

function convertArray(ary) {
  var children = [];
  for (var i = 0; i < ary.length; ++i) {
    children.push(new ArrayItemTab(YamlTab.convert(ary[i])));
  }
  return new YamlTab(children, 'array');
}

function convertObject(obj) {
  var children = [];
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      var val = YamlTab.convert(obj[key]);
      children.push(new KeyVal(key, val, ':'))
    }
  }
  return new YamlTab(children, 'object');
}

YamlTab.prototype = new pretty.Collection([], '');

YamlTab.prototype.oneLine = function (buffer, level) {
  if (this.type == 'array') {
    buffer.push('[ ]');
  } else {
    buffer.push('{ }');
  }
}

YamlTab.prototype._oneLineOpen = function(buffer, level) {
  
};

YamlTab.prototype._oneLineClose = function(buffer, level) {

};

YamlTab.prototype.multiLine = function (buffer, level) {
  if (this.children.length == 0) {
    return this.oneLine(buffer, level);
  } else {
    return this._multiLine(buffer, level);
  }
}

YamlTab.prototype._multiLineChildTab = function (buffer, level, i) {
  if (buffer.top() != '- ') {
  buffer.fixedTab(level - 1);
  }
}

YamlTab.prototype._multiLineOpen = function(buffer, level) {

};


YamlTab.prototype._multiLineClose = function(buffer, level) {

};

var prettify = pretty.makePrinter(YamlTab);

module.exports = {
  prettify: prettify,
  Yaml: YamlTab
};

console.log(prettify({
  foo: {
    bar: { baz: 1 }
  },
  bar: [
    1, 2, { a: 1, b: 2, c: 3 }, 3 , 
    [ ] , 4 , { } , "what's your name?",
    [ 'foo', 'bar', 'baz' ]    
  ]
}));


