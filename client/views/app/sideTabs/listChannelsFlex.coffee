Template.listChannelsFlex.helpers
  channel: ->
    return Template.instance().channelsList?.get()

Template.listChannelsFlex.events
  'click header': ->
    SideNav.closeFlex()

  'click .channel-link': ->
    menu.close()
    rightMenu.close()
    clearActive()
    SideNav.closeFlex()
    $('.room-icons .icon-list').addClass('active')

  'click footer .create': ->
    SideNav.setFlex "createChannelFlex"

  'mouseenter header': ->
    SideNav.overArrow()

  'mouseleave header': ->
    SideNav.leaveArrow()

Template.listChannelsFlex.onCreated ->
  instance = this
  instance.channelsList = new ReactiveVar []

  Meteor.call 'channelsList', (err, result) ->
    if result
      instance.channelsList.set result.channels

clearActive = () ->
  $('.room-icons .icon-home').removeClass('active')
  $('.room-icons .icon-docs').removeClass('active')
  $('.room-icons .icon-calendar').removeClass('active')
  Session.set('isClassroom', false)
  Session.set('isCalendar', false)
  Session.set('isFiles', false)
  Session.set('isThread', false)
