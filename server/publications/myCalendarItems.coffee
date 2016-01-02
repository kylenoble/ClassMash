Meteor.publish 'myCalendarItems', ->
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

  subs = ChatSubscription.find({'u._id': @userId}).fetch()
  subs = subs.map((sub)-> return sub.rid)

  query = { $or: [ { 'r._id': { $in: subs } }, { 'u._id': @userId } ] }

  console.log '[publish] calendar events'.green, query

  return CalendarItems.find query,
    fields: fields
    sort: { date: 1 }
