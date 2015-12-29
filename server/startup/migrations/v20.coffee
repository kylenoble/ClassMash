Meteor.startup ->
  Migrations.add
    version: 20
    up: ->
      ChatMessage.update {}, {$set:{'topic':'general'}}, {multi: true}

      rooms = ChatRoom.find({t: 'c'}).fetch()
      rooms.map( (room) ->
        if not Topics.findOne({'title': 'general', 'classId': room._id})?
          Topics.insert
            'title': 'general'
            'classId': room._id
      )
