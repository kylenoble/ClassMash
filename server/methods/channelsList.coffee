Meteor.methods
	channelsList: ->
		user = Meteor.user()
		school = user.profile.school
		return { channels: ChatRoom.find({ t: 'c', 's._id': school._id }, { sort: { msgs:-1 } }).fetch() }
