// Generated by CoffeeScript 1.4.0
(function() {
  var SEARCH_TIMEOUT, root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  SEARCH_TIMEOUT = 250;

  root.SearchBox = (function() {

    function SearchBox(input, f_search, f_select) {
      this.input = input;
      this.f_search = f_search;
      this.f_select = f_select;
      this.search = __bind(this.search, this);

      this.inputKeyPressed = __bind(this.inputKeyPressed, this);

      this.keyDownTimeout = null;
      this.input.onkeydown = this.inputKeyPressed;
    }

    SearchBox.prototype.inputKeyPressed = function(event) {
      if (event.keyCode === 13) {
        this.f_select();
      }
      if (this.keyDownTimeout != null) {
        window.clearTimeout(this.keyDownTimeout);
      }
      return this.keyDownTimeout = window.setTimeout(this.search, SEARCH_TIMEOUT);
    };

    SearchBox.prototype.search = function() {
      var text;
      text = this.input.value;
      return this.f_search(text);
    };

    return SearchBox;

  })();

}).call(this);
