Blaze.registerHelper 'pathFor', (path, kw) ->
  return FlowRouter.path path, kw.hash

BlazeLayout.setRoot 'body'

FlowRouter.subscriptions = ->
  Tracker.autorun =>
    RoomManager.init()
    @register 'userData', Meteor.subscribe('userData')
    @register 'activeUsers', Meteor.subscribe('activeUsers')
    @register 'admin-settings', Meteor.subscribe('admin-settings')

FlowRouter.route '/',
  name: 'home'

  triggersEnter: [ (context, redirect) ->
    if Meteor.userId()
      BlazeLayout.render 'main', {center: 'loading'}

      Tracker.autorun (c) ->
        if FlowRouter.subsReady() is true
          Meteor.defer ->
            if Meteor.user().defaultRoom?
              room = Meteor.user().defaultRoom.split('/')
              FlowRouter.go room[0], {name: room[1]}
            else
              FlowRouter.go 'home'
          c.stop()
    else
      BlazeLayout.render 'landingPage'
 ]

FlowRouter.route '/login',
  name: 'login'

  action: ->
    FlowRouter.go 'home'

FlowRouter.route '/register',
  name: 'register'

  action: ->
    Session.set('registerInvite', true)
    FlowRouter.go 'home'

FlowRouter.route '/home',
  name: 'home'

  action: ->
    BlazeLayout.render 'main', {center: 'home'}
    KonchatNotification.getDesktopPermission()

FlowRouter.route '/my-files',
  name: 'my-files'

  action: ->
    BlazeLayout.render 'main', {center: 'myFiles'}

FlowRouter.route '/my-calendar',
  name: 'my-calendar'

  action: ->
    BlazeLayout.render 'main', {center: 'myCalendar'}

FlowRouter.route '/changeavatar',
  name: 'changeAvatar'

  action: ->
    BlazeLayout.render 'main', {center: 'avatarPrompt'}


FlowRouter.route '/admin/users',
  name: 'admin-users'

  action: ->
    BlazeLayout.render 'main', {center: 'adminUsers'}


FlowRouter.route '/admin/rooms',
  name: 'admin-rooms'

  action: ->
    BlazeLayout.render 'main', {center: 'adminRooms'}


FlowRouter.route '/admin/statistics',
  name: 'admin-statistics'

  action: ->
    BlazeLayout.render 'main', {center: 'adminStatistics'}


FlowRouter.route '/admin/:group?',
  name: 'admin'

  action: ->
    BlazeLayout.render 'main', {center: 'admin'}


FlowRouter.route '/account/:group?',
  name: 'account'

  action: (params) ->
    unless params.group
      params.group = 'Preferences'
    params.group = _.capitalize params.group, true
    BlazeLayout.render 'main', { center: "account#{params.group}" }


FlowRouter.route '/history/private',
  name: 'privateHistory'

  subscriptions: (params, queryParams) ->
    @register 'privateHistory', Meteor.subscribe('privateHistory')

  action: ->
    Session.setDefault('historyFilter', '')
    BlazeLayout.render 'main', {center: 'privateHistory'}


FlowRouter.route '/terms-of-service',
  name: 'terms-of-service'

  action: ->
    Session.set 'cmsPage', 'Layout_Terms_of_Service'
    BlazeLayout.render 'cmsPage'

FlowRouter.route '/privacy-policy',
  name: 'privacy-policy'

  action: ->
    Session.set 'cmsPage', 'Layout_Privacy_Policy'
    BlazeLayout.render 'cmsPage'

FlowRouter.route '/room-not-found/:type/:name',
  name: 'room-not-found'

  action: (params) ->
    Session.set 'roomNotFound', {type: params.type, name: params.name}
    BlazeLayout.render 'main', {center: 'roomNotFound'}

FlowRouter.route '/four-oh-four',
  name: 'four-oh-four'

  action: (params) ->
    BlazeLayout.render 'four-oh-four'

FlowRouter.notFound = action: ->
  name: '404'
  FlowRouter.go 'four-oh-four'

checkLogin = ->
  if Meteor.userId()
    BlazeLayout.render 'main', {center: 'loading'}

    Tracker.autorun (c) ->
      if FlowRouter.subsReady() is true
        Meteor.defer ->
          if Meteor.user().defaultRoom?
            room = Meteor.user().defaultRoom.split('/')
            FlowRouter.go room[0], {name: room[1]}
          else
            FlowRouter.go 'home'
        c.stop()
  else
    BlazeLayout.render 'landingPage'
