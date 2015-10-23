Template.eventDetailsPage.helpers
  event: ->
    path = window.location.pathname.split('/')
    eventId = path[2]
    event = Events.find(_id: eventId)
    return event

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  icon: (type) ->
    console.log(type)
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

Template.eventDetailsPage.events


Template.eventDetailsPage.events
  "click #foo": (event, template) ->

Template.eventDetailsPage.onCreated ->
  path = window.location.pathname.split('/')

  instance = @
  @eventId = new ReactiveVar path[2]
  @ready = new ReactiveVar true

  @autorun ->
    eventId = instance.eventId.get()
    fileDetails = Meteor.subscribe 'eventDetails', eventId
    instance.ready.set fileDetails.ready()
