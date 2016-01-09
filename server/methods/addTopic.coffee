Meteor.methods
  addTopic: (title, classId) ->
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] addTopic -> Invalid user"

    if not /^[0-9a-z-_]+$/.test title
      throw new Meteor.Error 'title-invalid'

    console.log '[methods] addTopic -> '.green, 'userId:', Meteor.userId(), 'classId:', classId, title

    # avoid duplicate titles
    if Topics.findOne( { title:title, 'classId': classId } )
      console.log 'found duplicate topic'
      throw new Meteor.Error 'duplicate-topic'

    key = 'topics.' + title
    obj = {}
    obj[key] = 0

    ChatSubscription.update({rid: classId, t: 'c'}, {$set: obj}, {multi: true})
    console.log 'no duplicate topic'

    Topics.insert title: title, classId: classId
