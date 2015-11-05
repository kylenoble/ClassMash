Template.filesPage.helpers
  roomFiles: ->
    filter = Template.instance().currentFilter.get()
    return fileCollection.find({category: filter}, {limit: 10})

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

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

Template.filesPage.events
  'click .file': (event) ->
    $('.adding-files').toggle()

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

Template.filesPage.onRendered ->
  $('.filter-item.files').addClass('active')
  console.log('files page rendered')

Template.filesPage.onCreated ->
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
  else
    term = ''

  console.log 'file page typeName'
  console.log typeLetter + path[2] + '%' + term
  console.log RoomManager.openedRooms[typeLetter + path[2] + '%']
  console.log RoomManager.openedRooms
  instance = @
  @limit = new ReactiveVar 50
  @currentFilter = new ReactiveVar 'regular'
  @roomId = new ReactiveVar RoomManager.openedRooms[typeLetter + path[2] + '%' + term].rid
  @ready = new ReactiveVar true

  @autorun ->
    filter = instance.currentFilter.get()
    limit = instance.limit.get()
    roomId = instance.roomId.get()
    fileList = Meteor.subscribe 'fileList', limit, roomId
    instance.ready.set fileList.ready()


clearFilters = ->
  Template.instance().isFilesFilter = false
  Template.instance().isNotesFilter = false
  Template.instance().isNoteCardsFilter = false
  $('.filter-item.files').removeClass('active')
  $('.filter-item.notes').removeClass('active')
  $('.filter-item.note-cards').removeClass('active')
