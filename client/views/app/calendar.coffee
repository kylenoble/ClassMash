Template.calendarPage.helpers
  addEventForm: ->
    console.log(Template.instance().showAddCalendarForm.get())
    return Template.instance().showAddCalendarForm.get()

  options: ->
    {
      id: 'myId2'
      class: 'classCalendar'
      fixedWeekCount: false
      height: $('.messages-container').height() - $('.room-icons').height() - 100
      header:
        left: ''
        center: 'title'
        right: 'month agendaWeek agendaDay prev,next'
      events: (start, end, timezone, callback) ->
        start = new Date(start)
        callback(Events.find({start: {$gt:start}}).fetch())
      eventClick: (calEvent, jsEvent, view) ->
        alert('Event: ' + calEvent.title)
        alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY)
        alert('View: ' + view.name)

        $(this).css('border-color', 'red')
    }

Template.calendarPage.events
  'click .refresh': (e, template) ->
    template.$('.classCalendar').fullCalendar 'refetchEvents'
    return

  'click .type-item': (e, template) ->
    console.log $(e.target)
    $('.type-item').removeClass('active')
    $(e.target).parent().addClass('active')

  'click .add-event-click': (e, template) ->
    title = $('#event-title').val()
    description = $('#event-description').val()
    start = new Date($('#start-date').val())
    end = new Date($('#end-date').val())
    eventType = $('.type-item.active').text().trim()

    console.log(title)
    console.log(description)
    console.log(start)
    console.log(end)

    Meteor.call "addEvent", Template.instance().rid.get(), title, description, start, end, (error, result) ->
      if error
        console.log "error", error
      if result
        console.log result

Template.calendarPage.rendered = ->
  $('.fc-toolbar .fc-right').prepend $('<button type="button" class="fc-button
  fc-state-default fc-corner-left fc-corner-right" data-toggle="modal"
  data-target="#eventModal">Add</button>')


  $('.fc-right .fc-button').addClass('line red-border')
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

    Template.instance().rid.set(RoomManager.openedRooms[typeLetter + path[2]].rid)

    Meteor.subscribe 'eventsList', Template.instance().rid.get()
    fc.fullCalendar 'refetchEvents'
    return

Template.calendarPage.onRendered ->
  @$('#datetimepicker1').datetimepicker(
    inline: true
  )
  @$('#datetimepicker2').datetimepicker(
    inline: true
  )
  @$('#datetimepicker1').data("DateTimePicker").toggle()
  @$('#datetimepicker2').data("DateTimePicker").toggle()
  return

Template.calendarPage.onCreated ->
  instance = @
  @showAddCalendarForm = new ReactiveVar false
  @rid = new ReactiveVar ''
  @calendarEvents = new ReactiveVar []
