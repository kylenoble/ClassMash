Template.assignmentsList.helpers
  addEventForm: ->
    return Template.instance().showAddCalendarForm.get()

  assignments: ->
    return CalendarItems.find({type: {$in: ['Paper', 'Homework', 'Quiz/Test']}}).fetch()

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  unread: (id) ->
    room = ChatRoom.find({"t": "f", "f._id": id}).fetch()
    if room[0]
      return room[0].msgs
    return false

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

Template.assignmentsList.events
  'click .refresh': (e, template) ->
    template.$('.classCalendar').fullCalendar 'refetchEvents'
    return

  'click .icon-bubble': (e, template) ->
    $('.room-icons .icon-calendar').removeClass('active')
    type = $(this)[0].type
    id = $(this)[0]._id

    clearActive()

    if type is 'Homework' or type is 'Paper'
      FlowRouter.go '/assignment/' + id
    else if type is 'Quiz/Test'
      FlowRouter.go '/quiz-test/' + id
    else
      FlowRouter.go '/calendar-item/' + id

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

    Meteor.call "addCalendarItem", Template.instance().rid.get(), title, description, type, start, end, (error, result) ->
      if error
        console.log "error", error
      if result
        clearPage()
        console.log result

Template.assignmentsList.rendered = ->
  instance = @
  fc = @$('.fc')
  @autorun ->
    #1) trigger event re-rendering when the collection is changed in any way
    #2) find all, because we've already subscribed to a specific range
    path = window.location.pathname.split('/')
    if path[1] is 'group'
      typeLetter = 'p'
    else if path[1] is 'files'
      typeLetter = 'f'
    else if path[1] is 'calendar-item'
      typeLetter = 'o'
    else if path[1] is 'quiz-test'
      typeLetter = 'q'
    else if path[1] is 'assignment'
      typeLetter = 'a'
    else
      typeLetter = path[1][0]

    if path[3]
      term = path[3]
    else if typeLetter in ['p','d']
      term = 'all'
    else
      term = ''

    Template.instance().rid.set(RoomManager.openedRooms[typeLetter + path[2] + '%' + term].rid)

    Meteor.subscribe 'calendarItems', Template.instance().rid.get()
    return

Template.assignmentsList.onRendered ->
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

Template.assignmentsList.onCreated ->
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
