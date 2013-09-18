;(function($) {
  $.fn.scrollTo = function(target, duration, offset) {
    this.animate({ scrollTop: $(target).offset().top + offset }, duration);
  };
})(jQuery);
