openRoom = (type, name, term, id) ->
  Session.set 'openedRoom', null
  console.log("open room firing")
  BlazeLayout.render 'main', {center: 'loading'}

  Meteor.defer ->
    Tracker.autorun (c) ->
      if type in ['f', 'a', 'q', 'o']
        name = id

      if RoomManager.open(type + name + '%' + term).ready() isnt true
        return

      c.stop()

      user = Meteor.users.findOne Meteor.userId(), fields: username: 1, profile: 1

      if term != ''
        query =
          t: type
          name: name
          term: term
          's._id': user.profile.school._id
      else if type is 'f'
        query =
          t: type
          's._id': user.profile.school._id
          'f._id': id
      else if type is 'a'
        query =
          t: type
          's._id': user.profile.school._id
          'ci._id': id
      else if type is 'q'
        query =
          t: type
          's._id': user.profile.school._id
          'ci._id': id
      else if type is 'o'
        query =
          t: type
          's._id': user.profile.school._id
          'ci._id': id
      else
        query =
          t: type
          name: name
          's._id': user.profile.school._id

      if type is 'd'
        delete query.name
        query.usernames =
          $all: [name, Meteor.user().username]

      console.log query
      room = ChatRoom.findOne(query)
      console.log room
      if not room?
        Session.set 'roomNotFound', {type: type, name: name}
        BlazeLayout.render 'main', {center: 'roomNotFound'}
        return

      mainNode = document.querySelector('.main-content')
      if mainNode?
        for child in mainNode.children
          mainNode.removeChild child if child?
        roomDom = RoomManager.getDomOfRoom(type + name + '%' + term, room._id)
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

      # if Meteor.Device.isDesktop()
      #   setTimeout ->
      #     $('.message-form .input-message').focus()
      #   , 100


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
    openRoom 'c', params.name, params.term, ''

  triggersExit: [roomExit]


FlowRouter.route '/group/:name',
  name: 'group'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'p', params.name, '', ''

  triggersExit: [roomExit]


FlowRouter.route '/direct/:username',
  name: 'direct'

  action: (params, queryParams) ->
    Session.set 'showUserInfo', params.username
    openRoom 'd', params.username, '', ''

  triggersExit: [roomExit]


FlowRouter.route '/files/:id',
  name: 'files'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'f', '', '', params.id

  triggersExit: [roomExit]


FlowRouter.route '/calendar-item/:id',
  name: 'calendar-item'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'o', '', '', params.id

FlowRouter.route '/assignment/:id',
  name: 'assignment'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'a', '', '', params.id

FlowRouter.route '/quiz-test/:id',
  name: 'quiz-test'

  action: (params, queryParams) ->
    Session.set 'showUserInfo'
    openRoom 'q', '', '', params.id

  triggersExit: [roomExit]
