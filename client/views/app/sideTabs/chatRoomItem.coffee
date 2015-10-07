Template.chatRoomItem.helpers

  alert: ->
    if FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()
      return this.alert

  unread: ->
    if (FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()) and this.unread > 0
      return this.unread

  isDirectRoom: ->
    return this.t is 'd'

  userStatus: ->
    return 'status-' + (Session.get('user_' + this.name + '_status') or 'offline') if this.t is 'd'
    return ''

  name: ->
    return this.name

  roomIcon: ->
    switch this.t
      when 'd' then return 'icon-bubbles'
      when 'c' then return 'icon-globe-alt'
      when 'p' then return 'icon-lock'

  active: ->
    if Session.get('openedRoom') is this.rid
      return 'active'

  canLeave: ->
    roomData = Session.get('roomData' + this.rid)

    return false unless roomData

    if (roomData.cl? and not roomData.cl) or roomData.t is 'd' or (roomData.usernames?.indexOf(Meteor.user().username) isnt -1 and roomData.usernames?.length is 1)
      return false
    else
      return true

  route: ->
    return switch this.t
      when 'd'
        FlowRouter.path('direct', {username: this.name})
      when 'p'
        FlowRouter.path('group', {name: this.name})
      when 'c'
        FlowRouter.path('channel', {name: this.name, term: this.term})

Template.chatRoomItem.rendered = ->
  if not (FlowRouter.getParam('_id')? and FlowRouter.getParam('_id') is this.data.rid) and not this.data.ls
    KonchatNotification.newRoom(this.data.rid)

Template.chatRoomItem.events

  'click .open-room': (e) ->
    menu.close()
    rightMenu.close()
    if e.currentTarget.baseURI is window.location.href
      console.log("returning")
      return
    clearActive()
    $('.room-icons .icon-list').addClass('active')

  'click .hide-room': (e) ->
    e.stopPropagation()
    e.preventDefault()

    if FlowRouter.getRouteName() in ['channel', 'group', 'direct'] and Session.get('openedRoom') is this.rid
      FlowRouter.go 'home'

    Meteor.call 'hideRoom', this.rid

  'click .leave-room': (e) ->
    e.stopPropagation()
    e.preventDefault()

    if FlowRouter.getRouteName() in ['channel', 'group', 'direct'] and Session.get('openedRoom') is this.rid
      FlowRouter.go 'home'

    path = window.location.pathname.split('/')
    if path[1] is 'group'
      typeLetter = 'p'
    else
      typeLetter = path[1][0]

    roomType = typeLetter + path[2]
    term = path[3]

    RoomManager.close roomType, term

    Meteor.call 'leaveRoom', this.rid

clearActive = () ->
  $('.room-icons .icon-home').removeClass('active')
  $('.room-icons .icon-docs').removeClass('active')
  $('.room-icons .icon-calendar').removeClass('active')
  Session.set('isClassroom', false)
  Session.set('isCalendar', false)
  Session.set('isFiles', false)
  if Session.get('isThread')
    Session.set('isThread', false)
