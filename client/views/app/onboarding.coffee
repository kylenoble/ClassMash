Template.onboarding.helpers
  sidebar: ->
    console.log Template.instance().isTouch.get()
    if Template.instance().isTouch.get()
      return "Press the globe to open the side bar. The sidebar is a how you access classes and private groups. Press General to try it out!"
    return "The sidebar is how you access classes and private groups. Click General to try it out!"

  details: ->
    if Template.instance().isTouch.get()
      return "Manage files, add calendar items and view classroom information by pressing the tab bar icons"
    return "Manage files, add calendar items and view classroom information by clicking these icons."

  directMessages: ->
    if Template.instance().isTouch.get()
      return "View and chat with classmates by pressing the chat icon to the right."
    return "View and chat with classmates by clicking the chat icon to the right."

  chatEntry: ->
    if Template.instance().isTouch.get()
      return "Enter text, links, and resources in addition to uploading files."
    return "Enter text, links, and resources in addition to uploading files below."

Template.onboarding.onCreated ->
  this.isTouch = new ReactiveVar ''
  if $( window ).width() < 780
    this.isTouch.set(true)
  else
    this.isTouch.set(false)

Template.onboarding.onRendered ->
  if $('.cd-tour-wrapper').length > 0
    initTour()

initTour = ->
  tourWrapper = $('.cd-tour-wrapper')
  tourSteps = tourWrapper.children('li')
  stepsNumber = tourSteps.length
  coverLayer = $('.cd-cover-layer')
  tourStepInfo = $('.cd-more-info')
  tourTrigger = $('#cd-tour-trigger')
  #create the navigation for each step of the tour
  createNavigation tourSteps, stepsNumber
  tourTrigger.on 'click', ->
    #start tour
    $('.cd-nugget-info').hide()
    if !tourWrapper.hasClass('active')
      #in that case, the tour has not been started yet
      tourWrapper.addClass 'active'
      showStep tourSteps.eq(0), coverLayer
    return
  #change visible step
  tourStepInfo.on 'click', '.cd-prev', (event) ->
    #go to prev step - if available
    !$(event.target).hasClass('inactive') and changeStep(tourSteps, coverLayer, 'prev')
    return
  tourStepInfo.on 'click', '.cd-next', (event) ->
    #go to next step - if available
    !$(event.target).hasClass('inactive') and changeStep(tourSteps, coverLayer, 'next')
    return
  #close tour
  tourStepInfo.on 'click', '.cd-close', (event) ->
    closeTour tourSteps, tourWrapper, coverLayer
    return
  #detect swipe event on mobile - change visible step
  tourStepInfo.on 'swiperight', (event) ->
    #go to prev step - if available
    if !$(this).find('.cd-prev').hasClass('inactive') and viewportSize() == 'mobile'
      changeStep tourSteps, coverLayer, 'prev'
    return
  tourStepInfo.on 'swipeleft', (event) ->
    #go to next step - if available
    if !$(this).find('.cd-next').hasClass('inactive') and viewportSize() == 'mobile'
      changeStep tourSteps, coverLayer, 'next'
    return
  #keyboard navigation
  $(document).keyup (event) ->
    if event.which == '37' and !tourSteps.filter('.is-selected').find('.cd-prev').hasClass('inactive')
      changeStep tourSteps, coverLayer, 'prev'
    else if event.which == '39' and !tourSteps.filter('.is-selected').find('.cd-next').hasClass('inactive')
      changeStep tourSteps, coverLayer, 'next'
    else if event.which == '27'
      closeTour tourSteps, tourWrapper, coverLayer
    return
  return

createNavigation = (steps, n) ->
  tourNavigationHtml = '<div class="cd-nav"><span><b class="cd-actual-step">1</b> of ' + n + '</span><ul class="cd-tour-nav"><li><a href="" class="cd-prev">&#171; Previous</a></li><li><a href="" class="cd-next">Next &#187;</a></li></ul></div><a href="" class="cd-close">Close</a>'
  steps.each (index) ->
    step = $(this)
    stepNumber = index + 1
    nextClass = if stepNumber < n then '' else 'inactive'
    prevClass = if stepNumber == 1 then 'inactive' else ''
    nav = $(tourNavigationHtml).find('.cd-next').addClass(nextClass).end().find('.cd-prev').addClass(prevClass).end().find('.cd-actual-step').html(stepNumber).end().appendTo(step.children('.cd-more-info'))
    return
  return

showStep = (step, layer) ->
  step.addClass('is-selected').removeClass 'move-left'
  smoothScroll step.children('.cd-more-info')
  showLayer layer
  return

smoothScroll = (element) ->
  element.offset().top < $(window).scrollTop() and $('body,html').animate({ 'scrollTop': element.offset().top }, 100)
  element.offset().top + element.height() > $(window).scrollTop() + $(window).height() and $('body,html').animate({ 'scrollTop': element.offset().top + element.height() - $(window).height() }, 100)
  return

showLayer = (layer) ->
  layer.addClass('is-visible').on 'webkitAnimationEnd oanimationend msAnimationEnd animationend', ->
    layer.removeClass 'is-visible'
    return
  return

changeStep = (steps, layer, bool) ->
  visibleStep = steps.filter('.is-selected')
  delay = if viewportSize() == 'desktop' then 300 else 0
  visibleStep.removeClass 'is-selected'
  bool == 'next' and visibleStep.addClass('move-left')
  setTimeout (->
    if bool == 'next' then showStep(visibleStep.next(), layer) else showStep(visibleStep.prev(), layer)
    return
  ), delay
  return

closeTour = (steps, wrapper, layer) ->
  steps.removeClass 'is-selected move-left'
  wrapper.removeClass 'active'
  layer.removeClass 'is-visible'
  return

viewportSize = ->
  ### retrieve the content value of .cd-main::before to check the actua mq ###
  window.getComputedStyle(document.querySelector('.cd-tour-wrapper'), '::before').getPropertyValue('content').replace(/"/g, '').replace /'/g, ''
