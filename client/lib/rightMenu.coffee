@rightMenu = new class
	init: ->
		@container = $("#rocket-chat")

	isOpen: ->
		return @container?.hasClass("right-menu-opened") is true

	open: ->
		if not @isOpen()
			@container?.removeClass("right-menu-closed").addClass("right-menu-opened")

	close: ->
		if @isOpen()
			@container?.removeClass("right-menu-opened").addClass("right-menu-closed")

	toggle: ->
		if @isOpen()
			@close()
		else
			@open()
