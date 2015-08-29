@fileCollection = new Mongo.Collection 'rocketchat_uploads'

fileCollection.allow
	insert: (userId, doc) ->
		return userId

	update: (userId, doc) ->
		return userId is doc.userId

	remove: (userId, doc) ->
		return userId is doc.userId
