;(function($, window, document, undefined) {
  var Bubble = function(element, options) {
    /**
     * Create a Bubble instance around a DOM element that increases its width
     * and height on mouseover (goes back on mouseout). See defaults for
     * possible options.
     */
    this.$element = $(element);
    this.options = $.extend({}, this.defaults, options);
    this.init();
  };
  // Constructor options will extend these
  Bubble.defaults = {
    // The duration of the transition
    time: 0.1,
    // The amount of widget/height to grow on mouseover
    offset: 10
  }
  Bubble.prototype = {
    init: function() {
      // Check if a Bubble instance has already been initialized on this DOM
      // $element and unbind it if found
      var previousInstance = this.$element.data('bubble');
      // Check if whatever's in the data attribute actually has an "unbind"
      // method, it might be other type of object put by some other plugin
      // (tough luck!)
      if (previousInstance && previousInstance.unbind) {
        // Its events have been unbound, the reference will be removed once we
        // store the new instance in the data attribute, it's up to the GC to
        // take it from here
        previousInstance.unbind();
      }
      // Store current instance in a data attribute of the DOM element (replace
      // any previous one)
      this.$element.data('bubble', this);

      // Get everything else we need in order to get this running and add mouse
      // events
      this.extractBaseAttributes();

      // Bind DOM events to instance (should be unbound at destroy!)
      this.bind();
    },
    bindMethod: function(fn) {
      /**
       * Bind prototype method to instance scope (similar to CoffeeScript's fat
       * arrow)
       */
      var that = this;
      return function() {
        return fn.apply(that, arguments);
      };
    },
    bind: function() {
      // Create reference for wrapped event listeners, in order to be able to
      // unbind them later on (couldn't with closures)
      this.onMouseOver = this.bindMethod(this.onMouseOver);
      this.onMouseOut = this.bindMethod(this.onMouseOut);

      this.$element.on('mouseover', this.onMouseOver);
      this.$element.on('mouseout', this.onMouseOut);
    },
    unbind: function() {
      this.$element.off('mouseover', this.onMouseOver);
      this.$element.off('mouseout', this.onMouseOut);
    },
    extractBaseAttributes: function() {
      /**
       * Get initial values for the element attributes we need to work width,
       * because we're never working with absolute values, but with offsets
       * relative to these ones.
       */
      this.base = {
        left: this.parseNumericAttribute('margin-left'),
        top: this.parseNumericAttribute('margin-top'),
        width: this.$element.width(),
        height: this.$element.height()
      };
    },
    parseNumericAttribute: function(attr) {
      return parseInt(this.$element.css(attr));
    },
    onMouseOver: function() {
      this.toggle(1);
    },
    onMouseOut: function() {
      this.toggle(0);
    },
    toggle: function(toggle) {
      /**
       * Expand or contract bubble using a boolean(ish) parameter, 0 or 1.
       */
      // Important: since a transition can be interrupted and turned around at
      // any point (e.g. at fast mouse over/out) we need to make sure it
      // resumes from its latest state (and doesn't snap to any extremity). For
      // that reason we store this.currentRatio with every transition
      // callback, but we need to know how to apply it when changing transition
      // around, which is to start transition from its opposite (1 - x)
      var initialRatio = 0;
      // If a previous transition has already been running
      if (this.currentRatio != null) {
        // When moving in the opposite direction from before
        if (toggle != this.direction) {
          initialRatio = 1 - this.currentRatio
        // When moving in the same direction as before
        } else {
          initialRatio = this.currentRatio;
        }
      }
      // Store the toggle value so that we know the direction we're moving
      // towards (and compare it with future ones, see above)
      this.direction = toggle;

      var that = this;
      // Perform a transition on the "play" plugin whenever the Bubble is
      // toggled
      this.$element.play({
        time: this.options.time,
        // Start transition with initial ratio
        ratio: initialRatio,
        callback: function(ratio) {
          // Store the most current transition ratio returned by the play
          // callback into the Bubble instance
          that.currentRatio = ratio;
          // Expand or contract depending on our current direction
          ratio = that.direction ? ratio : 1 - ratio;

          // Obtain offset at this phase of the transition
          var offset = that.options.offset * ratio;
          // Important: Unless the ratio has hit a destination (original or
          // target state) we need to make sure the offset is divisable by 2,
          // so it syncs with the left/top movement, which is half the offset
          // and needs to be an integer (browsers only apply integer values to
          // elements)
          if(that.ratio != 1) {
            offset = 2 * Math.round(offset / 2);
          }
          // Apply offset to DOM element
          that.applyOffset(offset);
        }
      });
    },
    applyOffset: function(offset) {
      /**
       * Apply transition state to DOM element (called on every frame change
       * triggered by the "play" plugin)
       */
      $(this.$element).css({
        marginLeft: this.base.left - offset / 2,
        marginTop: this.base.top - offset / 2,
        width: this.base.width + offset,
        height: this.base.height + offset,
        lineHeight: (this.base.height + offset) + 'px'
      });
    }
  };
  // Hook plugin to jQuery selections
  $.fn.bubble = function(options) {
    this.each(function() {
      new Bubble(this, options);
    });
    // Maintain jQuery chain
    return this;
  };
})(jQuery, window, document);