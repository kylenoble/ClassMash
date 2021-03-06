Meteor.publish 'room', (typeName) ->
  unless this.userId
    return this.ready()

  console.log '[publish] room ->'.green, 'arguments:', arguments

  if typeof typeName isnt 'string'
    return this.ready()

  type = typeName.substr(0, 1)
  name = typeName.split('%')
  term = name[1]
  name = name[0].substr(1)

  user = Meteor.users.findOne this.userId, fields: username: 1, profile: 1

  query = {}

  if type in ['c', 'p']
    query =
      t: type
      name: name
      's._id': user.profile.school._id
      term: term

    if type is 'p'
      query.usernames = user.username
  else if type is 'd'
    query =
      t: 'd'
      's._id': user.profile.school._id
      usernames:
        $all: [user.username, name]
  else if type is 'f'
    query =
      t: 'f'
      's._id': user.profile.school._id
      'f._id': name
  else if type in ['a', 'q', 'o']
    query =
      t: type
      's._id': user.profile.school._id
      'ci._id': name
  # Change to validate access manualy
  # if not Meteor.call 'canAccessRoom', rid, this.userId
  #   return this.ready()

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
