@FlexTab = (->

	flexTab = {}
	flexTabNav = {}
	arrow = {}
	animating = false

	toggleArrow = (status = null) ->
		if status is -1 or (status isnt 1 and arrow.hasClass "top")
			arrow.removeClass "top"
			arrow.addClass "bottom"
		else
			arrow.addClass "top"
			arrow.removeClass "bottom"

	toggleCurrent = ->
		if flexTabNav.opened then closeFlex() else AccountBox.toggle()

	overArrow = ->
		arrow.addClass "hover"

	leaveArrow = ->
		arrow.removeClass "hover"

	arrowBindHover = ->
		arrow.on "mouseenter", ->
			flexTab.find("header").addClass "hover"
		arrow.on "mouseout", ->
			flexTab.find("header").removeClass "hover"

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
		return false;

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
		toggleArrow 1
		toggleFlex 1, callback
		focusInput()

	closeFlex = (callback = null) ->
		return if animating == true
		toggleArrow -1
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
		arrow = flexTab.children ".arrow"
		setFlex ""
		arrowBindHover()

	init: init
	setFlex: setFlex
	getFlex: getFlex
	openFlex: openFlex
	closeFlex: closeFlex
	validate: validate
	flexStatus: flexStatus
	toggleArrow: toggleArrow
	toggleCurrent: toggleCurrent
	overArrow: overArrow
	leaveArrow: leaveArrow
)()
