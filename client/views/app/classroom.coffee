addTeacherEmail = new ReactiveVar false

Template.classroomPage.helpers
  addingTeacherEmail: ->
    console.log addTeacherEmail.get()
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

  # "click .member-info": (e) ->
  #   # channel = $(e.currentTarget).data('channel')
  #   # term = $(e.currentTarget).data('term')
  #   # if channel?
  #   #   FlowRouter.go 'channel', {name: channel, term: term}
  #   #   return
  #   Session.set('showUserProfile', true)
  #   Session.set('showUserInfo', $(e.target).text().trim())

  'click .add-teacher-email': (e, t) ->
    console.log 'adding teacher email'
    addTeacherEmail.set(true)
    $('.teacher-info .teacher-email').addClass('adding-teacher-email')

  'click .add-teacher-email-button': (e, t) ->
    email = $('#teacher-email').val()
    console.log email
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

    console.log(files)

    fileUploadS3 files, 'syllabus', Template.instance().roomId
    $('#select-syllabus').hide()
    $('.add-syllabus-label').hide()

Template.classroomPage.created = ->
  path = window.location.pathname.split('/')
  if path[1] is 'group'
    typeLetter = 'p'
  else
    typeLetter = path[1][0]

  this.term = path[3]
  this.roomId = RoomManager.openedRooms[typeLetter + path[2]].rid

  console.log(this.term)
  console.log(RoomManager.openedRooms)
  this.room = ChatRoom.findOne(this.roomId, term: this.term )

  this.school = Schools.find().fetch()
  this.membersLimit = new ReactiveVar 3
