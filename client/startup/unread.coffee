Meteor.startup ->

  ChatSubscription.find({}, { fields: { unread: 1 } }).observeChanges
    changed: (id, fields) ->
      if fields.unread and fields.unread > 0
        KonchatNotification.newMessage()

Meteor.startup ->

  Tracker.autorun ->

    unreadCount = 0
    unreadAlert = false

    messagesUnreadCount = 0
    messagesUnreadAlert = false

    subscriptions = ChatSubscription.find({open: true}, { fields: { unread: 1, alert: 1, rid: 1, t: 1, name: 1, ls: 1 } })

    rid = undefined
    if FlowRouter.getRouteName() in ['channel', 'group', 'direct']
      rid = Session.get 'openedRoom'

    for subscription in subscriptions.fetch()
      if subscription.rid is rid and (subscription.alert or subscription.unread > 0)
        readMessage.readNow()
      else
        if subscription.t == 'd'
          messagesUnreadCount += subscription.unread
          if subscription.alert is true
            messagesUnreadAlert = '•'
        else
          unreadCount += subscription.unread
          if subscription.alert is true
            unreadAlert = '•'

      readMessage.refreshUnreadMark(subscription.rid)

    if unreadCount > 0
      if unreadCount > 999
        Session.set 'unread', '999+'
      else
        Session.set 'unread', unreadCount
    else if unreadAlert isnt false
      Session.set 'unread', unreadAlert
    else
      Session.set 'unread', ''

    if messagesUnreadCount > 0
      if messagesUnreadCount > 999
        Session.set 'unreadMessages', '999+'
      else
        Session.set 'unreadMessages', messagesUnreadCount
    else if messagesUnreadAlert isnt false
      Session.set 'unreadMessages', messagesUnreadAlert
    else
      Session.set 'unreadMessages', ''


Meteor.startup ->

  window.favico = new Favico
    position: 'up'
    animation: 'none'

  Tracker.autorun ->
    siteName = RocketChat.settings.get 'Site_Name'

    unread = Session.get 'unread'
    unreadMessages = Session.get 'unreadMessages'
    if FlowRouter.getRouteName() == 'direct'
      fireGlobalEvent 'unread-changed', unreadMessages
    else
      fireGlobalEvent 'unread-changed', unread
    favico?.badge unread, bgColor: if typeof unread isnt 'number' then '#3d8a3a' else '#ac1b1b'
    document.title = if unread == '' then 'ClassMash' else '(' + unread + ') ClassMash'
