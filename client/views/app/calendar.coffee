Template.calendarPage.helpers
  addEventForm: ->
    console.log(Template.instance().showAddCalendarForm.get())
    return Template.instance().showAddCalendarForm.get()

  options: ->
    {
      id: 'myId2'
      class: 'classCalendar'
      fixedWeekCount: false
      aspectRatio: 1.5
      events: (start, end, timezone, callback) ->
        start = new Date(start)
        callback(Events.find({start: {$gt:start}}).fetch())
      customButtons:
        addEvent:
          text: 'Add'
          click: ->
            alert 'hello'
            return
      header:
        left: 'title'
        center: 'addEvent'
        right: 'month agendaWeek agendaDay prev,next'
    }

Template.calendarPage.events
  'click .refresh': (e, template) ->
    template.$('.classCalendar').fullCalendar 'refetchEvents'
    return

  'click .add-event-click': (e, template) ->
    title = $('#event-title').val()
    description = $('#event-description').val()
    start = new Date($('#start-date').val())
    end = new Date($('#end-date').val())

    console.log(title)
    console.log(description)
    console.log(start)
    console.log(end)

    Meteor.call "addEvent", Template.instance().rid.get(), title, description,
      start, end, (error, result) ->
      if error
        console.log "error", error
      if result
        console.log result

Template.calendarPage.rendered = ->
  $('.fc-right .fc-button').addClass('button white red-border')
  $('.bootstrap-datetimepicker-widget').hide()
  instance = @
  fc = @$('.fc')
  @autorun ->
    #1) trigger event re-rendering when the collection is changed in any way
    #2) find all, because we've already subscribed to a specific range
    path = window.location.pathname.split('/')
    if path[1] is 'group'
      typeLetter = 'p'
    else
      typeLetter = path[1][0]

    Template.instance().rid
    .set(RoomManager.openedRooms[typeLetter + path[2]].rid)

    Meteor.subscribe 'eventsList', Template.instance().rid.get()
    fc.fullCalendar 'refetchEvents'
    return

Template.calendarPage.onRendered ->
  @$('.datetimepicker').datetimepicker(
    inline: true
  )
  @$('.datetimepicker').data("DateTimePicker").toggle()
  return

Template.calendarPage.onCreated ->
  instance = @
  @showAddCalendarForm = new ReactiveVar false
  @rid = new ReactiveVar ''
  @calendarEvents = new ReactiveVar []
