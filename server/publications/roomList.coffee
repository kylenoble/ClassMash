Meteor.publish 'roomList', (type) ->
  unless this.userId
    return this.ready()

  console.log '[publish] room list ->'.green, 'arguments:', arguments

  if typeof type isnt 'string'
    return this.ready()

  user = Meteor.users.findOne this.userId, fields: username: 1, profile: 1

  query = {}

  if type in ['c', 'p']
    query =
      t: type
      's._id': user.profile.school._id

    if type is 'p'
      query.usernames = user.username
  else if type is 'd'
    query =
      t: 'd'
      's._id': user.profile.school._id
      usernames:
        $all: [user.username]
  else if type is 'f'
    query =
      t: 'f'
      's._id': user.profile.school._id
  else if type in ['a', 'q', 'o']
    query =
      t: type
      's._id': user.profile.school._id
  # Change to validate access manualy
  # if not Meteor.call 'canAccessRoom', rid, this.userId
  #   return this.ready()
  console.log('room method query')
  console.log query

  ChatRoom.find query,
    fields:
      name: 1
      t: 1
      u: 1
      s: 1
      f: 1
      ci: 1
      p: 1
      msgs: 1
      usernames: 1
      term: 1
      teacher: 1
      teacherEmail: 1
      syllabus: 1
