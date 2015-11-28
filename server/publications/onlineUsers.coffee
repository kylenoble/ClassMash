Meteor.publish 'onlineUsers', (name) ->
  unless this.userId
    return this.ready()

  console.log '[publish] onlineUsers'.green, name

  exp = new RegExp(name, 'i')
  user = Meteor.users.findOne @userId

  unless user.profile.school
    return this.ready()

  school = user.profile.school

  query =
    'profile.school._id': school._id
    username:
      $exists: 1

    $or: [
      {name: exp}
      {username: exp}
    ]

  options =
    fields:
      username: 1
      name: 1
      status: 1
      utcOffset: 1
      profile: 1
    sort:
      lastLogin: -1
    limit: 5

  pub = this

  cursorHandle = Meteor.users.find(query, options).observeChanges
    added: (_id, record) ->
      pub.added('online-users', _id, record)

    changed: (_id, record) ->
      pub.changed('online-users', _id, record)

    removed: (_id, record) ->
      pub.removed('online-users', _id, record)

  @ready()
  @onStop ->
    cursorHandle.stop()
  return
