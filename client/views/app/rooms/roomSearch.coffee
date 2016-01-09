Template.roomSearch.helpers
	roomIcon: ->
		return 'icon-at' if this.type is 'u'

		if this.type is 'r'
			switch this.t
				when 'd' then return 'icon-at'
				when 'c' then return 'icon-globe-alt'
				when 'p' then return 'icon-chemistry'

	userStatus: ->
		if this.type is 'u'
			return 'status-' + this.status
