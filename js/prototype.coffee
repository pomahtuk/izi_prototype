# = require jquery.js
# = require bootstrap.js
# = require jquery.scrollTo.js
# = require jquery.jplayer.min.js

# = require_tree ./utils

# = require forms/modal.js
# = require forms/remote.js

# = require media-content/crop.js
# = require media-content/upload.js
# = require media-content/audio-player.js
# = require quiz.js
# = require stories.js
# = require story-sets.js

lastOfLine = (elem) ->
  elem = $(elem)
  top  = elem.offset().top
  pred = ->
    top < $(@).offset().top

  $.merge(elem, elem.nextUntil(pred)).last()


isSameLine = (x, y) ->
  x.length > 0 && y.length > 0 && x.offset().top == y.offset().top


getFullObject = (->
  xhr = null

  (url, handler) ->
    xhr.abort() if xhr

    xhr = $.getJSON(url, (json) -> handler(json))
)()

  ###########################################################################################
  ###########################################################################################
  ###########################################################################################

tileGrid = (collection, tileWidth, tileSpace, tileListMargin) ->
  windowWidth = $(window).innerWidth()
  tileRealWidth = tileWidth + tileSpace
  windowRealWidth = windowWidth - tileListMargin * 2 + tileSpace

  lineSize = Math.floor(windowRealWidth / tileRealWidth)
  diff = windowWidth - (lineSize * tileRealWidth - tileSpace)
  marginLeft = Math.floor(diff / 2)

  collection.css 'margin-right': 0, 'margin-left': tileSpace
  collection.each (i) ->
    return if i % lineSize != 0
    $(@).css 'margin-left': marginLeft

$ ->
  collection = $('.exhibits>li.exhibit')
  tileListMargin = 59
  tileWidth = collection.width()
  tileSpace = parseInt(collection.css('margin-left')) \
    + parseInt(collection.css('margin-right'))

  $('.exhibits').css 'text-align': 'left'
  tileGrid(collection, tileWidth, tileSpace, tileListMargin)
  $(window).resize(tileGrid.bind(@, collection, tileWidth, tileSpace, tileListMargin))
 

  ###########################################################################################
  ###########################################################################################
  ###########################################################################################

  $.fn.refresh = -> $(this.selector)
  $.fn.isEmpty = -> @length == 0

  dropDown   = $('#drop_down').removeClass('hidden').hide()#.remove()

  museums_search_array = []

  findActive = -> $('ul.exhibits li.exhibit.active')

  fillDropDown = (object) ->
    dropDown.find('p').html(object.description)

    if object.images.length > 1
      html = object.images.map((i) -> "<img src=\"#{i.big_url}\">").join('')
      dropDown.find('.slides').html(html).slidesjs slidesjs_options

  dummy_focusout_process = (active) ->
    if dropDown.find('#name').val() is ''
      remove = true
      for field in dropDown.find('#media .form-control:not(#opas_number)')
        field = $ field
        if field.val() isnt ''
          remove = false
      if remove
        active.remove()
      else
        number = active.data('number')
        $('ul.exhibits').append modal_template(number)
        $('#dummyModal').modal { show: true, backdrop: 'static' }
        $('#dummyModal').find('.btn-default').click ->
          active.remove()
          $('#dummyModal, .modal-backdrop').remove()
        $('#dummyModal').find('.btn-primary').click ->
          active.removeClass('dummy')
          dropDown.find('#name').val("item_#{number}")
          active.find('.opener').removeClass 'draft'
          $('#dummyModal, .modal-backdrop').remove()

  closeDropDown = ->
    active = findActive()
    if active.hasClass 'dummy'
      dummy_focusout_process(active)
    dropDown.hide()
    active.removeClass('active')

  attachDropDown = (li) ->
    hasParent = dropDown.hasClass 'inited'
    dropDown.show().insertAfter(lastOfLine(li))

    unless hasParent

      dropDown.addClass 'inited'

      dropDown.find('a.done, .close').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        closeDropDown()

      dropDown.find('>.prev-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        prev = active.prev('.exhibit')
        if prev.attr('id') == 'drop_down'
          prev = prev.prev()
        if prev.length > 0
          prev.find('.opener .description').click()
        else
          active.siblings('.exhibit').last().find('.opener').click()

      dropDown.find('>.next-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        next = active.next()
        if next.attr('id') == 'drop_down'
          next = next.next()
        if next.length > 0
          next.find('.opener .description').click()
        else
          active.siblings('.exhibit').first().find('.opener').click()

      dropDown.find('.label-content').unbind('click').bind 'click', (e) ->
        elem = $ @
        parent = elem.parents('.dropdown-menu').prev('.dropdown-toggle')
        if elem.hasClass 'everyone'
          parent.html "<div class='extra'><i class='icon-globe'></i></div> Published <span class='caret'></span>"
        else
          parent.html "<div class='extra'><i class='icon-user'></i></div> Publish <span class='caret'></span>"

      dropDown.find('#delete_story input[type=radio]').unbind('change').bind 'change', ->
        elem = $ @
        container = $('#delete_story')
        if elem.attr('id') is 'lang_selected'
          if elem.is(':checked')
            $('#delete_story .other_variants').slideDown(150)
        else
          $('#delete_story .other_variants').slideUp(150)

      $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind 'change', ->
        elem = $ @
        quiz = dropDown.find('.form-wrap')
        console.log elem.val()
        if elem.attr('id') is 'story_quiz_enabled'
          $('label[for=story_quiz_enabled]').text('Enabled')
          $('label[for=story_quiz_disabled]').text('Disable')
          #should someway publish model
          true
        else
          $('label[for=story_quiz_disabled]').text('Disabled')
          $('label[for=story_quiz_enabled]').text('Enable')
          #should someway unpublish model
          true

      dropDown.find('a.delete_story').unbind('click').bind 'click', (e) ->
        elem = $ @
        if elem.hasClass 'no_margin'
          e.preventDefault()
          e.stopPropagation()
          closeDropDown()

  $(window).resize ->
    findActive().each ->
      dropDown.hide()
      attachDropDown @
    museum_list_prepare()
    # fields_behaviour()

  hide_popovers = (target) ->
    $(".icon-question-sign").each ->
      $(this).popover "hide"  if not $(this).is(target) and $(this).has(target).length is 0 and $(".popover").has(target).length is 0

  fields_behaviour = ->
    $('.form-group').each (index, group) ->
      group = $ group
      text = group.find('.triggered > *').val()
      group.find('span.placeholder').text text
      group.find('.save_status').html('<i class="icon-ok-sign"></i>saved')
      if text is ''
        group.find('.trigger').hide()
        group.find('.triggered').show().focus()

    $('span.placeholder').unbind('click').bind 'click',  ->
      elem = $ @
      parent = elem.parents('.trigger')
      target = parent.next()
      parent.hide()
      target.show().children().first().val(elem.text()).focus()

    $('.triggered > *').unbind('blur').bind 'blur', ->
      elem = $ @
      parent = elem.parents('.triggered')
      target = parent.prev()
      if elem.val() isnt ''
        parent.hide()
        target.show().find('span').text elem.val()

      # code below - complet random and emulation      
      show_loader = Math.round(Math.random()) > 0
      timeout = 0
      timeout = 1000 if show_loader

      parent = target.parent('.form-group')

      parent.append "<div class='preloader'></div>" if show_loader

      setTimeout ->
        save_status = parent.find('.save_status')
        parent.find('.preloader').remove() if show_loader

        save_status.fadeIn(300)
        setTimeout ->
          save_status.fadeOut(300)
        , 800
      , timeout

    $('i.icon-question-sign').popover()

    $('.form-group').unbind('mouseenter').bind 'mouseenter', (e) ->
      hide_popovers(e.target)

    $("body").on "click", (e) ->
      hide_popovers(e.target)

    $('a.other_lang').unbind('click').bind 'click', ->
      elem = $ @
      elem.next('ul').toggleClass 'hidden'
      false

  museum_list_prepare = ->
    list  = $('ul.museum_list')
    count = list.find('li').length
    width = $('body').width()
    row_count = (count * 150 + 160) / width
    if row_count > 1
      $('.museum_filters').show()
      list.width(width-200)
    else
      $('.museum_filters').hide()
      list.width(width-100)

  museum_search = ->
    $('.museum_navigation_menu .search').click ->
      elem = $ @
      elem.hide()
      elem.next().show().children().first().focus()

    $('.museum_navigation_menu .search_input input').blur ->
      elem   = $ @
      parent = elem.parents('.search_input')
      elem.animate {width: '150px'}, 150,  ->
        parent.hide()
        parent.prev().show()

    $('.museum_navigation_menu .search_input input').focus ->
      input = $ @
      width = $('body').width() - 700
      if width > 150
        input.animate {width: "#{width}px"}, 300

    $('.museum_navigation_menu .search_input input').keyup ->
      input   = $ @
      value   = input.val().toLowerCase()
      museums = $('ul.museum_list > li')
      if value.length isnt 0
        $('.museum_filters a').removeClass 'active'
      else
        $('.museum_filters a').first().addClass 'active'
      # museums.show()
      for museum, index in museums_search_array
        if museum.indexOf(value) is -1
          $(museums[index]).hide(100)
        else
          $(museums[index]).show(100)

    $('.museum_navigation_menu .search_input .search_reset').click ->
      $('.museum_navigation_menu .search_input input').val('').keyup()

  museum_filters = ->
    $('.museum_filters a').click ->
      elem = $ @
      $('.museum_filters a').removeClass 'active'
      elem.addClass 'active'
      museums = $('ul.museum_list')
      if elem.hasClass 'type_tour'
        museums.find('>li:not(.tour)').hide()
        museums.find('>li.tour').show()
      else if elem.hasClass 'type_museum'
        museums.find(' li:not(.museum)').hide()
        museums.find('>li.museum').show()
      else
        museums.find('>li').show()


  create_museums_search_array = ->
    museums = $('ul.museum_list > li')
    for museum in museums
      museum = $ museum
      museums_search_array.push "#{museum.find('h4').text().trim().toLowerCase()}"

  museum_list_prepare()
  create_museums_search_array()
  museum_search()
  museum_filters()

  $('.filter_opener').click (e) ->
    e.preventDefault()
    elem = $ @
    filters_bar = $('.filters_bar')
    nav         = $('.navigation')
    if elem.hasClass 'active'
      filters_bar.css {overflow: 'hidden'}
      filters_bar.animate {height: "0px"}, 200  
      elem.removeClass 'active'
      if nav.hasClass 'navbar-fixed-top'
        $('body').animate {'padding-top': '-=44px'}, 200
    else
      filters_bar.animate {height: "44px"}, 200, ->
        filters_bar.css {overflow: 'visible'}
      if nav.hasClass 'navbar-fixed-top'
        $('body').animate {'padding-top': '+=44px'}, 200
      elem.addClass 'active'

  $('.menu_opener').click ->
    elem       = $ @
    museum_nav = $('.museum_navigation_menu')
    nav        = $('.navigation')

    if museum_nav.is(':visible')
      padding    = elem.data('last-padding')
      museum_nav.slideUp(300)
      nav.addClass 'navbar-fixed-top'
      $('body').css {'padding-top':"#{padding}"}
    else
      padding    = $('body').css('padding-top')
      elem.data('last-padding', padding)
      museum_nav.slideDown(300)
      nav.removeClass 'navbar-fixed-top'
      $('body').css {'padding-top':'0px'}

    # $('.museum_navigation_menu').slideToggle()

  $('ul.exhibits>li:not(#drop_down) .checkbox input').change ->
    elem   = $ @
    parent = elem.parents('.opener')
    if elem.is(':checked')
      parent.addClass 'border'
    else
      parent.removeClass 'border'

  $('.actions_bar input.search').focus ->
    input = $ @
    width = $('body').width() - 700
    if width > 150
      input.animate {width: "#{width}px"}, 300

  $('.actions_bar input.search').blur ->
    input = $ @
    input.animate {width: '150px'}, 300

  assign_click = ->
    $('ul.exhibits>li:not(#drop_down)>.opener .description, ul.exhibits>li:not(#drop_down)>.opener .overlay').unbind('click').bind 'click', (e) ->

      # closeDropDown()
      clicked = $(@).parents('li')
      if clicked.hasClass('active')
        closeDropDown()
        return false

      previous = findActive()

      if previous.hasClass 'dummy'
        dummy_focusout_process previous

      previous.removeClass('active')
      clicked.addClass('active')

      # slides = $('<div>').addClass('slides').html "<img src=\"#{clicked.data('big-image')}\">"

      # qr_link = clicked.data('qr-code')
      # $.ajax
      #   url: qr_link
      #   method: 'GET'
      #   dataType: 'html'
      # .done (data) ->
      #   qr_code = data
      #   dropDown.find('#qr_code').html qr_code

      # edit_link = clicked.data('edit-link')
      # $.ajax
      #   url: edit_link
      #   method: 'GET'
      #   dataType: 'html'
      # .done (data) ->
      #   media = data
      #   dropDown.find('#media').html media
      #   fields_behaviour()

      # $.ajax
      #   url: edit_link
      #   method: 'GET'
      #   data: {quiz: true}
      #   dataType: 'html'
      # .done (data) ->
      #   quiz = data
      #   dropDown.find('#quiz').html quiz
      #   fields_behaviour()

      # exhibit_link = clicked.data('exhibit-link')
      # $.ajax
      #   url: exhibit_link
      #   method: 'GET'
      #   data: {images: true}
      #   dataType: 'html'
      # .done (data) ->
      #   images = data
      #   dropDown.find('.images').html images
      #   # fields_behaviour()

      # slides.appendTo dropDown.find('.images').html('')
      dropDown.find('h2').text(clicked.find('h4').text())

      # if fullObject = clicked.data('full-object')
      #   fillDropDown fullObject
      # else
      #   dropDown.addClass('loading')
      #   dropDown.find('p').html('')
      #   getFullObject clicked.data('full-object-path'), (fullObject) ->
      #     dropDown.removeClass('loading')
      #     clicked.data('full-object', fullObject)
      #     fillDropDown fullObject

      unless isSameLine(clicked, previous)
        attachDropDown clicked
        $('body').scrollTo(clicked, 500, 150)
     
      fields_behaviour()

      $("#jquery_jplayer_1").jPlayer
        ready: ->
          $(this).jPlayer "setMedia",
            m4a:"http://www.jplayer.org/audio/m4a/TSP-01-Cro_magnon_man.m4a"
            oga:"http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg"
        swfPath: "/js"
        wmode: "window"
        preload: "auto"
        smoothPlayBar: true
        keyEnabled: true
        supplied: "m4a, oga"

      item_publish_settings = dropDown.find('.item_publish_settings')
      done = dropDown.find('.done')
      close = dropDown.find('.close')
      delete_story = dropDown.find('.delete_story')

      if clicked.hasClass 'dummy'
        number = clicked.data('number')
        $('#opas_number').val(number).blur()
        $('#name').focus()
        item_publish_settings.hide()
        done.hide()
        close.show()
        delete_story.addClass('no_margin')
      else
        item_publish_settings.show()
        done.show()
        close.hide()
        delete_story.removeClass('no_margin')

  assign_click()

  ###########################################################################################
  ## New item click functions
  ###########################################################################################

  modal_template = (number) ->
    """
      <div class="modal fade" id='dummyModal'>
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
              <h4 class="modal-title">Name of exhibit is empty</h4>
            </div>
            <div class="modal-body row">
              <div class="pull-right">
                <button type="button" class="btn btn-default" data-dismiss="modal">Discard exhibit</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal">Save as "item_#{number}"</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    """

  new_template = (number) ->
    """
      <li class="exhibit dummy" data-big-image=/img/img-bg.png" data-number='#{number}'>
        <div class="opener draft">
          <div class="overlay"></div>
          <div class="checkbox">
            <input type="checkbox">
          </div>
          <div class="image">
            <img data-src="" src="/img/img-bg.png">
          </div>
          <div class="description">
            <h4>
              #{number}. item_#{number}
            </h4>
          </div>
          <div class="visibility">
            <i class="icon-globe placeholder"></i>
            <div class="on_hover">
              <div class="btn-group">
                <button class="btn btn-default dropdown-toggle" data-toggle="dropdown" type="button">
                  <div class="extra_right">
                    <i class="icon-globe"></i>
                  </div>
                  <span class="caret"></span></button>
                <ul class="dropdown-menu" role="menu">
                  <div class="status-select-dropdown">
                    <form accept-charset="UTF-8" action="/1/museums/1/exhibits/8" class="simple_form status-select-inline" data-remote="true" id="edit_exhibit_8" method="post" novalidate="novalidate">
                      <div style="margin:0;padding:0;display:inline">
                        <input name="utf8" type="hidden" value="✓"><input name="_method" type="hidden" value="put"><input name="authenticity_token" type="hidden" value="oE0Ns9ypDjsWQrc0VHdsAqhAgEz0Q8Lx8pJQlyqQaq0=">
                      </div>
                      <div class="status-select control-group radio_buttons required">
                        <label class="radio_buttons required control-label">
                          <div class="required-symbol">
                            <abbr title="required"></abbr>
                          </div>
                          Who can see it in mobile application</label>
                        <div class="controls">
                          <div>
                            <input checked="checked" class="radio_buttons required radio" data-status-text="Published" id="exhibit_8_status_published" name="exhibit[status]" type="radio" value="published"><label class="radio" for="exhibit_8_status_published">
                              <div class="label-content">
                                <i class="icon-globe"></i> Everyone
                              </div>
                            </label>
                          </div>
                          <div>
                            <input class="radio_buttons required radio" data-status-text="Limited" id="exhibit_8_status_limited" name="exhibit[status]" type="radio" value="limited"><label class="radio" for="exhibit_8_status_limited">
                              <div class="label-content">
                                <i class="icon-user"></i> Only users who have passcode
                              </div>
                            </label>
                            <div class="limited-pass-hint hidden">
                              <div class="limited-pass">
                                pzicen
                              </div>
                              <a href="/1/content_provider/edit#passcode" target="_blank">Edit</a>
                            </div>
                          </div>
                        </div>
                      </div>
                    </form>
                  </div>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </li>
    """
  get_number = ->
    Math.round Math.random() * 10 + 11

  $('#create_new_item').click ->
    exhibits =  $('ul.exhibits')
    return false if exhibits.find('li.dummy').length > 0

    number = get_number()

    dummy_item = $ new_template(number)
    exhibits.append dummy_item

    assign_click()

    collection = $('.exhibits>li.exhibit')
    tileGrid(collection, tileWidth, tileSpace, tileListMargin)

    exhibits.find('li.dummy').find('.opener .description').click()
    dropDown.find('#name').blur ->
      elem = $ @
      if elem.val() isnt ''
        active = findActive()
        active.removeClass('dummy').find('.opener').removeClass 'draft'
        dropDown.find('.item_publish_settings').show()
        dropDown.find('.done').show()
        dropDown.find('.close').hide()
        dropDown.find('.delete_story').removeClass('no_margin')
    false

  ##########################################################################################
  ## story-sets.js.coffee
  ##########################################################################################
  storySetImage = $('a.thumb')

  $('#images, #maps').find('li.new').on 'click', 'a.upload-image, a.upload-map', (e) ->
    e.preventDefault()
    $this = $ this
    $parent = $this.parents('#images, #maps')

    if $parent.find('li:hidden').isEmpty()
      $.ajax
        url: $this.attr('href')
        async: false
        success: (response) ->
          node = $(response).hide()
          $parent.find('li.new').before node
          initFileUpload e, node.find('.fileupload'), { progress: $this.find('.progress') }
    $parent.find('li:hidden :file').trigger 'click'

  $('#images, #maps').on 'click', 'a.remove', (e) ->
    e.preventDefault()
    e.stopPropagation()
    $this = $ this
    $parent = $this.parents('#images, #maps')

    if confirm($this.data('confirm'))
      $.ajax
        url: $this.attr('href')
        type: $this.data('method')
        data:
          authentity_token: $('meta[name=csrf-token]').attr('content')
        success: ->
          fadeTime = 200
          if $parent.attr('id').match(/images/)
            $this.parents('li').fadeOut fadeTime, ->
              $(this).remove()
              storySetImage.trigger 'image:deleted'
          else
            $this.parents('li').fadeOut fadeTime, ->
              $(this).remove()

  $('#images, #maps').find('>ul[data-liftable]').each ->
    $container = $ this
    $parent = $container.parents('#images, #maps')
    sendSortRequest = ->
      formData = $container.sortable 'serialize'
      formData += "&" + $('meta[name=csrf-param]').attr("content") +
                  "=" + encodeURIComponent($('meta[name=csrf-token]').attr("content"))
      $.ajax
        type: 'post'
        data: formData
        dataType: 'script'
        url: $container.data('sort-url')
        success: ->
          if $parent.attr('id').match(/images/)
            storySetImage.trigger 'image:moved'
    $container.disableSelection().sortable
      axis: 'xy'
      cursor: 'move'
      update: sendSortRequest
      items: 'li[id]'

  storySetImage.on 'click', (e) ->
    e.preventDefault()
    $('div.tab-pane#images').each ->
      $('div.tab-pane, ul.nav-pills li').removeClass('active')
      $(this).addClass('active')
      imagesTab.parent('li').addClass('active')

  reloadMainImage = ->
    $.ajax
      url: storySetImage.data('reload-url')
      type: 'get'
      success: (response) ->
        thumb = response.thumb || storySetImage.data('default-url')
        thumb += '?_=' + new Date().getTime() if response.thumb
        title = imagesTab.text().replace(/\d+/, response.count)
        storySetImage.find('img').attr('src', thumb)
        imagesTab.text title

  updateDisplayedAndHidden = ->
    itemSelector = 'li:not(.new)'

    imagesList = $('.images-list')
    displayedImages = imagesList.find('.images-displayed')
    maxDisplayed = displayedImages.data('max-displayed')
    displayedNow = displayedImages.find(itemSelector).length
    hiddenImages = imagesList.find('.images-hidden')
    getHiddenNow = -> hiddenImages.find(itemSelector).length
    hiddenHeaders = imagesList.find('.hidden-header')

    if displayedNow > maxDisplayed
      displayedImages.find("#{itemSelector}:last").prependTo(hiddenImages)
    else if displayedNow < maxDisplayed and getHiddenNow() > 0
      hiddenImages.find("#{itemSelector}:first").appendTo(displayedImages)

    hiddenHeaders.toggleClass('hidden', getHiddenNow() is 0)

  processImageChanges = ->
    reloadMainImage()
    updateDisplayedAndHidden()

  storySetImage.on 'image:uploaded', processImageChanges
  storySetImage.on 'image:cropped', reloadMainImage
  storySetImage.on 'image:deleted', processImageChanges
  storySetImage.on 'image:moved', processImageChanges