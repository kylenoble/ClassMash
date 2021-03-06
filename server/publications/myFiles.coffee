Meteor.publish 'myFiles', (limit, rid) ->
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

  query = { "user._id": @userId }

  console.log '[publish] file uploads'.green, limit, rid

  return fileCollection.find query,
    fields: fields
    limit: limit
    sort: { date: -1 }
