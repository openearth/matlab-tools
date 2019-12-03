/*
 *
 *  jQuery truncateLines by Gary Hepting - https://github.com/ghepting/truncateLines
 *  
 *  Open source under the MIT License. 
 *
 *  Copyright © 2013 Gary Hepting. All rights reserved.
 *
*/


(function() {
  var TruncatedLines, delayedAdjust, truncateIndex;

  delayedAdjust = [];

  truncateIndex = 0;

  TruncatedLines = (function() {
    function TruncatedLines(el) {
      this.el = el;
      this.index = truncateIndex++;
      this.text = $(this.el).text();
      $(this.el).attr('data-text', this.text);
      this.words = this.text.trim().split(" ");
      this.lines = parseInt($(this.el).attr('data-truncate'));
      this.truncate();
      this.adjustOnResize();
    }

    TruncatedLines.prototype.truncate = function() {
      this.measure();
      return this.setContent();
    };

    TruncatedLines.prototype.reset = function() {
      return $(this.el).text(this.text).css('max-height', 'none').attr('data-truncated', 'false');
    };

    TruncatedLines.prototype.measure = function() {
      var i;
      this.reset();
      $(this.el).html(".");
      this.singleLineHeight = $(this.el).outerHeight();
      i = 1;
      while (i++ < this.lines) {
        $(this.el).append("<br>.");
      }
      return this.maxLinesHeight = $(this.el).outerHeight();
    };

    TruncatedLines.prototype.empty = function() {
      return $(this.el).html("");
    };

    TruncatedLines.prototype.setContent = function() {
      var truncated;
      this.reset();
      truncated = false;
      this.addWords(this.words.length);
      if (this.tooBig()) {
        this.addNumberWordsThatFit();
        $(this.el).css('max-height', this.maxLinesHeight + 'px');
        return $(this.el).attr('data-truncated', true);
      }
    };

    TruncatedLines.prototype.addNumberWordsThatFit = function() {
      var can, cant, mid;
      cant = this.words.length;
      can = 0;
      mid = Math.floor(this.words.length / 2);
      while (can + 1 !== cant) {
        this.addWords(can + mid);
        if (this.tooBig()) {
          cant = can + mid;
        } else {
          can = can + mid;
        }
        mid = Math.floor(mid / 2) || 1;
      }
      this.addWords(can);
      return $(this.el).html(this.trimTrailingPunctuation($(this.el).html()));
    };

    TruncatedLines.prototype.addWords = function(num) {
      return $(this.el).html(this.words.slice(0, num).join(" "));
    };

    TruncatedLines.prototype.tooBig = function() {
      return $(this.el).outerHeight() > this.maxLinesHeight;
    };

    TruncatedLines.prototype.adjustOnResize = function() {
      var _this = this;
      return $(window).on('resize', function() {
        clearTimeout(delayedAdjust[_this.index]);
        return delayedAdjust[_this.index] = setTimeout(function() {
          return _this.truncate();
        }, 50);
      });
    };

    TruncatedLines.prototype.trimTrailingPunctuation = function(str) {
      return str.replace(/(,$)|(\.$)|(\:$)|(\;$)|(\?$)|(\!$)/g, "");
    };

    return TruncatedLines;

  })();

  (function($) {
    var truncateInitialized, truncatedThings;
    truncateInitialized = false;
    truncatedThings = [];
    return $.fn.truncateLines = function() {
      if (!truncateInitialized) {
        $('head').append('<style type="text/css"> [data-truncated="true"] { overflow: hidden; } [data-truncated="true"]:after { content: "..."; position: absolute; } </style>');
      }
      return this.each(function() {
        return truncatedThings.push(new TruncatedLines(this));
      });
    };
  })(jQuery);

  $(window).load(function() {
    return $("[data-truncate]").truncateLines();
  });

}).call(this);
