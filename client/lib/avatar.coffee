@getAvatarUrlFromUsername = (username) ->
  key = "avatar_random_#{username}"
  random = Session.keys[key] or 1
  if not username?
    return

  return "#{Meteor.absoluteUrl()}avatar/#{username}.jpg?_dc=#{random}"

Blaze.registerHelper 'avatarUrlFromUsername', getAvatarUrlFromUsername

@updateAvatarOfUsername = (username) ->
  key = "avatar_random_#{username}"
  Session.set key, Math.round(Math.random() * 1000)

  for key, room of RoomManager.openedRooms
    url = getAvatarUrlFromUsername username

    $(room.dom).find(".message[data-username='#{username}'] .avatar-image").css('background-image', "url(#{url})")

  return true
