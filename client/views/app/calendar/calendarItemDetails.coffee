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
    console.log('clicking edit')
    Template.instance().editingItem.set(true)
    editingFields()

  "click .cancel": (e, template) ->
    Template.instance().editingItem.set(false)
    normalFields()
    resetFields()

  "click .save": (e, template) ->
    title = $('.editing-title').text()
    startDate =  $('.editing-start-date').text()
    endDate = $('.editing-end-date').text()
    description = $('.editing-description').text()
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
      title, startDate, endDate, description, (error, result) ->
        if error
          console.log "error", error
          return
      Template.instance().editingItem.set(false)
      normalFields()

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

editingFields = ->
  $('.editing-title').addClass('now-editing')
  $('.editing-start-date').addClass('now-editing')
  $('.editing-end-date').addClass('now-editing')
  $('.editing-description').addClass('now-editing')

normalFields = ->
  $('.editing-title').removeClass('now-editing')
  $('.editing-start-date').removeClass('now-editing')
  $('.editing-end-date').removeClass('now-editing')
  $('.editing-description').removeClass('now-editing')

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

resetFields = ->
  calItem = Template.instance().item.get()
  $('.editing-title').text(calItem.title)
  $('.editing-start-date').text(calItem.startDate)
  $('.editing-end-date').text(calItem.endDate)
  $('.editing-description').text(calItem.description)
