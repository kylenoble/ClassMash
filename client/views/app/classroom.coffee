Template.classroomPage.helpers
	teacher: ->
		return Template.instance().room.teacher

	teacherLabel: ->
		if Template.instance().school.isHighSchool
			return "Teacher"

		return "Professor"

	teacherEmail: ->
		if Template.instance().room.teacherEmail
			return Template.instance().room.teacherEmail
		else
			return "<a href=''>Add Teacher Email</a>"

	syllabus: ->
		if Template.instance().room.syllabus
			return Template.instance().room.teacherEmail
		else
			return "<button class='add-syllabus button white blue-border'>Add</button>"

	term: ->
		return Template.instance().room.term

	classMembers: ->
		students = Template.instance().room.usernames
		length = students.length - 1
		console.log students
		console.log length
		if length + 1 > Template.instance().membersLimit
			return students.slice(length - Template.instance().membersLimit, length)
		else
			return students

Template.classroomPage.events


Template.classroomPage.created = ->
	path = window.location.pathname.split('/')
	if path[1] is 'group'
		typeLetter = 'p'
	else
		typeLetter = path[1][0]

	term = path[3]
	roomId = RoomManager.openedRooms[typeLetter + path[2]].rid

	console.log(term)
	console.log(RoomManager.openedRooms)
	this.room = ChatRoom.findOne(roomId, term: term )

	this.school = Schools.find().fetch()
	this.membersLimit = new ReactiveVar 3
