addTeacherEmail = new ReactiveVar false

Template.classroomPage.helpers
  addingTeacherEmail: ->
    return addTeacherEmail.get()

  teacher: ->
    return Template.instance().room.teacher

  teacherLabel: ->
    if Template.instance().school.isHighSchool
      return "Teacher"

    return "Professor"

  teacherEmail: ->
    if Template.instance().room.teacherEmail
      return Template.instance().room.teacherEmail
    else
      return "<a href='' class='add-teacher-email'>Add Teacher Email</a>"

  syllabus: ->
    Template.instance().room = ChatRoom.findOne(Template.instance().roomId, term: Template.instance().term)
    if Template.instance().room.syllabus
      return "
              <a href='#{Template.instance().room.syllabus.url}'><i class='icon-notebook'></i></a>
            "
    else
      return "
              <input type='file' id='select-syllabus'>
              <label class='add-syllabus-label button white blue-border' for='select-syllabus'>Add</label>
            "

  term: ->
    return Template.instance().room.term

  showViewAll: ->
    if Template.instance().showAllClassmates.get()
      return true
    return false

  classMembers: ->
    students = Template.instance().room.usernames
    length = students.length - 1
    limit = Template.instance().membersLimit.get()
    if length + 1 > limit
      console.log("not all students")
      return students.slice(length - limit, length)
    else
      return students

Template.classroomPage.events

  "click i.icon-bubbles": (e) ->
    username = $(e.target).parent().children()[1].innerText
    if Meteor.user().username == username
      return
    Meteor.call 'createDirectMessage', username, (error, result) ->
      if error
        return Errors.throw error.reason

      if result?.rid?
        clearActive()
        $('.room-icons .icon-list').addClass('active')
        FlowRouter.go('direct', { username: username })

  'click #view-all-classmates': (e, t) ->
    totalUsers = Template.instance().room.usernames.length
    if totalUsers > 3
      totalUsers - 1
    Template.instance().membersLimit.set(totalUsers)
    Template.instance().showAllClassmates.set(false)

  'click .add-teacher-email': (e, t) ->
    console.log 'adding teacher email'
    addTeacherEmail.set(true)
    $('.teacher-info .teacher-email').addClass('adding-teacher-email')

  'click .add-teacher-email-button': (e, t) ->
    email = $('#teacher-email').val()
    Meteor.call "addTeacherEmail", email, Template.instance().room._id, (error, result) ->
      if error
        console.log "error", error
        toastr.error(error)
        return
      if result
        $('.teacher-info .teacher-email').removeClass('adding-teacher-email')
        addTeacherEmail.set(false)

    Template.instance().room.teacherEmail = email

  'change #select-syllabus': (event, tmplate) ->
    e = event.originalEvent or event
    files = document.getElementById('select-syllabus').files[0]
    if not files or files.length is 0
      files = e.dataTransfer?.files or []

    fileUploadS3 files, 'syllabus', Template.instance().roomId
    $('#select-syllabus').hide()
    $('.add-syllabus-label').hide()

Template.classroomPage.created = ->
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

  this.term = path[3]
  this.roomId = RoomManager.openedRooms[typeLetter + path[2] + '%' + this.term].rid

  this.room = ChatRoom.findOne(this.roomId, term: this.term )

  this.school = Schools.find().fetch()
  this.membersLimit = new ReactiveVar 3
  this.showAllClassmates = new ReactiveVar true

clearActive = () ->
  if Session.get('isClassroom')
    Session.set('isClassroom', false)
    $('.room-icons .icon-home').removeClass('active')
  if Session.get('isCalendar')
    Session.set('isCalendar', false)
    $('.room-icons .icon-calendar').removeClass('active')
  if Session.get('isFiles')
    Session.set('isFiles', false)
    $('.room-icons .icon-docs').removeClass('active')
  if Session.get('isThread')
    Session.set('isThread', false)
    $('.room-icons .icon-list').removeClass('active')
  if Session.get('isProfile')
    Session.set('isProfile', false)
    $('.room-icons .icon-user').removeClass('active')
  if Session.get('isFileDetails')
    Session.set('isFileDetails', false)
    $('.room-icons .icon-doc').removeClass('active')
  if Session.get('isEventDetails')
    Session.set('isEventDetails', false)
    $('.room-icons .icon-notebook').removeClass('active')
  if Session.get('isAssignments')
    Session.set('isAssignments', false)
    $('.room-icons .icon-book-open').removeClass('active')
  if Session.get('isFileHistory')
    Session.set('isFileHistory', false)
    $('.room-icons .icon-graph').removeClass('active')
