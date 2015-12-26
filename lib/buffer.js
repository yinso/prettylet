// Generated by CoffeeScript 1.8.0
(function() {
  var Buffer,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Buffer = (function() {
    function Buffer(limit, tab) {
      this.limit = limit;
      this.tab = tab != null ? tab : '  ';
      this.lines = [];
      this.newLine();
    }

    Buffer.prototype.branch = function() {
      var buffer;
      buffer = new Buffer(this.limit);
      buffer.prev = this;
      buffer.continuePreviousLine = true;
      return buffer;
    };

    Buffer.prototype.merge = function(sub) {
      var i, line, _i, _len, _ref;
      if (sub.prev === this) {
        _ref = sub.lines;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          line = _ref[i];
          if (sub.continuePreviousLine && i === 0) {
            this.pushArray(line);
          } else {
            this.lines.push(line);
          }
        }
        this.lastLine = this.lines[this.lines.length - 2];
        return this.currentLine = this.lines[this.lines.length - 1];
      } else {
        throw {
          cannotMerge: 'Not_connected_to_current_buffer'
        };
      }
    };

    Buffer.prototype.flexTab = function() {
      var level, precede, _ref;
      level = arguments[0], precede = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (_ref = this.currentLine[this.currentLine.length - 1], __indexOf.call(precede, _ref) >= 0) {
        return this.pushOneLine(' ');
      } else {
        return this.fixedTab(level);
      }
    };

    Buffer.prototype.fixedTab = function(level) {
      var i;
      if (this.currentLine.length > 0) {
        this.newLine();
      }
      return this.pushArray((function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= level ? _i < level : _i > level; i = 0 <= level ? ++_i : --_i) {
          _results.push(this.tab);
        }
        return _results;
      }).call(this));
    };

    Buffer.prototype.wordedTab = function(level) {
      var i, idx, str, _i, _results;
      if (this.currentLine.length > 0) {
        this.newLine();
      }
      _results = [];
      for (idx = _i = 0; 0 <= level ? _i < level : _i > level; idx = 0 <= level ? ++_i : --_i) {
        if (this.lastLine[idx]) {
          str = ((function() {
            var _j, _ref, _results1;
            _results1 = [];
            for (i = _j = 0, _ref = this.lastLine[idx].length; 0 <= _ref ? _j < _ref : _j > _ref; i = 0 <= _ref ? ++_j : --_j) {
              _results1.push(' ');
            }
            return _results1;
          }).call(this)).join('');
          _results.push(this.push(str));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Buffer.prototype.newLine = function(currentLine) {
      if (currentLine == null) {
        currentLine = this.currentLine;
      }
      this.lastLine = currentLine;
      this.currentLine = [];
      return this.lines.push(this.currentLine);
    };

    Buffer.prototype.pushOneLine = function() {
      var items;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.pushArray(items, true);
    };

    Buffer.prototype.push = function() {
      var items;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.pushArray(items);
    };

    Buffer.prototype.pushArray = function(items, checkExceeds) {
      var item, _i, _len, _results;
      if (checkExceeds == null) {
        checkExceeds = false;
      }
      _results = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if (checkExceeds && this.exceedsLimit(item)) {
          throw {
            exceedsLimit: this.limit,
            item: item
          };
        }
        _results.push(this.currentLine.push(item));
      }
      return _results;
    };

    Buffer.prototype.currentLength = function() {
      return this.currentLine.join('').length;
    };

    Buffer.prototype.exceedsLimit = function(item) {
      var length;
      length = item.length + this.currentLine.join('').length;
      return length > this.limit;
    };

    Buffer.prototype.flatten = function(acc) {
      var line, _i, _len, _ref;
      if (acc == null) {
        acc = [];
      }
      if (this.prev) {
        this.prev.flatten(acc);
      }
      _ref = this.lines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        acc.push(line.join(''));
      }
      return acc;
    };

    Buffer.prototype.join = function() {
      var acc;
      acc = [];
      this.flatten(acc);
      return acc.join('\n');
    };

    return Buffer;

  })();

  module.exports = Buffer;

}).call(this);