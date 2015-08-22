Meteor.methods
	createChannel: (name, members) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createChannel -> Invalid user"

		if not /^[0-9a-z-_]+$/i.test name
			throw new Meteor.Error 'name-invalid'

		user = Meteor.user()
		school = user.profile.school
		console.log '[methods] createChannel -> '.green, 'userId:', Meteor.userId(), 'schoolId:', school._id, 'arguments:', arguments

		now = new Date()
		members.push user.username

		# avoid duplicate names
		if ChatRoom.findOne({name:name, s: {_id:school._id}})
			console.log 'found duplicate class'
			throw new Meteor.Error 'duplicate-name'

		console.log 'no duplicate class'
		# name = s.slugify name

		room =
			usernames: members
			ts: now
			t: 'c'
			name: name
			msgs: 0
			s: 
				_id: school._id
				name: school.name
			u:
				_id: Meteor.userId()
				username: user.username

		RocketChat.callbacks.run 'beforeCreateChannel', user, room

		# create new room
		rid = ChatRoom.insert room

		for username in members
			member = Meteor.users.findOne({username: username})
			if not member?
				continue

			sub =
				rid: rid
				ts: now
				name: name
				t: 'c'
				unread: 0
				u:
					_id: member._id
					username: username

			if username is user.username
				sub.ls = now
				sub.open = true

			ChatSubscription.insert sub

		Meteor.defer ->

			RocketChat.callbacks.run 'afterCreateChannel', user, room

		return {
			rid: rid
		}
