Meteor.methods
  # addEvent: (rid, title, description, type, allDay, start, end, url) ->
  #   unless Meteor.userId()
  #     return
  #
  #   now = new Date()
  #   me = Meteor.user()
  #
  #   eventId = Event.insert
  #     title: title
  #     description: description
  #     created: now
  #     allDay: allDay
  #     start: start
  #     end: end
  #     url: url
  #     className: 'calendarItem'
  #     editable: true
  #     startEditable: true
  #     durationEditable: true
  #     overlap: true
  #     color: color
  #     backgroundColor: backgroundColor
  #     borderColor: borderColor
  #     textColor: textColor
  #     r:
  #       _id: rid
  #     u:
  #       _id: me._id
  #       username: me.username
  #
  #   return {
  #     eventId: eventId
  #   }

  addEvent: (rid, title, description, type, start, end) ->
    unless Meteor.userId()
      return

    now = new Date()
    me = Meteor.user()

    switch
      when type == 'Lab' then backgroundColor = '#5DCA8B' and borderColor = '#5DCA8B'
      when type == 'Lecture' then backgroundColor = '#04436A' and borderColor = '#04436A'
      when type == 'Homework' then backgroundColor = '#546A76' and borderColor = '#546A76'
      when type == 'Paper' then backgroundColor = '#9BC4F2' and borderColor = '#9BC4F2'
      when type == 'Quiz/Test' then backgroundColor = '#F06475' and borderColor = '#F06475'

    eventId = Events.insert
      title: title
      description: description
      created: now
      start: start
      end: end
      type: type
      backgroundColor: backgroundColor
      borderColor: borderColor
      r:
        _id: rid
      u:
        _id: me._id
        username: me.username

    return {
      eventId: eventId
    }

  updateEvent: (eventId) ->
