fileCategory = new ReactiveVar('')
fileRoomId = new ReactiveVar('')
shortFileType = new ReactiveVar('')

readAsDataURL = (file, callback) ->
  reader = new FileReader()
  reader.onload = (ev) ->
    callback ev.target.result, file

  reader.readAsDataURL file

@fileUploadS3 = (files, category, roomId) ->
  files = [].concat files

  fileCategory.set(category)
  fileRoomId.set(roomId)
  text = ''
  icon = ''
  previewIcon = ''
  shortFileType.set('')
  metaContext = {roomId: roomId, type: category}
  uploader = new Slingshot.Upload("fileUploads", metaContext)
  consume = ->
    file = files.pop()
    if not file?
      swal.close()
      return
    fileType = file.type.split("/")
    fileExtension = file.name.split('.')
    readAsDataURL file, (fileContent) ->
      text = ''
      if file.type is 'audio'
        text = """
          <div class='upload-preview'>
            <div class='upload-preview-file' style='background-image: url(#{fileContent})'></div>
          </div>
          <div class='upload-preview-title'>#{file.name}</div>
        """
      else if fileType[0] is 'image'
        text = """
          <div class='upload-preview'>
            <div class='upload-preview-file' style='background-image: url(#{fileContent})'></div>
          </div>
          <div class='upload-preview-title'>#{file.name}</div>
        """
      else
        if fileType[1] is 'pdf'
          previewIcon = 'fa fa-file-pdf-o'
        else if (fileType[1] == 'vnd.ms-excel' or fileType[1] == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') or fileExtension[fileExtension.length - 1] == '.xls'
          previewIcon = 'fa fa-file-excel-o'
        else if fileType[1] is 'vnd.ms-powerpoint'
          previewIcon = 'fa fa-file-powerpoint-o'
        else if fileType[1] == 'vnd.msword' or fileType[1] == 'msword'
          previewIcon = 'fa fa-file-word-o'
        else if fileType[1] is 'csv'
          previewIcon = 'fa fa-file-excel-o'
        else if fileType[1] is 'rtf'
          previewIcon = 'fa fa-file-text-o'
        else if fileExtension[fileExtension.length - 2] == 'pages'
          previewIcon = 'icon-note'
        else if fileExtension[fileExtension.length - 2] == 'numbers'
          previewIcon = 'fa fa-bar-chart'
        else if fileExtension[fileExtension.length - 2] == 'key'
          previewIcon = 'icon-key'
        else
          previewIcon = 'fa fa-file-o'

        text = """
          <div class='upload-preview'>
            <div class='upload-preview-file'><i class="#{previewIcon}"></i></div>
          </div>
          <div class='upload-preview-title'>#{file.name}</div>
        """

      swal
        title: t('Upload_file_question')
        text: text
        showCancelButton: true
        closeOnConfirm: true
        closeOnCancel: true
        html: true
      , (isConfirm) ->
        consume()
        if isConfirm isnt true
          return

        uploader.send file, (error, downloadUrl) ->
          if error
            if error.error
              toastr.error error.error
              return
            else
              if uploader.xhr
                toastr.error 'Error uploading', uploader.xhr.response
                return
              else
                toastr.error error
                return
          else
            if file.type is 'audio'
              shortFileType.set('audio')
              message = """
                File Uploaded: *#{file.name}*
                #{downloadUrl}
              """
            else if fileType[0] is 'image'
              downloadUrl = encodeURI(downloadUrl)
              shortFileType.set('image')
              message = """
                File Uploaded: <a class="linkable-title" href="#{downloadUrl}" target=_blank>#{file.name}</a>
                <a href="#{downloadUrl}" class="swipebox" target="_blank">
                  <div style="background-image: url(#{downloadUrl}); background-size: contain; background-repeat: no-repeat; background-position: center left; height: 200px;"></div>
                </a>
              """
            else
              if fileType[1] is 'pdf'
                icon = 'fa fa-file-pdf-o'
                shortFileType.set('pdf')
              else if (fileType[1] == 'vnd.ms-excel' or fileType[1] == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') or fileExtension[fileExtension.length - 1] == '.xls'
                icon = 'fa fa-file-excel-o'
                shortFileType.set('vnd.ms-excel')
              else if fileType[1] is 'vnd.ms-powerpoint'
                icon = 'fa fa-file-powerpoint-o'
                shortFileType.set('vnd.ms-powerpoint')
              else if fileType[1] == 'vnd.msword' or fileType[1] == 'msword'
                icon = 'fa fa-file-word-o'
                shortFileType.set('vnd.msword')
              else if fileType[1] is 'csv'
                icon = 'fa fa-file-excel-o'
                shortFileType.set('csv')
              else if fileType[1] is 'rtf'
                icon = 'fa fa-file-text-o'
                shortFileType.set('rtf')
              else if fileExtension[fileExtension.length - 2] == 'pages'
                icon = 'icon-note'
                shortFileType.set('pages')
              else if fileExtension[fileExtension.length - 2] == 'numbers'
                icon = 'fa fa-bar-chart'
                shortFileType.set('numbers')
              else if fileExtension[fileExtension.length - 2] == 'key'
                icon = 'icon-key'
                shortFileType.set('key')
              else
                icon = 'fa fa-file-o'

              message = """
                File Uploaded:
                <div class='uploaded-file'>
                  <i class="#{icon}"></i><div class='file-upload-metadata'>#{file.name}</div>
                  <div class='download-file'><a href='#{downloadUrl}' class='linkable-title' target=_blank><i class="fa fa-cloud-download"></i></a></div>
                </div>
              """
            upload = fileCollection.insert
              name: file.name
              size: file.size
              type: file.type
              url: downloadUrl
              date: new Date()
              category: fileCategory.get()
              user: {
                _id: Meteor.userId()
                username: Meteor.user().username
              }
              room: {
                _id: fileRoomId.get()
              }

              if metaContext.type is 'syllabus'
                Meteor.call 'addSyllabus', file.name, downloadUrl, fileRoomId.get()
              else
                Meteor.call 'sendMessage', {
                  _id: Random.id()
                  t: shortFileType.get()
                  rid: Session.get('openedRoom')
                  msg: message
                  file:
                    _id: this._id
                }
  consume()
