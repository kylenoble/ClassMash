Template.flexTab.helpers
	isAdmin: ->
		return Meteor.user()?.admin is true
	flexTemplate: ->
		return FlexTab.getFlex().template
	flexData: ->
		return FlexTab.getFlex().data
	footer: ->
		return RocketChat.settings.get 'Layout_Sidenav_Footer'

Template.flexTab.events
	'click .close-flex': ->
		FlexTab.closeFlex()

	'click .arrow': ->
		FlexTab.toggleCurrent()

	'mouseenter .header': ->
		FlexTab.overArrow()

	'mouseleave .header': ->
		FlexTab.leaveArrow()

Template.flexTab.onRendered ->
	FlexTab.init()
	rightMenu.init()
