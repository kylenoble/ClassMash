Meteor.publish 'fileDetails', (id) ->
  unless @userId
    return @ready()

  fields =
    name: 1
    type: 1
    date: 1
    category: 1
    url: 1
    user: 1
    room: 1

  roomId = ChatRoom.find({t: 'f', 'f._id': id}).fetch()
  console.log(roomId)

  query = { $or: [ { 'r._id': roomId }, { _id: id } ] }

  console.log '[publish] file details data'.green, id

  return fileCollection.find query,
    fields: fields
