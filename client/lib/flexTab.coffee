@FlexTab = (->

  flexTab = {}
  flexTabNav = {}
  animating = false

  toggleCurrent = ->
    if flexTabNav.opened then closeFlex() else AccountBox.toggle()

  focusInput = ->
    setTimeout ->
      flexTab.find("input[type='text']:first")?.focus()
    , 200
    return

  validate = ->
    invalid = []
    flexTab.find("input.required").each ->
      if not this.value.length
        invalid.push $(this).prev("label").html()
    if invalid.length
      return invalid
    return false

  toggleFlex = (status = null, callback = null) ->
    return if animating == true
    animating = true
    if status is -1 or (status isnt 1 and flexTabNav.opened)
      flexTabNav.opened = false
      flexTabNav.addClass "hidden"
    else
      flexTabNav.opened = true
      # added a delay to make sure the template is already rendered before animating it
      setTimeout ->
        flexTabNav.removeClass "hidden"
      , 50
    setTimeout ->
      animating = false
      callback?()
    , 500

  openFlex = (callback = null) ->
    return if animating == true
    toggleFlex 1, callback
    focusInput()

  closeFlex = (callback = null) ->
    return if animating == true
    toggleFlex -1, callback

  flexStatus = ->
    return flexTabNav.opened

  setFlex = (template, data={}) ->
    Session.set "flex-nav-template", template
    Session.set "flex-nav-data", data

  getFlex = ->
    return {
      template: Session.get "flex-nav-template"
      data: Session.get "flex-nav-data"
    }

  init = ->
    flexTab = $(".flex-tab")
    flexTabNav = flexTab.find ".flex-nav"
    setFlex ""

  init: init
  setFlex: setFlex
  getFlex: getFlex
  openFlex: openFlex
  closeFlex: closeFlex
  validate: validate
  flexStatus: flexStatus
  toggleCurrent: toggleCurrent
)()
