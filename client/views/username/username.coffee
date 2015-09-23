Template.username.onCreated ->
  self = this
  self.username = new ReactiveVar
  Session.set('isAddingUserName', false)
  element = $("#login-card")
  element.removeClass("red-background")
  element.addClass("light-blue-background")
  element = $(".full-page-username")
  element.removeClass("red-background")
  element.addClass("light-blue-background")
  $('body').css('background-color', '#3498DB')

  Meteor.call 'getUsernameSuggestion', (error, username) ->
    self.username.set
      ready: true
      username: username
    Meteor.defer ->
      self.find('input').focus()

Template.username.helpers
  username: ->
    return Template.instance().username.get()
  addingUsername: ->
    return Session.get 'isAddingUserName'

Template.username.events
  'submit #login-card': (event, instance) ->
    event.preventDefault()

    username = instance.username.get()
    username.empty = false
    username.error = false
    username.invalid = false
    instance.username.set(username)

    button = $(event.target).find('button.login')
    RocketChat.Button.loading(button)

    value = $("input").val().trim()
    if value is ''
      username.empty = true
      instance.username.set(username)
      RocketChat.Button.reset(button)
      return

    Meteor.call 'setUsername', value, (err, result) ->
      if err?
        if err.error is 'username-invalid'
          username.invalid = true
        else
          username.error = true
        username.username = value

      RocketChat.Button.reset(button)
      instance.username.set(username)

      if not err?
        Meteor.call 'joinDefaultChannels'
        FlowRouter.go 'app'
