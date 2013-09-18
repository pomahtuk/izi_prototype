(function() {
  var getFullObject, isSameLine, lastOfLine, tileGrid;

  lastOfLine = function(elem) {
    var pred, top;
    elem = $(elem);
    top = elem.offset().top;
    pred = function() {
      return top < $(this).offset().top;
    };
    return $.merge(elem, elem.nextUntil(pred)).last();
  };

  isSameLine = function(x, y) {
    return x.length > 0 && y.length > 0 && x.offset().top === y.offset().top;
  };

  getFullObject = (function() {
    var xhr;
    xhr = null;
    return function(url, handler) {
      if (xhr) {
        xhr.abort();
      }
      return xhr = $.getJSON(url, function(json) {
        return handler(json);
      });
    };
  })();

  tileGrid = function(collection, tileWidth, tileSpace, tileListMargin) {
    var diff, lineSize, marginLeft, tileRealWidth, windowRealWidth, windowWidth;
    windowWidth = $(window).innerWidth();
    tileRealWidth = tileWidth + tileSpace;
    windowRealWidth = windowWidth - tileListMargin * 2 + tileSpace;
    lineSize = Math.floor(windowRealWidth / tileRealWidth);
    diff = windowWidth - (lineSize * tileRealWidth - tileSpace);
    marginLeft = Math.floor(diff / 2);
    collection.css({
      'margin-right': 0,
      'margin-left': tileSpace
    });
    return collection.each(function(i) {
      if (i % lineSize !== 0) {
        return;
      }
      return $(this).css({
        'margin-left': marginLeft
      });
    });
  };

  $(function() {
    var assign_click, attachDropDown, closeDropDown, collection, create_museums_search_array, dropDown, fields_behaviour, fillDropDown, findActive, get_number, hide_popovers, modal_template, museum_list_prepare, museum_search, museums_search_array, new_template, tileListMargin, tileSpace, tileWidth;
    collection = $('.exhibits>li.exhibit');
    tileListMargin = 59;
    tileWidth = collection.width();
    tileSpace = parseInt(collection.css('margin-left')) + parseInt(collection.css('margin-right'));
    $('.exhibits').css({
      'text-align': 'left'
    });
    tileGrid(collection, tileWidth, tileSpace, tileListMargin);
    $(window).resize(tileGrid.bind(this, collection, tileWidth, tileSpace, tileListMargin));
    dropDown = $('#drop_down').remove().removeClass('hidden');
    museums_search_array = [];
    findActive = function() {
      return $('ul.exhibits li.active');
    };
    fillDropDown = function(object) {
      var html;
      dropDown.find('p').html(object.description);
      if (object.images.length > 1) {
        html = object.images.map(function(i) {
          return "<img src=\"" + i.big_url + "\">";
        }).join('');
        return dropDown.find('.slides').html(html).slidesjs(slidesjs_options);
      }
    };
    closeDropDown = function() {
      var active, field, number, remove, _i, _len, _ref;
      active = findActive();
      if (active.hasClass('dummy')) {
        if (dropDown.find('#name').val() === '') {
          remove = true;
          _ref = dropDown.find('#media .form-control:not(#opas_number)');
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            field = _ref[_i];
            field = $(field);
            if (field.val() !== '') {
              remove = false;
            }
          }
          if (remove) {
            active.remove();
          } else {
            number = active.data('number');
            $('ul.exhibits').append(modal_template(number));
            $('#dummyModal').modal({
              show: true,
              backdrop: 'static'
            });
            $('#dummyModal').find('.btn-default').click(function() {
              active.remove();
              return $('#dummyModal, .modal-backdrop').remove();
            });
            $('#dummyModal').find('.btn-primary').click(function() {
              active.removeClass('dummy');
              dropDown.find('#name').val("item_" + number);
              active.find('.opener').removeClass('draft');
              return $('#dummyModal, .modal-backdrop').remove();
            });
          }
        }
      }
      dropDown.remove();
      return active.removeClass('active');
    };
    attachDropDown = function(li) {
      var hasParent;
      hasParent = dropDown.parent().length > 0;
      dropDown.insertAfter(lastOfLine(li));
      if (!hasParent) {
        dropDown.find('a.done').unbind('click').bind('click', function(e) {
          e.preventDefault();
          return closeDropDown();
        });
        dropDown.find('>.prev-ex').unbind('click').bind('click', function(e) {
          var active, prev;
          e.preventDefault();
          active = findActive();
          prev = active.prev('.exhibit');
          if (prev.attr('id') === 'drop_down') {
            prev = prev.prev();
          }
          if (prev.length > 0) {
            return prev.find('.opener .description').click();
          } else {
            return active.siblings('.exhibit').last().find('.opener').click();
          }
        });
        dropDown.find('>.next-ex').unbind('click').bind('click', function(e) {
          var active, next;
          e.preventDefault();
          active = findActive();
          next = active.next();
          if (next.attr('id') === 'drop_down') {
            next = next.next();
          }
          if (next.length > 0) {
            return next.find('.opener .description').click();
          } else {
            return active.siblings('.exhibit').first().find('.opener').click();
          }
        });
        dropDown.find('.label-content').unbind('click').bind('click', function(e) {
          var elem, parent;
          elem = $(this);
          parent = elem.parents('.dropdown-menu').prev('.dropdown-toggle');
          if (elem.hasClass('everyone')) {
            return parent.html("<div class='extra'><i class='icon-globe'></i></div><span class='caret'></span>");
          } else {
            return parent.html("<div class='extra'><i class='icon-user'></i></div> Publish <span class='caret'></span>");
          }
        });
        dropDown.find('#delete_story input[type=radio]').unbind('change').bind('change', function() {
          var container, elem;
          elem = $(this);
          container = $('#delete_story');
          if (elem.attr('id') === 'lang_selected') {
            if (elem.is(':checked')) {
              return $('#delete_story .other_variants').slideDown(150);
            }
          } else {
            return $('#delete_story .other_variants').slideUp(150);
          }
        });
        return $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind('change', function() {
          var elem, quiz;
          elem = $(this);
          quiz = dropDown.find('.form-wrap');
          console.log(elem.val());
          if (elem.attr('id') === 'story_quiz_enabled') {
            $('label[for=story_quiz_enabled]').text('Enabled');
            $('label[for=story_quiz_disabled]').text('Disable');
            return true;
          } else {
            $('label[for=story_quiz_disabled]').text('Disabled');
            $('label[for=story_quiz_enabled]').text('Enable');
            return true;
          }
        });
      }
    };
    $(window).resize(function() {
      findActive().each(function() {
        dropDown.remove();
        return attachDropDown(this);
      });
      museum_list_prepare();
      return fields_behaviour();
    });
    hide_popovers = function(target) {
      return $(".icon-question-sign").each(function() {
        if (!$(this).is(target) && $(this).has(target).length === 0 && $(".popover").has(target).length === 0) {
          return $(this).popover("hide");
        }
      });
    };
    fields_behaviour = function() {
      $('.form-group').each(function(index, group) {
        var text;
        group = $(group);
        text = group.find('.triggered > *').val();
        group.find('span.placeholder').text(text);
        group.find('.save_status').html('<i class="icon-ok-sign"></i>saved');
        if (text === '') {
          group.find('.trigger').hide();
          return group.find('.triggered').show().focus();
        }
      });
      $('span.placeholder').unbind('click').bind('click', function() {
        var elem, parent, target;
        elem = $(this);
        parent = elem.parents('.trigger');
        target = parent.next();
        parent.hide();
        return target.show().children().first().val(elem.text()).focus();
      });
      $('.triggered > *').unbind('blur').bind('blur', function() {
        var elem, parent, save_status, target;
        elem = $(this);
        parent = elem.parents('.triggered');
        target = parent.prev();
        if (elem.val() !== '') {
          parent.hide();
          target.show().find('span').text(elem.val());
        }
        save_status = target.parent('.form-group').find('.save_status');
        save_status.fadeIn(300);
        return setTimeout(function() {
          return save_status.fadeOut(300);
        }, 800);
      });
      $('i.icon-question-sign').popover();
      $('.form-group').unbind('mouseenter').bind('mouseenter', function(e) {
        return hide_popovers(e.target);
      });
      $("body").on("click", function(e) {
        return hide_popovers(e.target);
      });
      return $('a.other_lang').unbind('click').bind('click', function() {
        var elem;
        elem = $(this);
        elem.next('ul').toggleClass('hidden');
        return false;
      });
    };
    museum_list_prepare = function() {
      var count, list, row_count, width;
      list = $('ul.museum_list');
      count = list.find('li').length;
      width = $('body').width();
      row_count = (count * 150 + 160) / width;
      if (row_count > 1) {
        $('.museum_filters').show();
        return list.width(width - 200);
      } else {
        $('.museum_filters').hide();
        return list.width(width - 100);
      }
    };
    museum_search = function() {
      $('.museum_navigation_menu .search').click(function() {
        var elem;
        elem = $(this);
        elem.hide();
        return elem.next().show().children().first().focus();
      });
      $('.museum_navigation_menu .search_input input').blur(function() {
        var elem, parent;
        elem = $(this);
        parent = elem.parents('.search_input');
        return elem.animate({
          width: '150px'
        }, 150, function() {
          parent.hide();
          return parent.prev().show();
        });
      });
      $('.museum_navigation_menu .search_input input').focus(function() {
        var input, width;
        input = $(this);
        width = $('body').width() - 700;
        if (width > 150) {
          return input.animate({
            width: "" + width + "px"
          }, 300);
        }
      });
      $('.museum_navigation_menu .search_input input').keyup(function() {
        var index, input, museum, museums, value, _i, _len, _results;
        input = $(this);
        value = input.val().toLowerCase();
        museums = $('ul.museum_list > li');
        if (value.length !== 0) {
          $('.museum_filters a').removeClass('active');
        } else {
          $('.museum_filters a').first().addClass('active');
        }
        _results = [];
        for (index = _i = 0, _len = museums_search_array.length; _i < _len; index = ++_i) {
          museum = museums_search_array[index];
          if (museum.indexOf(value) === -1) {
            _results.push($(museums[index]).hide(100));
          } else {
            _results.push($(museums[index]).show(100));
          }
        }
        return _results;
      });
      return $('.museum_navigation_menu .search_input .search_reset').click(function() {
        return $('.museum_navigation_menu .search_input input').val('').keyup();
      });
    };
    create_museums_search_array = function() {
      var museum, museums, _i, _len, _results;
      museums = $('ul.museum_list > li');
      _results = [];
      for (_i = 0, _len = museums.length; _i < _len; _i++) {
        museum = museums[_i];
        museum = $(museum);
        _results.push(museums_search_array.push("" + (museum.find('h4').text().trim().toLowerCase())));
      }
      return _results;
    };
    museum_list_prepare();
    create_museums_search_array();
    museum_search();
    $('.filter_opener').click(function(e) {
      var elem, filters_bar, nav;
      e.preventDefault();
      elem = $(this);
      filters_bar = $('.filters_bar');
      nav = $('.navigation');
      if (elem.hasClass('active')) {
        filters_bar.css({
          overflow: 'hidden'
        });
        filters_bar.animate({
          height: "0px"
        }, 200);
        elem.removeClass('active');
        if (nav.hasClass('navbar-fixed-top')) {
          return $('body').animate({
            'padding-top': '-=44px'
          }, 200);
        }
      } else {
        filters_bar.animate({
          height: "44px"
        }, 200, function() {
          return filters_bar.css({
            overflow: 'visible'
          });
        });
        if (nav.hasClass('navbar-fixed-top')) {
          $('body').animate({
            'padding-top': '+=44px'
          }, 200);
        }
        return elem.addClass('active');
      }
    });
    $('.menu_opener').click(function() {
      var elem, museum_nav, nav, padding;
      elem = $(this);
      museum_nav = $('.museum_navigation_menu');
      nav = $('.navigation');
      if (museum_nav.is(':visible')) {
        padding = elem.data('last-padding');
        museum_nav.slideUp(300);
        nav.addClass('navbar-fixed-top');
        return $('body').css({
          'padding-top': "" + padding
        });
      } else {
        padding = $('body').css('padding-top');
        elem.data('last-padding', padding);
        museum_nav.slideDown(300);
        nav.removeClass('navbar-fixed-top');
        return $('body').css({
          'padding-top': '0px'
        });
      }
    });
    $('ul.exhibits>li:not(#drop_down) .checkbox input').change(function() {
      var elem, parent;
      elem = $(this);
      parent = elem.parents('.opener');
      if (elem.is(':checked')) {
        return parent.addClass('border');
      } else {
        return parent.removeClass('border');
      }
    });
    $('.actions_bar input.search').focus(function() {
      var input, width;
      input = $(this);
      width = $('body').width() - 700;
      if (width > 150) {
        return input.animate({
          width: "" + width + "px"
        }, 300);
      }
    });
    $('.actions_bar input.search').blur(function() {
      var input;
      input = $(this);
      return input.animate({
        width: '150px'
      }, 300);
    });
    assign_click = function() {
      return $('ul.exhibits>li:not(#drop_down)>.opener .description, ul.exhibits>li:not(#drop_down)>.opener .overlay').unbind('click').bind('click', function(e) {
        var clicked, number, previous, slides;
        clicked = $(this).closest('li');
        if (clicked.hasClass('active')) {
          closeDropDown();
          return false;
        }
        previous = findActive();
        previous.removeClass('active');
        clicked.addClass('active');
        slides = $('<div>').addClass('slides').html("<img src=\"" + (clicked.data('big-image')) + "\">");
        slides.appendTo(dropDown.find('.images').html(''));
        dropDown.find('h2').text(clicked.find('h4').text());
        if (!isSameLine(clicked, previous)) {
          attachDropDown(clicked);
          $('body').scrollTo(clicked, 500, 150);
        }
        fields_behaviour();
        $("#jquery_jplayer_1").jPlayer({
          ready: function() {
            return $(this).jPlayer("setMedia", {
              m4a: "http://www.jplayer.org/audio/m4a/TSP-01-Cro_magnon_man.m4a",
              oga: "http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg"
            });
          },
          swfPath: "/js",
          wmode: "window",
          preload: "auto",
          smoothPlayBar: true,
          keyEnabled: true,
          supplied: "m4a, oga"
        });
        if (clicked.hasClass('dummy')) {
          number = clicked.data('number');
          $('#opas_number').val(number).blur();
          return $('#name').focus();
        }
      });
    };
    assign_click();
    modal_template = function(number) {
      return "<div class=\"modal fade\" id='dummyModal'>\n  <div class=\"modal-dialog\">\n    <div class=\"modal-content\">\n      <div class=\"modal-header\">\n        <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>\n        <h4 class=\"modal-title\">Name of exhibit is empty</h4>\n      </div>\n      <div class=\"modal-body row\">\n        <div class=\"pull-right\">\n          <button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Discard exhibit</button>\n          <button type=\"button\" class=\"btn btn-primary\" data-dismiss=\"modal\">Save as \"item_" + number + "\"</button>\n        </div>\n      </div>\n    </div>\n  </div>\n</div>";
    };
    new_template = function(number) {
      return "<li class=\"exhibit dummy\" data-big-image=/img/img-bg.png\" data-number='" + number + "'>\n  <div class=\"opener draft\">\n    <div class=\"overlay\"></div>\n    <div class=\"checkbox\">\n      <input type=\"checkbox\">\n    </div>\n    <div class=\"image\">\n      <img data-src=\"\" src=\"/img/img-bg.png\">\n    </div>\n    <div class=\"description\">\n      <h4>\n        " + number + ". item_" + number + "\n      </h4>\n    </div>\n    <div class=\"visibility\">\n      <i class=\"icon-globe placeholder\"></i>\n      <div class=\"on_hover\">\n        <div class=\"btn-group\">\n          <button class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\">\n            <div class=\"extra_right\">\n              <i class=\"icon-globe\"></i>\n            </div>\n            <span class=\"caret\"></span></button>\n          <ul class=\"dropdown-menu\" role=\"menu\">\n            <div class=\"status-select-dropdown\">\n              <form accept-charset=\"UTF-8\" action=\"/1/museums/1/exhibits/8\" class=\"simple_form status-select-inline\" data-remote=\"true\" id=\"edit_exhibit_8\" method=\"post\" novalidate=\"novalidate\">\n                <div style=\"margin:0;padding:0;display:inline\">\n                  <input name=\"utf8\" type=\"hidden\" value=\"✓\"><input name=\"_method\" type=\"hidden\" value=\"put\"><input name=\"authenticity_token\" type=\"hidden\" value=\"oE0Ns9ypDjsWQrc0VHdsAqhAgEz0Q8Lx8pJQlyqQaq0=\">\n                </div>\n                <div class=\"status-select control-group radio_buttons required\">\n                  <label class=\"radio_buttons required control-label\">\n                    <div class=\"required-symbol\">\n                      <abbr title=\"required\"></abbr>\n                    </div>\n                    Who can see it in mobile application</label>\n                  <div class=\"controls\">\n                    <div>\n                      <input checked=\"checked\" class=\"radio_buttons required radio\" data-status-text=\"Published\" id=\"exhibit_8_status_published\" name=\"exhibit[status]\" type=\"radio\" value=\"published\"><label class=\"radio\" for=\"exhibit_8_status_published\">\n                        <div class=\"label-content\">\n                          <i class=\"icon-globe\"></i> Everyone\n                        </div>\n                      </label>\n                    </div>\n                    <div>\n                      <input class=\"radio_buttons required radio\" data-status-text=\"Limited\" id=\"exhibit_8_status_limited\" name=\"exhibit[status]\" type=\"radio\" value=\"limited\"><label class=\"radio\" for=\"exhibit_8_status_limited\">\n                        <div class=\"label-content\">\n                          <i class=\"icon-user\"></i> Only users who have passcode\n                        </div>\n                      </label>\n                      <div class=\"limited-pass-hint hidden\">\n                        <div class=\"limited-pass\">\n                          pzicen\n                        </div>\n                        <a href=\"/1/content_provider/edit#passcode\" target=\"_blank\">Edit</a>\n                      </div>\n                    </div>\n                  </div>\n                </div>\n              </form>\n            </div>\n          </ul>\n        </div>\n      </div>\n    </div>\n  </div>\n</li>";
    };
    get_number = function() {
      return Math.round(Math.random() * 10 + 11);
    };
    return $('#create_new_item').click(function() {
      var exhibits, html, number;
      exhibits = $('ul.exhibits');
      if (exhibits.find('li.dummy').length > 0) {
        return false;
      }
      number = get_number();
      html = new_template(number);
      exhibits.append(html);
      assign_click();
      exhibits.find('li.dummy').find('.opener .description').click();
      dropDown.find('#name').blur(function() {
        var active, elem;
        elem = $(this);
        if (elem.val() !== '') {
          active = findActive();
          return active.removeClass('dummy').find('.opener').removeClass('draft');
        }
      });
      return false;
    });
  });

}).call(this);
