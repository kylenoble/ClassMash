Meteor.methods
  createEventRoom: (eventName, eventId, parentRoomId) ->
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] createEventRoom -> Invalid user"

    console.log '[methods] createEventRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

    eventName = eventName.split(" ").join("-")
    eventName = eventName.replace(/[^\w\s-_]/gi, '')

    if not /^[0-9a-z-_]+$/.test eventName
      throw new Meteor.Error 'name-invalid'

    now = new Date()

    me = Meteor.user()

    # members.push me.username

    # name = s.slugify name

    school = me.profile.school
    parentRoom = ChatRoom.findOne({_id: parentRoomId, 's._id': school._id})
    # avoid duplicate names
    if ChatRoom.findOne({'e._id':eventId, 's._id': school._id})
      throw new Meteor.Error 'duplicate-file-room'

    # create new room
    rid = ChatRoom.insert
      usernames: []
      term: 'all'
      ts: now
      t: 'e'
      e:
        _id: eventId
      s:
        _id: school._id
        name: school.name
      u:
        _id: me._id
        username: me.username
      p:
        _id: parentRoomId
        term: parentRoom.term
        name: parentRoom.name
        t: parentRoom.t
      name: eventName
      msgs: 0

    return {
      rid: rid
    }
