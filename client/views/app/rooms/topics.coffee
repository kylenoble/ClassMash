Template.topics.helpers
  classTopics: ->
    return Topics.find("classId": Template.instance().classId.get()).fetch()

  checkActive: (topic)->
    lastPos = $( ".topics-container .topic:last" ).position()
    topicsContainer = $('.topics-container').width()
    if lastPos and lastPos.left > topicsContainer
      $('.show-more-topics').css('visibility', 'visible')
    else
      $('.show-more-topics').css('visibility', 'hidden')

    if Session.get("topic") is topic
      # currentClassId = Template.instance().classId.get()
      # Meteor.call "updateTopicUnread", topic, currentClassId, (error, result) ->
      #   if error
      #     console.log "error", error
      #     toastr.error error
      return 'active'

  addingTopic: () ->
    return Template.instance().addTopic.get()

  unread: (topic) ->
    currentClassId = Template.instance().classId.get()
    room = ChatSubscription.find({"rid": currentClassId, 'u._id': Meteor.userId()}).fetch()
    if room
      # if room[0].topics[topic] > 0 and Session.get('topic') is topic
      #   Meteor.call "updateTopicUnread", topic, currentClassId, (error, result) ->
      #     if error
      #       console.log "error", error
      #       toastr.error error
      #     return room[0].topics[topic]
      # else
      return room[0].topics[topic]

Template.topics.events
  "click .topic": (event, template) ->
    if $(event.target).hasClass('topic')
      topic = $(event.target).children()[0].innerText
    else
      topic = event.target.innerText

    if Session.get('topic') != topic
      Session.set('topic', topic)
      currentClassId = Template.instance().classId.get()
      Meteor.call "updateTopicUnread", topic, currentClassId, (error, result) ->
        if error
          console.log "error", error
          toastr.error error

  "click .icon-plus": (event, template) ->
    Template.instance().addTopic.set(true)

  "click .add-topic": (event, template) ->
    topic = $('.new-topic').val()
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
      else
        Session.set('topic', topic)
        newTopic = topic.length * 13 + 30
        width = $('.topics-container').width() + newTopic
        width = '+=' + width
        $('.topics-container').animate({scrollLeft:width},500)

    $('new-topic').text('')
    Template.instance().addTopic.set(false)

  "click .cancel-add-topic": (event, template) ->
    $('new-topic').text('')
    Template.instance().addTopic.set(false)

  "keydown new-topic": (event, template) ->

Template.topics.onRendered ->
  $('.topics-container').on 'scroll', (e) ->
    lastPos = $( ".topics-container .topic:last" ).position()
    topicsContainer = $('.topics-container').width()
    lastWidth = $( ".topics-container .topic:last" ).width() + 30
    if lastPos != undefined and lastPos.left + lastWidth - topicsContainer > 0
      $('.show-more-topics').css('visibility', 'visible')
    else
      $('.show-more-topics').css('visibility', 'hidden')

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
  @showMoreIcon = new ReactiveVar false
  @ready = new ReactiveVar true

  @autorun ->
    classId = instance.classId.get()
    topics = Meteor.subscribe 'topics', classId
    instance.ready.set topics.ready()
