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

  addEvent: (rid, title, description, start, end) ->
    unless Meteor.userId()
      return

    now = new Date()
    me = Meteor.user()

    eventId = Events.insert
      title: title
      description: description
      created: now
      start: start
      end: end
      r:
        _id: rid
      u:
        _id: me._id
        username: me.username

    return {
      eventId: eventId
    }

  updateEvent: (eventId) ->
