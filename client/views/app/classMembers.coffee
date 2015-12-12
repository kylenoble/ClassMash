Template.classMembers.helpers
  classMemberList: ->
    return classMembers.find()

Template.classMembers.events
  "click #foo": (event, template) ->

Template.classMembers.onCreated ->
  path = window.location.pathname.split('/')
  if path[1] is 'group'
    typeLetter = 'p'
  else if path[1] is 'files'
    typeLetter = 'f'
  else if path[1] is 'calendar-item'
    typeLetter = 'o'
  else if path[1] is 'quiz-test'
    typeLetter = 'q'
  else if path[1] is 'assignment'
    typeLetter = 'a'
  else
    typeLetter = path[1][0]

  if path[3]
    term = path[3]
  else if typeLetter in ['p','d']
    term = 'all'
  else
    term = ''

  instance = @
  @roomId = new ReactiveVar RoomManager.openedRooms[typeLetter + path[2] + '%' + term].rid
  @ready = new ReactiveVar true

  @autorun ->
    roomId = instance.roomId.get()
    classMembers = Meteor.subscribe 'classMembers', roomId
    instance.ready.set classMembers.ready()
