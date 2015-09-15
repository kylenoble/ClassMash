Meteor.methods
	addSyllabus: (name, url, id) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] updateMessage -> Invalid user")

		ChatRoom.update
			_id: id
		,
			$set: syllabus: {
        name: name
        url: url
      }

	addTeacherEmail: (email, id) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] updateMessage -> Invalid user")

		ChatRoom.update
			_id: id
		,
			$set: teacherEmail: email
