Template.threadPage.helpers
	roomManager: ->
		room = ChatRoom.findOne(Template.instance().roomId, { reactive: false })
		console.log(room)
		return RoomManager.openedRooms[room.t + room.name]

	unreadCount: ->
		return RoomHistoryManager.getRoom(@_id).unreadNotLoaded.get() + Template.instance().unreadCount.get()

	formatUnreadSince: ->
		room = ChatRoom.findOne(Template.instance().roomId, { reactive: false })
		room = RoomManager.openedRooms[room.t + room.name]
		date = room?.unreadSince.get()
		if not date? then return

		return moment(date).calendar(null, {sameDay: 'LT'})

	fileUrl: ->
		return @uploader.url(true);

	maxMessageLength: ->
		return RocketChat.settings.get('Message_MaxAllowedSize')

	seeAll: ->
		if Template.instance().showUsersOffline.get()
			return t('See_only_online')
		else
			return t('See_all')

	getPupupConfig: ->
		template = Template.instance()
		return {
			getInput: ->
				return template.find('.input-message')
		}

	messagesHistory: ->
		return ChatMessage.find { rid: Template.instance().roomId, t: { '$ne': 't' }	}, { sort: { ts: 1 } }

	hasMore: ->
		return RoomHistoryManager.hasMore Template.instance().roomId

	isLoading: ->
		return RoomHistoryManager.isLoading Template.instance().roomId

	windowId: ->
		return "chat-window-#{Template.instance().roomId}"

	uploading: ->
		return Session.get 'uploading'

	subscribed: ->
		return ChatSubscription.find({ rid: Template.instance().roomId }).count() > 0

	usersTyping: ->
		users = MsgTyping.get @_id
		if users.length is 0
			return
		if users.length is 1
			return {
				multi: false
				selfTyping: MsgTyping.selfTyping.get()
				users: users[0]
			}

		# usernames = _.map messages, (message) -> return message.u.username

		last = users.pop()
		if users.length > 4
			last = t('others')
		# else
		usernames = users.join(', ')
		usernames = [usernames, last]
		return {
			multi: true
			selfTyping: MsgTyping.selfTyping.get()
			users: usernames.join " #{t 'and'} "
		}

Template.threadPage.events
	'scroll .wrapper': _.throttle (e, instance) ->
		if RoomHistoryManager.hasMore(@_id) is true and RoomHistoryManager.isLoading(@_id) is false
			if e.target.scrollTop is 0
				RoomHistoryManager.getMore(@_id)
	, 200

	'click .load-more > a': ->
		RoomHistoryManager.getMore(@_id)

	'click .new-message': (e) ->
		Template.instance().atBottom = true
		Template.instance().find('.input-message').focus()

	'click .see-all': (e, instance) ->
		instance.showUsersOffline.set(!instance.showUsersOffline.get())

	"click .edit-message": (e) ->
		Template.instance().chatMessages.edit(e.currentTarget.parentNode.parentNode)
		input = Template.instance().find('.input-message')
		Meteor.setTimeout ->
			input.focus()
		, 200

	"click .editing-commands-cancel > a": (e) ->
		Template.instance().chatMessages.clearEditing()

	"click .editing-commands-save > a": (e) ->
		chatMessages = Template.instance().chatMessages
		chatMessages.send(@_id, chatMessages.input)

	"click .mention-link": (e) ->
		channel = $(e.currentTarget).data('channel')
		term = $(e.currentTarget).data('term')
		if channel?
			FlowRouter.go 'channel', {name: channel, term: term}
			return

		Session.set('showUserProfile', true)
		Session.set('showUserInfo', $(e.currentTarget).data('username'))

	'click .image-to-download': (event) ->
		ChatMessage.update {_id: this._arguments[1]._id, 'urls.url': $(event.currentTarget).data('url')}, {$set: {'urls.$.downloadImages': true}}

	'click .delete-message': (event) ->
		message = @_arguments[1]
		msg = event.currentTarget.parentNode.parentNode
		instance = Template.instance()
		return if msg.classList.contains("system")
		swal {
			title: t('Are_you_sure')
			text: t('You_will_not_be_able_to_recover')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		}, ->
			swal
				title: t('Deleted')
				text: t('Your_entry_has_been_deleted')
				type: 'success'
				timer: 1000
				showConfirmButton: false

			instance.chatMessages.deleteMsg(message)
	'click .pin-message': (event) ->
		message = @_arguments[1]
		instance = Template.instance()

		if message.pinned
			instance.chatMessages.unpinMsg(message)
		else
			instance.chatMessages.pinMsg(message)

	'click .user-card-message': (e) ->
		roomData = Session.get('roomData' + this._arguments[1].rid)
		if roomData.t in ['c', 'p', 'd']
			Session.set('showUserProfile', true)
			console.log($(e.currentTarget).data('username'))
			Session.set('showUserInfo', $(e.currentTarget).data('username'))

	'click .user-view nav .back': (e) ->
		Session.set('showUserInfo', null)

	'click .user-view nav .pvt-msg': (e) ->
		Meteor.call 'createDirectMessage', Session.get('showUserInfo'), (error, result) ->
			if error
				return Errors.throw error.reason

			if result?.rid?
				FlowRouter.go('direct', { username: Session.get('showUserInfo') })

	'click button.load-more': (e) ->
		RoomHistoryManager.getMore @_id

	'click .toggle-favorite': (event) ->
		event.stopPropagation()
		event.preventDefault()
		Meteor.call 'toogleFavorite', @_id, !$('i', event.currentTarget).hasClass('favorite-room')

	'click .join': (event) ->
		event.stopPropagation()
		event.preventDefault()
		Meteor.call 'joinRoom', @_id

	'focus .input-message': (event) ->
		KonchatNotification.removeRoomNotification @_id

	'keyup .input-message': (event) ->
		Template.instance().chatMessages.keyup(@_id, event, Template.instance())

	'click .file': (event) ->
		$('.adding-files').toggle();

	'change #select-regular-file': (event, tmplate) ->
		e = event.originalEvent or event
		files = document.getElementById('select-regular-file').files[0]
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		console.log(files)

		fileUploadS3 files, 'regular', Template.instance().roomId

		$('.adding-files').hide();

	'change #select-notes': (event, tmpl) ->
		e = event.originalEvent or event
		files = document.getElementById('select-notes').files[0]
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		console.log(files)

		fileUploadS3 files, 'notes', Template.instance().roomId

		$('.adding-files').hide();

	'change #select-note-cards': (event, tmpl) ->
		e = event.originalEvent or event
		files = document.getElementById('select-note-cards').files[0]
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		console.log(files)

		fileUploadS3 files, 'note-cards', Template.instance().roomId

		$('.adding-files').hide();

	'keydown .input-message': (event) ->
		Template.instance().chatMessages.keydown(@_id, event, Template.instance())

	'click .message-form .icon-paper-plane': (event) ->
		input = $(event.currentTarget).siblings("textarea")
		Template.instance().chatMessages.send(Template.instance().roomId, input.get(0))
		event.preventDefault()
		event.stopPropagation()
		input.focus()
		input.get(0).updateAutogrow()

	"touchstart .message": (e, t) ->
		message = this._arguments[1]
		doLongTouch = ->
			mobileMessageMenu.show(message, t)

		t.touchtime = Meteor.setTimeout doLongTouch, 500

	"touchend .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"touchmove .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"touchcancel .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"click .upload-progress-item > a": ->
		Session.set "uploading-cancel-#{this.id}", true

	"click .unread-bar > a": ->
		readMessage.readNow(true)


Template.threadPage.onCreated ->
	# this.scrollOnBottom = true
	# this.typing = new msgTyping this.data._id
	path = window.location.pathname.split('/')
	if path[1] is 'group'
		typeLetter = 'p'
	else
		typeLetter = path[1][0]

	this.roomId = RoomManager.openedRooms[typeLetter + path[2]].rid
	this.showUsersOffline = new ReactiveVar false
	this.atBottom = true
	this.unreadCount = new ReactiveVar 0

Template.threadPage.onRendered ->
	this.chatMessages = new ChatMessages
	this.chatMessages.init(this.firstNode)
	# ScrollListener.init()
	console.log('thread ' + Template.instance().roomId)

	wrapper = this.find('.wrapper')
	newMessage = this.find(".new-message")

	template = this

	wrapperOffset = $('.messages-box > .wrapper').offset()

	onscroll = _.throttle ->
		template.atBottom = wrapper.scrollTop >= wrapper.scrollHeight - wrapper.clientHeight
	, 200

	updateUnreadCount = _.throttle ->
		firstMessageOnScreen = document.elementFromPoint(wrapperOffset.left+1, wrapperOffset.top+50)
		if firstMessageOnScreen?.id?
			firstMessage = ChatMessage.findOne firstMessageOnScreen.id
			if firstMessage?
				subscription = ChatSubscription.findOne rid: template.data._id
				template.unreadCount.set ChatMessage.find({rid: template.data._id, ts: {$lt: firstMessage.ts, $gt: subscription.ls}}).count()
			else
				template.unreadCount.set 0
	, 300

	Meteor.setInterval ->
		if template.atBottom
			wrapper.scrollTop = wrapper.scrollHeight - wrapper.clientHeight
			newMessage.className = "new-message not"
	, 100

	wrapper.addEventListener 'touchstart', ->
		template.atBottom = false

	wrapper.addEventListener 'touchend', ->
		onscroll()
		readMessage.enable()
		readMessage.read()

	wrapper.addEventListener 'scroll', ->
		template.atBottom = false
		onscroll()
		updateUnreadCount()

	wrapper.addEventListener 'mousewheel', ->
		template.atBottom = false
		onscroll()
		readMessage.enable()
		readMessage.read()

	wrapper.addEventListener 'wheel', ->
		template.atBottom = false
		onscroll()
		readMessage.enable()
		readMessage.read()

	# salva a data da renderização para exibir alertas de novas mensagens
	$.data(this.firstNode, 'renderedAt', new Date)

	webrtc.onRemoteUrl = (url) ->
		Session.set('flexOpened', true)
		Session.set('remoteVideoUrl', url)

	webrtc.onSelfUrl = (url) ->
		Session.set('flexOpened', true)
		Session.set('selfVideoUrl', url)

	RoomHistoryManager.getMoreIfIsEmpty this.data._id
