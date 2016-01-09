Template.fileHistoryPage.helpers
  files: ->
    path = window.location.pathname.split('/')
    console.log path[2]
    fileInfo = fileCollection.find(_id: path[2]).fetch()
    console.log fileInfo
    return fileInfo

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

Template.fileHistoryPage.events
  "click #foo": (event, template) ->


Template.fileHistoryPage.onCreated ->
  path = window.location.pathname.split('/')

  instance = @
  @fileId = new ReactiveVar path[2]
  @ready = new ReactiveVar true

  @autorun ->
    fileId = instance.fileId.get()
    fileDetails = Meteor.subscribe 'fileDetails', fileId
    instance.ready.set fileDetails.ready()
