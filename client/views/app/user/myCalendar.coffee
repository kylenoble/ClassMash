Template.myCalendar.helpers
  addEventForm: ->
    console.log(Template.instance().showAddCalendarForm.get())
    return Template.instance().showAddCalendarForm.get()

  classSubs: ->
    return ChatSubscription.find({t: {$in: ['c']}}).fetch()

  groupSubs: ->
    return ChatSubscription.find({t: {$in: ['p']}}).fetch()

  options: ->
    {
      id: 'myCal2'
      class: 'myCalendar'
      fixedWeekCount: false
      height: $(window).height() - 100
      header:
        left: ''
        center: 'title'
        right: 'month agendaWeek agendaDay prev,next'
      events: (start, end, timezone, callback) ->
        start = new Date(start)
        callback(CalendarItems.find({start: {$gt:start}}).fetch())
      eventClick: (calEvent, jsEvent, view) ->
        clearActive()
        if calEvent.type is 'Homework' or calEvent.type is 'Paper'
          FlowRouter.go '/assignment/' + calEvent._id
        else if calEvent.type is 'Quiz/Test'
          FlowRouter.go '/quiz-test/' + calEvent._id
        else
          FlowRouter.go '/calendar-item/' + calEvent._id
    }

Template.myCalendar.events
  'click .refresh': (e, template) ->
    template.$('.myCalendar').fullCalendar 'refetchEvents'
    return

  'click .cancel-add-event': (e, template) ->
    clearPage()

  'click .type-item': (e, template) ->
    $('.type-item').removeClass('active')
    $(e.target).parent().addClass('active')

  'click .add-event-click': (e, template) ->
    title = $('#event-title').val()
    description = $('#event-description').val()
    start = new Date($('#start-date').val())
    end = new Date($('#end-date').val())
    type = $('.type-item.active').text().trim()
    room = $('#class-group option:selected').val()

    if title is ''
      toastr.error 'Please Enter a Title'
      return
    else if description is ''
      toastr.error 'Please Enter a Description'
      return
    else if start is ''
      toastr.error 'Please Enter a Start Date'
      return
    else if end is ''
      toastr.error 'Please Enter an End Date'
      return
    else if type is ''
      toastr.error 'Please Select a Type'
      return
    else if room is 'initial-select-val'
      toastr.error 'Please Select a Class or Group'
      return

    Meteor.call "addCalendarItem", room, title, description, type, start, end, (error, result) ->
      if error
        console.log "error", error
      if result
        clearPage()
        console.log result

Template.myCalendar.rendered = ->
  $('.bootstrap-datetimepicker-widget').hide()
  instance = @
  fc = @$('.fc')
  @autorun ->
    #1) trigger event re-rendering when the collection is changed in any way
    #2) find all, because we've already subscribed to a specific range

    Template.instance().rid.set('')

    Meteor.subscribe 'myCalendarItems'
    Meteor.subscribe 'subscription'
    fc.fullCalendar 'refetchEvents'
    return

Template.myCalendar.onRendered ->
  $('.rooms-list ul').children().removeClass('active')

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

Template.myCalendar.onCreated ->
  instance = @
  @showAddCalendarForm = new ReactiveVar false
  @rid = new ReactiveVar ''
  @height = new ReactiveVar $('.main-content').height() - 100
  @calendarEvents = new ReactiveVar []

clearPage = ->
  $('#event-title').val('')
  $('#event-description').val('')
  $('#start-date').val('')
  $('#end-date').val('')
  $('.type-item.active').removeClass('active')

clearActive = () ->
  if Session.get('isClassroom')
    Session.set('isClassroom', false)
    $('.room-icons .icon-home').removeClass('active')
  if Session.get('isCalendar')
    Session.set('isCalendar', false)
    $('.room-icons .icon-calendar').removeClass('active')
  if Session.get('isFiles')
    Session.set('isFiles', false)
    $('.room-icons .icon-docs').removeClass('active')
  if Session.get('isThread')
    Session.set('isThread', false)
    $('.room-icons .icon-list').removeClass('active')
  if Session.get('isProfile')
    Session.set('isProfile', false)
    $('.room-icons .icon-user').removeClass('active')
  if Session.get('isFileDetails')
    Session.set('isFileDetails', false)
    $('.room-icons .icon-doc').removeClass('active')
  if Session.get('isEventDetails')
    Session.set('isEventDetails', false)
    $('.room-icons .icon-notebook').removeClass('active')
  if Session.get('isAssignments')
    Session.set('isAssignments', false)
    $('.room-icons .icon-book-open').removeClass('active')
  if Session.get('isFileHistory')
    Session.set('isFileHistory', false)
    $('.room-icons .icon-graph').removeClass('active')
  if Session.get('isSearch')
    Session.set('isSearch', false)
