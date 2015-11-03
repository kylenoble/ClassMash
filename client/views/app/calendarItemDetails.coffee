Template.calendarItemDetailsPage.helpers
  calendarItem: ->
    path = window.location.pathname.split('/')
    calendarItemId = path[2]
    calendarItem = CalendarItems.find(_id: calendarItemId)
    return calendarItem

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  icon: (type) ->
    if type is "Lab"
      return "icon-chemistry"
    else if type is "Lecture"
      return "icon-notebook"
    else if type is "Homework"
      return "icon-home"
    else if type is "Paper"
      return "icon-note"
    else if type is "Quiz/Test"
      return "icon-hourglass"

Template.calendarItemDetailsPage.events
  "click #foo": (calendarItem, template) ->

Template.calendarItemDetailsPage.onCreated ->
  path = window.location.pathname.split('/')

  instance = @
  @calendarItemId = new ReactiveVar path[2]
  @ready = new ReactiveVar true

  @autorun ->
    calendarItemId = instance.calendarItemId.get()
    fileDetails = Meteor.subscribe 'calendarItemDetails', calendarItemId
    instance.ready.set fileDetails.ready()
