Meteor.publish 'calendarItemDetails', (id) ->
  unless @userId
    return @ready()

  fields =
    title: 1
    description: 1
    created: 1
    start: 1
    end: 1
    type: 1
    backgroundColor: 1
    borderColor: 1
    r: 1
    u: 1

  query = { _id: id }

  console.log '[publish] calendar calendarItems'.green, id

  return CalendarItems.find query,
    fields: fields
