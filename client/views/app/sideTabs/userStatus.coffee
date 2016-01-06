Template.userStatus.helpers
  myUserInfo: ->
    visualStatus = "online"
    username = Meteor.user()?.username
    switch Session.get('user_' + username + '_status')
      when "away"
        visualStatus = t("away")
      when "busy"
        visualStatus = t("busy")
      when "offline"
        visualStatus = t("invisible")
    return {
      name: Session.get('user_' + username + '_name')
      status: Session.get('user_' + username + '_status')
      visualStatus: visualStatus
      _id: Meteor.userId()
      username: username
    }

  isAdmin: ->
    return Meteor.user()?.admin is true

Template.userStatus.events
  'click .options .status': (event) ->
    event.preventDefault()
    AccountBox.setStatus(event.currentTarget.dataset.status)

  'click .account-box': (event) ->
    AccountBox.toggle()

  'click #logout': (event) ->
    event.preventDefault()
    user = Meteor.user()
    clearActive()
    Meteor.logout ->
      FlowRouter.go 'login'
      Meteor.call('logoutCleanUp', user)

  'click #avatar': (event) ->
    FlowRouter.go 'changeAvatar'

  'click #account': (event) ->
    SideNav.setFlex "accountFlex"
    SideNav.openFlex()
    FlowRouter.go 'account'

  'click #admin': ->
    SideNav.setFlex "adminFlex"
    SideNav.openFlex()

  'click .account-link': ->
    menu.close()

Template.userStatus.rendered = ->
  AccountBox.init()

clearActive = () ->
  $('.room-icons .icon-home').removeClass('active')
  $('.room-icons .icon-docs').removeClass('active')
  $('.room-icons .icon-calendar').removeClass('active')
  $('.room-icons .icon-user').removeClass('active')
  $('.room-icons .icon-doc').removeClass('active')
  $('.room-icons .icon-notebook').removeClass('active')
  $('.room-icons .icon-graph').removeClass('active')
  $('.room-icons .icon-book-open').removeClass('active')
  Session.set('isClassroom', false)
  Session.set('isCalendar', false)
  Session.set('isFiles', false)
  Session.set('isProfile', false)
  Session.set('isFileDetails', false)
  Session.set('isEventDetails', false)
  Session.set('isFileHistory', false)
  Session.set('isAssignments', false)
  Session.set('isSearch', false)
  if Session.get('isThread')
    Session.set('isThread', false)
