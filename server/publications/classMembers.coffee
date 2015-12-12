Meteor.publish 'classMembers', (rid) ->
  unless this.userId
    return this.ready()

  console.log '[publish] classMembers'.green, rid

  get_user = (user) -> return user.u._id
  users = ChatSubscription.find({rid: "TicnYN2rv9CxTo692"}, { _id: 0, u: 1}).map(get_user)

  query =
    $in: users

  options =
    fields:
      _id: 1
      username: 1
      name: 1
    sort:
      lastLogin: -1

  pub = this

  cursorHandle = Meteor.users.find(query, options).observeChanges
    added: (_id, record) ->
      pub.added('class-users', _id, record)

    changed: (_id, record) ->
      pub.changed('class-users', _id, record)

    removed: (_id, record) ->
      pub.removed('class-users', _id, record)

  @ready()
  @onStop ->
    cursorHandle.stop()
  return
