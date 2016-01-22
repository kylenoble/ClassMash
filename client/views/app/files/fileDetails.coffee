Template.fileDetailsPage.helpers
  file: ->
    path = window.location.pathname.split('/')
    fileInfo = fileCollection.find(_id: path[2]).fetch()
    return fileInfo

  cleanDate: (date) ->
    return moment(date).format("MM/D/YY h:mm a")

  icon: (fileName) ->
    fileType = fileName.split("/")
    fileExtension = fileName.split('.')
    if fileName.type is 'audio'
      return 'audio'
    else if fileType[0] is 'image'
      return 'image'
    else
      if fileType[1] is 'pdf'
        return 'pdf'
      else if (fileType[1] == 'vnd.ms-excel' or fileType[1] == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') or fileExtension[fileExtension.length - 1] == '.xls'
        return 'excel'
      else if fileType[1] is 'vnd.ms-powerpoint'
        return 'powerpoint'
      else if fileType[1] == 'vnd.msword' or fileType[1] == 'msword'
        return 'word'
      else if fileType[1] is 'csv'
        return 'csv'
      else if fileType[1] is 'rtf'
        return 'rtf'
      else if fileExtension[fileExtension.length - 2] == 'pages'
        return 'pages'
      else if fileExtension[fileExtension.length - 2] == 'numbers'
        return 'numbers'
      else if fileExtension[fileExtension.length - 2] == 'key'
        return 'keynote'
      else
        return 'unknown'

Template.fileDetailsPage.events
  "click #foo": (event, template) ->


Template.fileDetailsPage.onCreated ->
  path = window.location.pathname.split('/')

  instance = @
  @fileId = new ReactiveVar path[2]
  @ready = new ReactiveVar true


  @autorun ->
    fileId = instance.fileId.get()
    fileDetails = Meteor.subscribe 'fileDetails', fileId
    instance.ready.set fileDetails.ready()

Template.fileDetailsPage.onRendered ->
  properties = {
    fileId: Template.instance().fileId.get()
  }
  amplitude.logEvent("FILE_HISTORY_RENDERED", properties)
