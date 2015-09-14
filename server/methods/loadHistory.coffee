Meteor.methods
	loadHistory: (rid, end, limit=20, ls) ->
		fromId = Meteor.userId()
		# console.log '[methods] loadHistory -> '.green, 'fromId:', fromId, 'rid:', rid, 'end:', end, 'limit:', limit, 'skip:', skip

		unless Meteor.call 'canAccessRoom', rid, fromId
			return false

		query =
			_hidden: { $ne: true }
			rid: rid
			ts:
				$lt: end

		options =
			sort:
				ts: -1
			limit: limit

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { ets: 0 }

		messages = ChatMessage.find(query, options).fetch()
		unreadNotLoaded = 0

		if ls?
			firstMessage = messages[messages.length - 1]
			console.log(firstMessage)
			if firstMessage and firstMessage.ts > ls
				query.ts.$lt = firstMessage.ts
				query.ts.$gt = ls
				delete options.limit
				unreadNotLoaded = ChatMessage.find(query, options).count()
			else
				unreadNotLoaded = 0

		return {
			messages: messages
			unreadNotLoaded: unreadNotLoaded
		}
