Meteor.publish 'calendarItems', (rid) ->
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

  query = { "r._id": rid }

  console.log(query)

  console.log '[publish] calendar events'.green, rid

  return CalendarItems.find query,
    fields: fields
    sort: { start: -1 }
