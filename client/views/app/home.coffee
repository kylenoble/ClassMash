Template.home.helpers
  title: ->
    return RocketChat.settings.get 'Layout_Home_Title'
  body: ->
    return RocketChat.settings.get 'Layout_Home_Body'
  firstTime: ->
    user = Meteor.user()
    diff = (new Date() - new Date(user.createdAt)) / 1000 / 60
    if diff <= 6
      return true
    else
      return false
