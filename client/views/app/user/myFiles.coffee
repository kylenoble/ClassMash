Template.myFiles.helpers
  myFilesList: ->
    filter = Template.instance().currentFilter.get()
    return fileCollection.find({category: filter, 'user._id': Meteor.userId()}, {limit: 10})

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  unread: (id) ->
    room = ChatRoom.find({"t": "f", "f._id": id}).fetch()
    if room[0]
      return room[0].msgs
    return false

  currentUser: (username) ->
    user = Meteor.user()
    if user.username is username
      return true
    return false

  uploading: ->
    return Session.get 'uploading'

  icon: (fileName) ->
    fileType = fileName.split("/")
    fileExtension = fileName.split('.')
    if fileName.type is 'audio'
      return 'fa fa-sound-o'
    else if fileType[0] is 'image'
      return 'fa fa-picture-o'
    else
      if fileType[1] is 'pdf'
        return 'fa fa-file-pdf-o'
      else if (fileType[1] == 'vnd.ms-excel' or fileType[1] == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') or fileExtension[fileExtension.length - 1] == '.xls'
        return 'fa fa-file-excel-o'
      else if fileType[1] is 'vnd.ms-powerpoint'
        return 'fa fa-file-powerpoint-o'
      else if fileType[1] == 'vnd.msword' or fileType[1] == 'msword'
        return 'fa fa-file-word-o'
      else if fileType[1] is 'csv'
        return 'fa fa-file-excel-o'
      else if fileType[1] is 'rtf'
        return 'fa fa-file-text-o'
      else if fileExtension[fileExtension.length - 2] == 'pages'
        return 'fa fa-file-text-o'
      else if fileExtension[fileExtension.length - 2] == 'numbers'
        return 'fa fa-file-o'
      else if fileExtension[fileExtension.length - 2] == 'key'
        return 'fa fa-file-o'
      else
        return 'fa fa-file-o'

Template.myFiles.events
  'click .file-upload': (event) ->
    $('.adding-files').toggle()

  'click .files-list .icon-bubble': (event) ->
    $('.adding-files').hide()
    fileId = $(event.target).parent()[0].id
    url = "/files/" + fileId
    clearActive()
    FlowRouter.go(url)

  'click .delete-file': (event) ->
    $('.adding-files').hide()
    file = $(event.target).parent().parent()
    fileId = file[0].id

    roomId = Template.instance().roomId.get()
    console.log roomId

    swal
      title: 'Are you sure you want to delete this file?'
      text: ''
      showCancelButton: true
      closeOnConfirm: true
      closeOnCancel: true
      html: true
    , (isConfirm) ->
      if isConfirm isnt true
        return
      console.log 'deleted'

      Meteor.call "deleteFile", fileId, (error, result) ->
        if error
          console.log "error", error
          toastr.error error
        if result
          RoomHistoryManager.reset(roomId)
          return

  'change #select-regular-file': (event, tmplate) ->
    e = event.originalEvent or event
    files = document.getElementById('select-regular-file').files[0]
    if not files or files.length is 0
      files = e.dataTransfer?.files or []

    fileUploadS3 files, 'regular', Template.instance().roomId.get()

    $('.adding-files').hide()

  'change #select-notes': (event, tmpl) ->
    e = event.originalEvent or event
    files = document.getElementById('select-notes').files[0]
    if not files or files.length is 0
      files = e.dataTransfer?.files or []

    fileUploadS3 files, 'notes', Template.instance().roomId.get()

    $('.adding-files').hide()

  'change #select-note-cards': (event, tmpl) ->
    e = event.originalEvent or event
    files = document.getElementById('select-note-cards').files[0]
    if not files or files.length is 0
      files = e.dataTransfer?.files or []

    fileUploadS3 files, 'note-cards', Template.instance().roomId.get()

    $('.adding-files').hide()

  "click .filter-item.files": (event, template) ->
    clearFilters()
    Template.instance().isFilesFilter = true
    $('.filter-item.files').addClass('active')
    Template.instance().currentFilter.set('regular')

  "click .filter-item.notes": (event, template) ->
    clearFilters()
    Template.instance().isFilesFilter = true
    $('.filter-item.notes').addClass('active')
    Template.instance().currentFilter.set('notes')

  "click .filter-item.note-cards": (event, template) ->
    clearFilters()
    Template.instance().isFilesFilter = true
    $('.filter-item.note-cards').addClass('active')
    Template.instance().currentFilter.set('note-cards')

Template.myFiles.onRendered ->
  $('.rooms-list ul').children().removeClass('active')

  $('.filter-item.files').addClass('active')
  console.log('my files page rendered')

Template.myFiles.onCreated ->
  instance = @
  @limit = new ReactiveVar 50
  @currentFilter = new ReactiveVar 'regular'
  @roomId = new ReactiveVar ''
  @ready = new ReactiveVar true

  @autorun ->
    filter = instance.currentFilter.get()
    limit = instance.limit.get()
    roomId = instance.roomId.get()
    myFiles = Meteor.subscribe 'myFiles', limit, roomId
    instance.ready.set myFiles.ready()


clearFilters = ->
  Template.instance().isFilesFilter = false
  Template.instance().isNotesFilter = false
  Template.instance().isNoteCardsFilter = false
  $('.filter-item.files').removeClass('active')
  $('.filter-item.notes').removeClass('active')
  $('.filter-item.note-cards').removeClass('active')

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
  if Session.get('isSearch')
    Session.set('isSearch', false)
