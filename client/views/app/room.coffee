# @TODO bug com o botão para "rolar até o fim" (novas mensagens) quando há uma mensagem com texto que gere rolagem horizontal
Template.room.helpers
  tAddUsers: ->
    return t('Add_users')

  tQuickSearch: ->
    return t('Quick_Search')

  searchResult: ->
    return Template.instance().searchResult.get()

  # favorite: ->
  #   sub = ChatSubscription.findOne { rid: this._id }, { fields: { f: 1 } }
  #   return 'icon-star favorite-room' if sub?.f? and sub.f
  #   return 'icon-star'

  roomName: ->
    roomData = Session.get('roomData' + this._id)
    return '' unless roomData

    if roomData.t is 'd'
      return ChatSubscription.findOne({ rid: this._id }, { fields: { name: 1 } })?.name
    else
      return roomData.name

  roomId: ->
    return this._id

  roomIcon: ->
    roomData = Session.get('roomData' + this._id)
    return '' unless roomData?.t

    if roomData._id == 'GENERAL'
      return 'icon-graduation'

    switch roomData.t
      when 'd' then return 'icon-bubbles'
      when 'c' then return 'icon-globe-alt'
      when 'p' then return 'icon-chemistry'

  # userProfile: ->
  #   console.log(Session.get('showUserProfile'))
  #   return Session.get('showUserProfile')

  flexUserInfo: ->
    roomData = Session.get('roomData' + this._id)
    if roomData.s
      school = roomData.s._id
    else
      user = Meteor.users.findOne(Meteor.userId())
      school = user.profile.school._id
    username = Session.get('showUserInfo')
    user = Meteor.users.findOne({ username: String(username), "profile.school._id": school })
    if user
      return user

  userStatus: ->
    roomData = Session.get('roomData' + this._id)

    return {} unless roomData

    if roomData.t is 'd'
      username = _.without roomData.usernames, Meteor.user().username
      return Session.get('user_' + username + '_status') || 'offline'

    else
      return 'offline'

  autocompleteSettingsAddUser: ->
    return {
      limit: 10
      # inputDelay: 300
      rules: [
        {
          collection: 'UserAndRoom'
          subscription: 'roomSearch'
          field: 'name'
          template: Template.roomSearch
          noMatchTemplate: Template.roomSearchEmpty
          matchAll: true
          filter: { type: 'u', uid: { $ne: Meteor.userId() } }
          sort: 'name'
        }
      ]
    }

  autocompleteSettingsRoomSearch: ->
    return {
      limit: 10
      # inputDelay: 300
      rules: [
        {
          collection: 'UserAndRoom'
          subscription: 'roomSearch'
          field: 'name'
          template: Template.roomSearch
          noMatchTemplate: Template.roomSearchEmpty
          matchAll: true
          filter: { uid: { $ne: Meteor.userId() } }
          sort: 'name'
        }
      ]
    }

  isChannel: ->
    roomData = Session.get('roomData' + this._id)
    return '' unless roomData
    return roomData.t is 'c'

  canAddUser: ->
    roomData = Session.get('roomData' + this._id)
    return '' unless roomData
    return roomData.t in ['p', 'c'] and roomData.u?._id is Meteor.userId()

  canEditName: ->
    roomData = Session.get('roomData' + this._id)
    return '' unless roomData
    return roomData.u?._id is Meteor.userId() and roomData.t in ['c', 'p']

  canDirectMessage: ->
    return Meteor.user()?.username isnt this.username

  roomNameEdit: ->
    return Session.get('roomData' + this._id)?.name

  editingTitle: ->
    return 'hidden' if Session.get('editRoomTitle')

  showEditingTitle: ->
    return 'hidden' if not Session.get('editRoomTitle')

  flexOpened: ->
    return 'opened' if Session.equals('flexOpened', true)

  arrowPosition: ->
    return 'left' unless Session.equals('flexOpened', true)

  isGroupChat: ->
    room = ChatRoom.findOne(this._id, { reactive: false })
    return room?.t in ['c', 'p']

  userActiveByUsername: (username) ->
    status = Session.get 'user_' + username + '_status'
    if status in ['online', 'away', 'busy']
      return {username: username, status: status}
    return

  roomUsers: ->
    room = ChatRoom.findOne(this._id, { reactive: false })
    users = []
    onlineUsers = RoomManager.onlineUsers.get()

    for username in room?.usernames or []
      if onlineUsers[username]?
        utcOffset = onlineUsers[username]?.utcOffset
        if utcOffset?
          if utcOffset > 0
            utcOffset = "+#{utcOffset}"

          utcOffset = "(UTC #{utcOffset})"

        users.push
          username: username
          status: onlineUsers[username]?.status
          utcOffset: utcOffset

    users = _.sortBy users, 'username'

    ret =
      _id: this._id
      total: room?.usernames?.length or 0
      totalOnline: users.length
      users: users

    return ret

  remoteVideoUrl: ->
    return Session.get('remoteVideoUrl')

  selfVideoUrl: ->
    return Session.get('selfVideoUrl')

  videoActive: ->
    return (Session.get('remoteVideoUrl') || Session.get('selfVideoUrl'))

  remoteMonitoring: ->
    return (webrtc?.stackid? && (webrtc.stackid == 'webrtc-ib'))

  flexOpenedRTC1: ->
    return 'layout1' if Session.equals('flexOpenedRTC1', true)

  flexOpenedRTC2: ->
    return 'layout2' if Session.equals('flexOpenedRTC2', true)

  rtcLayout1: ->
    return (Session.get('rtcLayoutmode') == 1 ? true: false)

  rtcLayout2: ->
    return (Session.get('rtcLayoutmode') == 2 ? true: false)

  rtcLayout3: ->
    return (Session.get('rtcLayoutmode') == 3 ? true: false)

  noRtcLayout: ->
    return (!Session.get('rtcLayoutmode') || (Session.get('rtcLayoutmode') == 0) ? true: false)

  isAdmin: ->
    return Meteor.user()?.admin is true

  utc: ->
    if @utcOffset?
      return "UTC #{@utcOffset}"

  phoneNumber: ->
    return '' unless @phoneNumber
    if @phoneNumber.length > 10
      return "(#{@phoneNumber.substr(0,2)}) #{@phoneNumber.substr(2,5)}-#{@phoneNumber.substr(7)}"
    else
      return "(#{@phoneNumber.substr(0,2)}) #{@phoneNumber.substr(2,4)}-#{@phoneNumber.substr(6)}"

  lastLogin: ->
    if @lastLogin
      return moment(@lastLogin).format('LLL')

  roomManager: ->
    room = ChatRoom.findOne(this._id, { reactive: false })
    return RoomManager.openedRooms[room.t + room.name]

  adminClass: ->
    return 'admin' if Meteor.user()?.admin is true

  thread: ->
    if Session.get('isThread')
      $('.room-icons .icon-list').addClass('active')
    return Session.get('isThread')

  classroom: ->
    if Session.get('isClassroom')
      $('.room-icons .icon-home').addClass('active')
    return Session.get('isClassroom')

  profile: ->
    if Session.get('isProfile')
      $('.room-icons .icon-user').addClass('active')
    return Session.get('isProfile')

  files: ->
    if Session.get('isFiles')
      $('.room-icons .icon-docs').addClass('active')
    return Session.get('isFiles')

  calendar: ->
    if Session.get('isCalendar')
      $('.room-icons .icon-calendar').addClass('active')
    return Session.get('isCalendar')

  fileDetails: ->
    if Session.get('isFileDetails')
      $('.room-icons .icon-doc').addClass('active')
    return Session.get('isFileDetails')

  eventDetails: ->
    if Session.get('isEventDetails')
      $('.room-icons .icon-notebook').addClass('active')
    return Session.get('isEventDetails')

  fileHistory: ->
    if Session.get('isFileHistory')
      $('.room-icons .icon-graph').addClass('active')
    return Session.get('isFileHistory')

  roomIcons: ->
    roomData = Session.get('roomData' + this._id)
    if roomData.t is "c"
      return "<li><i class='icon-home'><label class='tab-label classroom'>Classroom</label></i></li>
            <li><i class='icon-list'><label class='tab-label thread'>Thread</label></i></li>
            <li><i class='icon-docs'><label class='tab-label files'>Files</label></i></li>
            <li><i class='icon-calendar'><label class='tab-label cal'>Cal</label></i></li>"
    if roomData.t is 'p'
      return "<li><i class='icon-list'><label class='tab-label thread'>Thread</label></i></li>
            <li><i class='icon-docs'><label class='tab-label files'>Files</label></i></li>
            <li><i class='icon-calendar'><label class='tab-label cal'>Cal</label></i></li>"
    else if roomData.t is 'd'
      return "<li><i class='icon-user'><label class='tab-label profile'>Profile</label></i></li>
              <li><i class='icon-list'><label class='tab-label thread'>Thread</label></i></li>
              <li><i class='icon-docs'><label class='tab-label files'>Files</label></i></li>
              <li><i class='icon-calendar'><label class='tab-label cal'>Cal</label></i></li>"
    else if roomData.t is 'f'
      return "<li><i class='icon-doc'><label class='tab-label fileDetails'>Details</label></i></li>
              <li><i class='icon-list'><label class='tab-label thread'>Thread</label></i></li>
              <li><i class='icon-graph'><label class='tab-label fileHistory'>History</label></i></li>"
    else if roomData.t is 'e'
      return "<li><i class='icon-notebook'><label class='tab-label eventDetails'>Details</label></i></li>
              <li><i class='icon-list'><label class='tab-label thread'>Thread</label></i></li>
              <li><i class='icon-docs'><label class='tab-label files'>Files</label></i></li>"

Template.room.events

  "click .room-icons .icon-home": (e) ->
    clearActive()
    Session.set('isClassroom', true)

  "click .room-icons .icon-user": (e) ->
    clearActive()
    Session.set('isProfile', true)

  "click .room-icons .icon-list": (e) ->
    clearActive()
    Session.set('isThread', true)

  "click .room-icons .icon-docs": (e) ->
    clearActive()
    Session.set('isFiles', true)

  "click .room-icons .icon-calendar": (e) ->
    clearActive()
    Session.set('isCalendar', true)

  "click .room-icons .icon-doc": (e) ->
    clearActive()
    Session.set('isFileDetails', true)

  "click .room-icons .icon-notebook": (e) ->
    clearActive()
    Session.set('isEventDetails', true)

  "click .room-icons .icon-graph": (e) ->
    clearActive()
    Session.set('isFileHistory', true)

  "keydown #room-search": (e) ->
    if e.keyCode is 13
      e.preventDefault()

  "keyup #room-search": _.debounce (e, t) ->
    t.searchResult.set undefined
    value = e.target.value.trim()
    if value is ''
      return

    Tracker.nonreactive ->
      Meteor.call 'messageSearch', value, Session.get('openedRoom'), (error, result) ->
        if result? and (result.messages?.length > 0 or result.users?.length > 0 or result.channels?.length > 0)
          t.searchResult.set result
  , 1000

  "click .flex-tab .more": (event, t) ->
    if (Session.get('flexOpened'))
      Session.set('rtcLayoutmode', 0)
      Session.set('flexOpened',false)
      t.searchResult.set undefined
    else
      Session.set('flexOpened', true)


  "click .flex-tab  .video-remote" : (e) ->
    if (Session.get('flexOpened'))
      if (!Session.get('rtcLayoutmode'))
        Session.set('rtcLayoutmode', 1)
      else
        t = Session.get('rtcLayoutmode')
        t = (t + 1) % 4
        console.log  'setting rtcLayoutmode to ' + t  if window.rocketDebug
        Session.set('rtcLayoutmode', t)

  # "click .flex-tab .more": (event, t) ->
  #   if (Session.get('flexOpened'))
  #     Session.set('rtcLayoutmode', 0)
  #     Session.set('flexOpened',false)
  #     t.searchResult.set undefined
  #     $('.fixed-title h2').show(500)
  #   else
  #     Session.set('flexOpened', true)
  #     $('.fixed-title h2').hide()
  #
  # "click .flex-tab  .video-remote" : (e) ->
  #   if (Session.get('flexOpened'))
  #     if (!Session.get('rtcLayoutmode'))
  #       Session.set('rtcLayoutmode', 1)
  #     else
  #       t = Session.get('rtcLayoutmode')
  #       t = (t + 1) % 4
  #       console.log  'setting rtcLayoutmode to ' + t  if window.rocketDebug
  #       Session.set('rtcLayoutmode', t)
  #
  # "click .flex-tab  .video-self" : (e) ->
  #   if (Session.get('rtcLayoutmode') == 3)
  #     console.log 'video-self clicked in layout3' if window.rocketDebug
  #     i = document.getElementById("fullscreendiv")
  #     if i.requestFullscreen
  #       i.requestFullscreen()
  #     else
  #       if i.webkitRequestFullscreen
  #         i.webkitRequestFullscreen()
  #       else
  #         if i.mozRequestFullScreen
  #           i.mozRequestFullScreen()
  #         else
  #           if i.msRequestFullscreen
  #             i.msRequestFullscreen()

  'click .add-user': (event) ->
    toggleAddUser()

  'click .edit-room-title': (event) ->
    event.preventDefault()
    Session.set('editRoomTitle', true)
    $(".fixed-title").addClass "visible"
    Meteor.setTimeout ->
      $('#room-title-field').focus().select()
    , 10

  'keydown #user-add-search': (event) ->
    if event.keyCode is 27 # esc
      toggleAddUser()

  'keydown #room-title-field': (event) ->
    if event.keyCode is 27 # esc
      Session.set('editRoomTitle', false)
    else if event.keyCode is 13 # enter
      renameRoom @_id, $(event.currentTarget).val()

  'blur #room-title-field': (event) ->
    # TUDO: create a configuration to select the desired behaviour
    # renameRoom this._id, $(event.currentTarget).val()
    Session.set('editRoomTitle', false)
    $(".fixed-title").removeClass "visible"

  "click .flex-tab .user-image > a" : (e) ->
    Session.set('flexOpened', true)
    Session.set('showUserInfo', $(e.currentTarget).data('username'))

  'autocompleteselect #user-add-search': (event, template, doc) ->
    roomData = Session.get('roomData' + Session.get('openedRoom'))

    if roomData.t is 'd'
      Meteor.call 'createGroupRoom', roomData.usernames, doc.username, (error, result) ->
        if error
          return Errors.throw error.reason

        if result?.rid?
          $('#user-add-search').val('')
    else if roomData.t in ['c', 'p']
      Meteor.call 'addUserToRoom', { rid: roomData._id, username: doc.username }, (error, result) ->
        if error
          return Errors.throw error.reason

        $('#user-add-search').val('')
        toggleAddUser()

  'autocompleteselect #room-search': (event, template, doc) ->
    if doc.type is 'u'
      Meteor.call 'createDirectMessage', doc.username, (error, result) ->
        if error
          return Errors.throw error.reason

        if result?.rid?
          FlowRouter.go('direct', { username: doc.username })
          $('#room-search').val('')
    else if doc.type is 'r'
      if doc.t is 'c'
        FlowRouter.go('channel', { name: doc.name, term: doc.term })
      else if doc.t is 'p'
        FlowRouter.go('group', { name: doc.name })

      $('#room-search').val('')

  'click .start-video': (event) ->
    _id = Template.instance().data._id
    webrtc.to = _id.replace(Meteor.userId(), '')
    webrtc.room = _id
    webrtc.mode = 1
    webrtc.start(true)

  'click .stop-video': (event) ->
    webrtc.stop()

  'click .monitor-video': (event) ->
    _id = Template.instance().data._id
    webrtc.to = _id.replace(Meteor.userId(), '')
    webrtc.room = _id
    webrtc.mode = 2
    webrtc.start(true)


  'click .setup-video': (event) ->
    webrtc.mode = 2
    webrtc.activateLocalStream()

  'dragenter .dropzone': (e) ->
    e.currentTarget.classList.add 'over'

  'dragleave .dropzone-overlay': (e) ->
    e.currentTarget.parentNode.classList.remove 'over'

  'click .message-form .mic': (e, t) ->
    AudioRecorder.start ->
      t.$('.stop-mic').removeClass('hidden')
      t.$('.mic').addClass('hidden')

  'click .message-form .stop-mic': (e, t) ->
    AudioRecorder.stop (blob) ->
      fileUpload [{
        file: blob
        type: 'audio'
        name: 'Audio record'
      }]

    t.$('.stop-mic').addClass('hidden')
    t.$('.mic').removeClass('hidden')

  'click .deactivate': ->
    username = Session.get('showUserInfo')
    user = Meteor.users.findOne { username: String(username) }
    Meteor.call 'setUserActiveStatus', user?._id, false, (error, result) ->
      if result
        toastr.success t('User_has_been_deactivated')
      if error
        toastr.error error.reason

  'click .activate': ->
    username = Session.get('showUserInfo')
    user = Meteor.users.findOne { username: String(username) }
    Meteor.call 'setUserActiveStatus', user?._id, true, (error, result) ->
      if result
        toastr.success t('User_has_been_activated')
      if error
        toastr.error error.reason

Template.room.onCreated ->
  # this.scrollOnBottom = true
  # this.typing = new msgTyping this.data._id
  this.showUsersOffline = new ReactiveVar false
  this.searchResult = new ReactiveVar
  Session.set('isThread', true)
  Session.set('isClassroom', false)
  Session.set('isCalendar', false)
  Session.set('isFiles', false)
  Session.set('isProfile', false)
  Session.set('isFileDetails', false)
  Session.set('isFileHistory', false)
  Session.set('isEventDetails', false)

  self = @

  @autorun ->
    self.subscribe 'fullUserData', Session.get('showUserInfo'), 1

Template.room.onRendered ->
  self = @
  $('.room-icons .icon-list').addClass('active')

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
  if Session.get('isFileHistory')
    Session.set('isFileHistory', false)
    $('.room-icons .icon-graph').removeClass('active')

renameRoom = (rid, name) ->
  name = name?.toLowerCase().trim()
  console.log 'room renameRoom' if window.rocketDebug
  room = Session.get('roomData' + rid)
  if room.name is name
    Session.set('editRoomTitle', false)
    return false

  Meteor.call 'saveRoomName', rid, name, (error, result) ->
    if result
      Session.set('editRoomTitle', false)
      room = ChatRoom.findOne(rid)
      term = room.term
      # If room was renamed then close current room and send user to the new one
      RoomManager.close room.t + room.name, term
      switch room.t
        when 'c'
          FlowRouter.go 'channel', {name: name, term: term}
        when 'p'
          FlowRouter.go 'group', name: name

      toastr.success t('Room_name_changed_successfully')
    if error
      if error.error is 'name-invalid'
        toastr.error t('Invalid_room_name', name)
        return
      if error.error is 'duplicate-name'
        if room.t is 'c'
          toastr.error t('Duplicate_channel_name', name)
        else
          toastr.error t('Duplicate_private_group_name', name)
        return
      toastr.error error.reason

toggleAddUser = ->
  console.log 'room toggleAddUser' if window.rocketDebug
  btn = $('.add-user')
  $('.add-user-search').toggleClass('show-search')
  if $('i', btn).hasClass('icon-plus')
    $('#user-add-search').focus()
    $('i', btn).removeClass('icon-plus').addClass('icon-cancel')
  else
    $('#user-add-search').val('')
    $('i', btn).removeClass('icon-cancel').addClass('icon-plus')
