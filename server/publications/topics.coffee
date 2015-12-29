Meteor.publish 'topics', (classId)->
  unless this.userId
    return this.ready()

  console.log '[publish] topics'.green

  Topics.find {classId: classId},
    fields:
      _id: 1
      title: 1
      classId: 1
