Meteor.startup ->
  Meteor.defer ->
    try Meteor.users._ensureIndex { 'username': 1, 'profile.school._id': 1 }, { unique: 1, sparse: 1 } catch e then console.log e
    try Meteor.users._ensureIndex { 'status': 1 } catch e then console.log e

    try ChatRoom._ensureIndex { 'name': 1, 's._id': 1, 'term': 1 }, { unique: 1, sparse: 1 } catch e then console.log e
    try ChatRoom._ensureIndex { 'u._id': 1 } catch e then console.log e

    try ChatSubscription._ensureIndex { 'rid': 1, 'u._id': 1 }, { unique: 1 } catch e then console.log e
    try ChatSubscription._ensureIndex { 'u._id': 1, 'name': 1, 't': 1, 'term': 1 }, { unique: 1 } catch e then console.log e
    try ChatSubscription._ensureIndex { 'open': 1 } catch e then console.log e
    try ChatSubscription._ensureIndex { 'alert': 1 } catch e then console.log e
    try ChatSubscription._ensureIndex { 'unread': 1 } catch e then console.log e
    try ChatSubscription._ensureIndex { 'ts': 1 } catch e then console.log e

    try ChatMessage._ensureIndex { 'rid': 1, 'ts': 1 } catch e then console.log e
    try ChatMessage._ensureIndex { 'ets': 1 }, { sparse: 1 } catch e then console.log e
    try ChatMessage._ensureIndex { 'rid': 1, 't': 1, 'u._id': 1 } catch e then console.log e
    try ChatMessage._ensureIndex { 'expireAt': 1 }, { expireAfterSeconds: 0 } catch e then console.log e
    try ChatMessage._ensureIndex { 'msg': 'text' } catch e then console.log e

    try fileCollection._ensureIndex { 'user._id': 1 } catch e then console.log e
    try fileCollection._ensureIndex { 'room._id': 1 } catch e then console.log e
    try fileCollection._ensureIndex { 'date': 1 } catch e then console.log e
    try fileCollection._ensureIndex { 'category': 1 } catch e then console.log e

    try CalendarItems._ensureIndex { 'u._id': 1 } catch e then console.log e
    try CalendarItems._ensureIndex { 'r._id': 1 } catch e then console.log e
    try CalendarItems._ensureIndex { 'start': 1 } catch e then console.log e
