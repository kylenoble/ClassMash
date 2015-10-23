Meteor.publish 'eventDetails', (id) ->
  unless @userId
    return @ready()

  fields =
    title: 1
    description: 1
    allDay: 1
    start: 1
    end: 1
    url: 1
    className: 1
    type: 1
    editable: 1
    startEditable: 1
    durationEditable: 1
    overlap: 1
    color: 1
    backgroundColor: 1
    borderColor: 1
    textColor: 1
    r: 1
    u: 1

  query = { _id: id }

  console.log '[publish] calendar events'.green, id

  return Events.find query,
    fields: fields
