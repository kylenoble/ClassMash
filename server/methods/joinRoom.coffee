Meteor.methods
  joinRoom: (rid) ->

    room = ChatRoom.findOne rid

    if room.t != 'c' and room.t != 'f' and room.t != 'a' and room.t != 'o' and room.t != 'q'
      throw new Meteor.Error 403, '[methods] joinRoom -> Not allowed'

    # verify if user is already in room
    # if room.usernames.indexOf(user.username) is -1
    console.log '[methods] joinRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

    now = new Date()

    user = Meteor.users.findOne Meteor.userId()

    RocketChat.callbacks.run 'beforeJoinRoom', user, room

    update =
      $addToSet:
        usernames: user.username

    ChatRoom.update rid, update

    fields =
      rid: rid
      ts: now
      name: room.name
      t: room.t
      open: true
      alert: true
      term: room.term
      unread: 1
      u:
        _id: user._id
        username: user.username

    if room.t is 'c'
      fields["topics"] = {}
      topics = Topics.find({classId: rid}).fetch()
      topics.map( (topic) ->
        key = topic.title
        fields["topics"][key] = 0
      )

    ChatSubscription.insert fields

    ChatMessage.insert
      rid: rid
      ts: now
      t: 'uj'
      msg: user.name
      topic: 'general'
      u:
        _id: user._id
        username: user.username

    Meteor.defer ->

      RocketChat.callbacks.run 'afterJoinRoom', user, room

    return true
