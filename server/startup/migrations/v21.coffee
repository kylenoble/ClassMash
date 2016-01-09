Meteor.startup ->
  Migrations.add
    version: 21
    up: ->
      subs = ChatSubscription.find({t: 'c'}).fetch()
      subs.map( (sub) ->
        topics = Topics.find({'classId': sub.rid}).fetch()
        topObj = {}
        topics.map( (topic) ->
          key = topic.title
          topObj[key] = 0
        )

        ChatSubscription.update({_id: sub._id}, {$set: {topics: topObj}})
      )
