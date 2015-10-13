Template.userProfile.helpers
  flexUserInfo: ->
    user = Meteor.users.findOne(Meteor.userId())
    school = user.profile.school._id
    path = window.location.pathname.split('/')
    username = path[2]
    user = Meteor.users.findOne({ username: username, "profile.school._id": school })
    if user
      console.log(user)
      return user

Template.userProfile.events
  "click #foo": (event, template) ->
