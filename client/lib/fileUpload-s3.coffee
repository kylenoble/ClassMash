fileCategory = new ReactiveVar('')
fileRoomId = new ReactiveVar('')

@fileUploadS3 = (file, category, roomId, fileUrl) ->
	fileCategory.set(category)
	console.log(roomId)
	fileRoomId.set(roomId)
	consume = ->
		text = ''

		if file.type is 'audio'
			text = """
				<div class='upload-preview'>
					<audio  style="width: 100%;" controls="controls">
						<source src="#{fileUrl}" type="audio/wav">
						Your browser does not support the audio element.
					</audio>
				</div>
				<div class='upload-preview-title'>#{file.name}</div>
			"""
		else
			text = """
				<div class='upload-preview'>
					<div class='upload-preview-file' style='background-image: url(#{encodeURI(fileUrl)})'></div>
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

			record =
				name: file.name
				size: file.size
				type: file.type
				url: fileUrl
				category: fileCategory.get()
				user: {
					_id: Meteor.userId()
				}
				room: {
					_id: fileRoomId.get()
				}

			upload = fileCollection.insert
				_id: Random.id()
				file: record
				Meteor.call 'sendMessage', {
					_id: Random.id()
					rid: Session.get('openedRoom')
					msg: """
						File Uploaded: *#{file.name}*
						#{encodeURI(fileUrl)}
					"""
					file:
						_id: file._id
				}

	consume()
