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
        $('.room-icons .icon-calendar').removeClass('active')
        FlowRouter.go '/events/' + calEvent._id
    }

Template.calendarPage.events
  'click .refresh': (e, template) ->
    template.$('.classCalendar').fullCalendar 'refetchEvents'
    return

  'click .cancel-add-event': (e, template) ->
    clearPage()

  'click .type-item': (e, template) ->
    console.log $(e.target)
    $('.type-item').removeClass('active')
    $(e.target).parent().addClass('active')

  'click .add-event-click': (e, template) ->
    title = $('#event-title').val()
    description = $('#event-description').val()
    start = new Date($('#start-date').val())
    end = new Date($('#end-date').val())
    type = $('.type-item.active').text().trim()

    Meteor.call "addEvent", Template.instance().rid.get(), title, description, type, start, end, (error, result) ->
      if error
        console.log "error", error
      if result
        clearPage()
        console.log result

Template.calendarPage.rendered = ->
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
  $('.fc-toolbar .fc-right').prepend $('<button type="button" class="fc-button
  fc-state-default fc-corner-left fc-corner-right" data-toggle="modal"
  data-target="#eventModal">Add</button>')

  $('.fc-right .fc-button').addClass('line red-border')

  @$('#datetimepicker1').datetimepicker(
    inline: true
    focusOnShow: false
  )
  @$('#datetimepicker2').datetimepicker(
    inline: true
    focusOnShow: false
  )
  @$('#datetimepicker1').data("DateTimePicker").toggle()
  @$('#datetimepicker2').data("DateTimePicker").toggle()
  return

Template.calendarPage.onCreated ->
  instance = @
  @showAddCalendarForm = new ReactiveVar false
  @rid = new ReactiveVar ''
  @calendarEvents = new ReactiveVar []

clearPage = ->
  $('#event-title').val('')
  $('#event-description').val('')
  $('#start-date').val('')
  $('#end-date').val('')
  $('.type-item.active').removeClass('active')
