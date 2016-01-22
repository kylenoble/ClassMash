Template.calendarItemDetailsPage.helpers
  calendarItem: ->
    path = window.location.pathname.split('/')
    calendarItemId = path[2]
    calItem = CalendarItems.findOne(_id: calendarItemId)
    Template.instance().item.set(calItem)
    Template.instance().itemId.set(calendarItemId)
    return calItem

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  currentUser: (username) ->
    user = Meteor.user()
    if user.username is username
      return true
    return false

  editing: ->
    return Template.instance().editingItem.get()

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
  "click .edit": (e, template) ->
    Template.instance().editingItem.set(true)
    $('#event-title').val($('.editing-title').text())
    $('#start-date').val($('.editing-start-date').text())
    $('#end-date').val($('.editing-end-date').text())
    $('#event-description').val($('.editing-description').text())
    _.each($('.type-item').children(), (item) ->
      console.log $(item).text()
      console.log $('.editing-type').text()
      console.log $(item).text().trim() == $('.editing-type').text().trim()
      if $(item).text().trim() == $('.editing-type').text().trim()
        console.log 'matched'
        $(item).parent().addClass('active')
        return
    )

  'click .type-item': (e, template) ->
    console.log $(e.target)
    $('.type-item').removeClass('active')
    $(e.target).parent().addClass('active')


  "click .update-event-click": (e, template) ->
    title = $('#event-title').val()
    description = $('#event-description').val()
    startDate = new Date($('#start-date').val())
    endDate = new Date($('#end-date').val())
    type = $('.type-item.active').text().trim()
    errors = validateFields([
      {title: 'Title', 'val': title},
      {title: 'Start Date', 'val': startDate},
      {title: 'End Date', 'val': endDate},
      {title: 'Description', 'val': description}
    ])
    timeErrors = checkDate([
      {title: 'Start Date', 'val': startDate},
      {title: 'End Date', 'val': endDate},
    ])
    errors = errors.concat(timeErrors)
    if errors.length > 1
      _.each errors, ((error) ->
        toastr.error(error.field + " " + error.error)
      )
      return
    else
      Meteor.call "updateCalendarItem", Template.instance().itemId.get(),
      title, startDate, endDate, description, type, (error, result) ->
        if error
          console.log "error", error
          return
      Template.instance().editingItem.set(false)

Template.calendarItemDetailsPage.onRendered ->
  properties = {
    calendarItemId: Template.instance().calendarItemId.get()
  }
  amplitude.logEvent("CALENDAR_DETAILS_RENDERED", properties)

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

Template.calendarItemDetailsPage.onCreated ->
  path = window.location.pathname.split('/')

  instance = @
  @calendarItemId = new ReactiveVar path[2]
  @editingItem = new ReactiveVar false
  @itemId = new ReactiveVar ''
  @item = new ReactiveVar {}
  @ready = new ReactiveVar true

  @autorun ->
    calendarItemId = instance.calendarItemId.get()
    fileDetails = Meteor.subscribe 'calendarItemDetails', calendarItemId
    instance.ready.set fileDetails.ready()

checkDate = (fields) ->
  errors = []
  _.each fields, ((field) ->
    date = moment(field.val)
    if String(date._d) is 'Invalid Date'
      errors.push({'field': field.title, 'error': "Must Be a Date"})
  )
  return errors

validateFields = (fields) ->
  errors = []
  _.each fields, ((field) ->
    if field.val is ''
      errors.push({'field': field.title, 'error': "Can't Be Empty"})
  )
  return errors
