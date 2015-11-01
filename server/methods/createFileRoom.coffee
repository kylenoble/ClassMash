Meteor.methods
  createFileRoom: (fileName, fileId, parentRoomId) ->
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] createFileRoom -> Invalid user"

    console.log '[methods] createFileRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

    fileName = fileName.split(" ").join("-")
    fileName = fileName.split(".").join("-")
    fileName = fileName.replace(/[^\w\s-_]/gi, '')
    console.log fileName
    if not /^[0-9a-z-_]+$/.test fileName
      throw new Meteor.Error 'name-invalid'

    now = new Date()

    me = Meteor.user()

    # members.push me.username

    # name = s.slugify name
    school = me.profile.school

    parentRoom = ChatRoom.findOne({_id: parentRoomId, 's._id': school._id})
    # avoid duplicate names
    if ChatRoom.findOne({'f._id':fileId, 's._id': school._id})
      throw new Meteor.Error 'duplicate-file-room'

    # create new room
    rid = ChatRoom.insert
      usernames: []
      term: 'all'
      ts: now
      t: 'f'
      f:
        _id: fileId
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
      name: fileName
      msgs: 0

    return {
      rid: rid
    }
