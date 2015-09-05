Meteor.publish 'schools', ->
	unless this.userId
		return this.ready()

	console.log '[publish] schoolData'.green

	user = Meteor.users.findOne(_id: this.userId)
	schoolId = user.profile.school._id
	oid = new Meteor.Collection.ObjectID(schoolId)

	Schools.find oid,
		fields:
			name: 1
			phone: 1
			address: 1
			city: 1
			state: 1
			zip: 1
			url: 1
			isHighSchool: 1
			isCollege: 1
			pos: 1
