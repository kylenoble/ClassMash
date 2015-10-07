openRoom = (type, name, term) ->
  Session.set 'openedRoom', null
  console.log("open room firing")
  BlazeLayout.render 'main', {center: 'loading'}

  Meteor.defer ->
    Tracker.autorun (c) ->
      if RoomManager.open(type + name).ready() isnt true
        return

      c.stop()

      user = Meteor.users.findOne Meteor.userId(), fields: username: 1, profile: 1

      if term != ''
        query =
          t: type
          name: name
          term: term
          's._id': user.profile.school._id
      else
        query =
          t: type
          name: name
          's._id': user.profile.school._id

      if type is 'd'
        delete query.name
        query.usernames =
          $all: [name, Meteor.user().username]

      room = ChatRoom.findOne(query)
      if not room?
        Session.set 'roomNotFound', {type: type, name: name}
        BlazeLayout.render 'main', {center: 'roomNotFound'}
        return

      mainNode = document.querySelector('.main-content')
      if mainNode?
        for child in mainNode.children
          mainNode.removeChild child if child?
        roomDom = RoomManager.getDomOfRoom(type + name, room._id)
        mainNode.appendChild roomDom
        if roomDom.classList.contains('room-container')
          if roomDom.classList.contains('.messages-box.wrapper')
            roomDom.querySelector('.messages-box > .wrapper').scrollTop = roomDom.oldScrollTop

      Session.set 'openedRoom', room._id
      Session.set 'isThread', true

      Session.set 'editRoomTitle', false
      RoomManager.updateMentionsMarksOfRoom type + name
      Meteor.setTimeout ->
        readMessage.readNow()
      , 2000
      # KonchatNotification.removeRoomNotification(params._id)

      if Meteor.Device.isDesktop()
        setTimeout ->
          $('.message-form .input-message').focus()
        , 100


roomExit = ->
  mainNode = document.querySelector('.main-content')
  if mainNode?
    for child in mainNode.children
      if child?
        if child.classList.contains('room-container')
          if Session.get('isThread')
            wrapper = child.querySelector('.messages-box > .wrapper')
            if wrapper and wrapper.scrollTop >= wrapper.scrollHeight - wrapper.clientHeight
              child.oldScrollTop = 10e10
            else if wrapper
              child.oldScrollTop = wrapper.scrollTop
        mainNode.removeChild child


FlowRouter.route '/class/:name/:term',
  name: 'channel'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'c', params.name, params.term

  triggersExit: [roomExit]


FlowRouter.route '/group/:name',
  name: 'group'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'p', params.name, ''

  triggersExit: [roomExit]


FlowRouter.route '/direct/:username',
  name: 'direct'

  action: (params, queryParams) ->
    Session.set 'showUserInfo', params.username
    openRoom 'd', params.username, ''

  triggersExit: [roomExit]
