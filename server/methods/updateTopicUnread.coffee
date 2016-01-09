Meteor.methods
  updateTopicUnread: (topic, classId) ->
    if not Meteor.userId()
      throw new Meteor.Error('invalid-user', "[methods] updateMessage -> Invalid user")

    key = 'topics.' + topic
    obj = {}
    obj[key] = 0

    console.log '[methods] updateTopicUnread -> '.green, 'userId:', Meteor.userId(), 'topic:', topic

    ChatSubscription.update({"rid": classId, 'u._id': Meteor.userId()}, {$set: obj})
