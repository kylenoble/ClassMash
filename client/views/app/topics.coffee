Template.topics.helpers
  classTopics: ->
    topics = Topics.find("classId": Template.instance().classId.get()).fetch()
    console.log topics
    return topics

  checkActive: (topic)->
    if Session.get("topic") is topic
      return 'active'

  addingTopic: () ->
    return Template.instance().addTopic.get()

Template.topics.events
  "click .topic": (event, template) ->
    topic = event.target.innerText
    if Session.get('topic') != topic
      Session.set('topic', topic)

  "click .icon-plus": (event, template) ->
    Template.instance().addTopic.set(true)

  "click .add-topic": (event, template) ->
    topic = $('.new-topic').val()
    console.log topic.length
    if topic.length < 1
      toastr.error "Please enter a topic before adding"
      return

    if topic.length > 50
      toastr.error "Please choose a shorter name"
      return

    currentClassId = Template.instance().classId.get()
    Meteor.call "addTopic", topic, currentClassId, (error, result) ->
      if error
        toastr.error error
        console.log "error", error
        return

    $('new-topic').text('')
    Template.instance().addTopic.set(false)

  "click .cancel-add-topic": (event, template) ->
    $('new-topic').text('')
    Template.instance().addTopic.set(false)

  "keydown new-topic": (event, template) ->


Template.topics.onCreated ->
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
  @classId = new ReactiveVar RoomManager.openedRooms[typeLetter + path[2] + '%' + term].rid
  @addTopic = new ReactiveVar false
  @ready = new ReactiveVar true

  @autorun ->
    classId = instance.classId.get()
    topics = Meteor.subscribe 'topics', classId
    instance.ready.set topics.ready()
