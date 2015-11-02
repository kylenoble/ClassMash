Meteor.startup ->
  Migrations.add
    version: 19
    up: ->
      users = Meteor.users.find().fetch()
      users.map( (user)->
        generalRoom = ChatRoom.find({'name': 'general', 's._id': user.profile.school._id})
        if not ChatSubscription.findOne({'u._id': user._id, 'name': 'general'})?
          ChatSubscription.insert
            rid: generalRoom._id
            ts: new Date()
            name: generalRoom.name
            t: generalRoom.t
            open: true
            alert: true
            term: generalRoom.term
            unread: 1
            u:
              _id: user._id
              username: user.username

          ChatMessage.insert
            rid: generalRoom._id
            ts: new Date()
            t: 'au'
            msg: user.name
            u:
              _id: user._id
              username: user.username
      )
