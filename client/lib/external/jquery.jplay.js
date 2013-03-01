;(function($, window, document, undefined) {

  var Play = function(id, options) {
    /**
     * Create a Play instance around a unique identifier (which can be any
     * type of object), which performs an abstract transition for a fixed
     * amount of time, regardless of the frame rate of the page (basically
     * frame skipping) and returns an onFrame callback with a 0-to-1 float
     * ratio, representing the progress of the transition, as often as the
     * browser can perform (but not more often than every 13ms, because that's
     * what the global interval is set to.)
     *
     * A custom transition formula can be set using the "transition" option,
     * otherwise it defaults to linear
     *
     * Warning: Creating a Play instance on an object that already has other
     * instances running around it will clear all them before starting
     */
    this.id = id;
    this.options = $.extend({}, this.defaults, options || {});

    // Validate that we have a callback function (nothing to do otherwise)
    if (typeof(this.options.onFrame) != 'function') {
      throw new Error('Play instance is missing an onFrame callback');
    }
    // A custom transition is optional, but if one is present it needs to be a
    // Function object
    if (this.options.transition &&
        typeof(this.options.transition) != 'function') {
      throw new Error('Play transition must be a Function');
    }
    this.init();
  };
  // Global stack for running instances
  Play.stack = [];

  // Static methods
  Play.init = function() {
    /**
     * Init the Play factory at entire plugin-level.
     *
     * Bails out on any instances that are still running (shouldn't happen
     * under normal circumstances because we only clear the global interval
     * when the last running instance ended its execution)
     */
    // Empty the global instance stack
    this.stack = [];

    // Don't create new interval if one is already running (shouldn't happen
    // unless Play.init was called inappropriately)
    if (this.interval) {
      return;
    }
    var that = this;
    // Set interval with a 13-millisecond refresh time - socially acceptable :)
    this.interval = window.setInterval(function() {
      that.frame();
    }, 13);
  };
  Play.push = function(instance) {
    /**
     * Push Play instance into the running loop
     */
    // Since the entire Play running loop shuts down when the last instance
    // standing ends its execution, we must make sure it's running whenever
    // pushing a new one
    if (!this.interval) {
      this.init();
    }
    this.stack.push(instance);
  };
  Play.cancel = function(id) {
    /**
     * Cancel a Play instance on a given identifier
     */
    for (var i = 0; i < this.stack.length; i++) {
      if (this.stack[i].id === id) {
        this.stack.splice(i, 1);
        return;
      }
    }
  };
  Play.frame = function(deleteAtIndex, time) {
    /**
     * Called with every interval loop; goes through all active instances and
     * runs their own onFrame callback individually.
     *
     * This method has two optional parameters that are only present when
     * entering recursion: an index of the stack to remove an instance at, and
     * the time at which this recursion started at. This happens when in the
     * process of rendering a frame loop, while going through all active
     * instances, we detect ones that have expired and thus want to remove
     * them. Removing an element of a list whilst looping through it causes
     * undesired behavior, so we're using this recursive pattern instead, where
     * we resume to the next element in a recursive call, after removing one
     * and breaking that current loop
     */
    if (deleteAtIndex !== undefined) {
      this.stack.splice(deleteAtIndex, 1);
      // Clear the entire running running loop if this was the last instance
      // running (it will be restarted automatically when a new Play instance
      // is created)
      if (!this.stack.length) {
        window.clearInterval(this.interval);
        this.interval = null;
      }
    }
    // Unless we're inside a recursive call (and we receive it as the 2nd
    // parameter, we need to fetch the current timestamp to send to all running
    // instances
    if (!time) {
      time = now();
    }
    for (var i = deleteAtIndex || 0; i < this.stack.length; i++) {
      // If an instance's frame handler returns false it means that it has
      // exceeded its timeframe and ended its execution and thus needs to be
      // removed from the running stack
      if (!this.stack[i].frame(time)) {
        this.frame(i, time);
        return;
      }
    }
  };

  // Prototype methods
  Play.prototype = {
    // Constructor options will extend these
    defaults: {
      // The default duration is none (instant)
      time: 0,
      // Start the transition at a given ratio directly; useful when trying to
      // resume a previous transition or to start a new one from the same
      // position a previous transition was stopped at
      ratio: 0
    },
    init: function() {
      // Cancel any currently-running instances wrapped around the same unique
      // id as the new instance we're trying to init
      Play.cancel(this.id);

      this.t1 = now();
      this.t2 = this.t1 + (this.options.time * 1000);
      // If a starting ratio is specified along with the constructor options,
      // we need to shift this instance's entire timeframe along the timeline,
      // in order to continue from that given ratio (in other words start a
      // transition mid-way)
      if (this.options.ratio) {
        var offset = (this.t2 - this.t1) * this.options.ratio;
        this.t1 -= offset;
        this.t2 -= offset;
      }

      // Only push the instance into the running stack if it has valid time
      // parameters, its ending point later in time than its starting point,
      // that is
      if (this.t2 > this.t1) {
        Play.push(this);
      }
      // Run the onFrame callback on the instance for the first time, manually
      // (in order for it to have synchronous effect, and have its initial state
      // applied immediately)
      this.frame(now());
    },
    frame: function(time) {
      /**
       * Called with every frame loop as long as this instance is active and
       * within its timeframe.
       *
       * Receives the current timestamp as a parameter from the Play factory
       * in order to avoid having to fetch it for each instance individually
       */
      var ratio;
      // The starting time should always be smaller than the ending one, but we
      // must avoid division by 0 no matter what
      if (this.t2 != this.t1) {
        // Make sure the ratio doesn't exceed 1, which is the end value of a
        // transition (max value)
        ratio = Math.min((time - this.t1) / (this.t2 - this.t1), 1);
      } else {
        ratio = 1;
      }
      // Apply user-defined transition formula, if specified. Not having one
      // simply renders the transition linear
      if (this.options.transition) {
        ratio = this.options.transition(ratio);
      }

      // Call user-defined callback with the current progress of the transition
      // as the only parameter
      this.options.onFrame(ratio);
      // Returning true means that the transition isn't over yet and will
      // maintain its position into the running loop, while returning false
      // will simply end its lifespan
      return ratio < 1;
    }
  };

  // Helper methods
  var now = function() {
    /**
     * Local shorthand helper for fetching current timestamp
     */
    return new Date().getTime();
  };

  // Hook plugin to jQuery selections
  $.fn.play = function(options) {
    this.each(function() {
      // Create a Play instance using the DOM element as a unique identifier
      new Play(this, options);
    });
    // Maintain jQuery chain
    return this;
  };

})(jQuery, window, document);