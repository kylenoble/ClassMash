Template.myCalendarItem.events
  "click .open-section": (event, template) ->
    rightMenu.close()
    clearActive()

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
