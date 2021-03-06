Template.message.helpers
  own: ->
    return 'own' if this.u?._id is Meteor.userId()

  time: ->
    return moment(this.ts).format('HH:mm')

  date: ->
    return moment(this.ts).format('LL')

  isTemp: ->
    if @temp is true
      return 'temp'
    return

  body: ->
    switch this.t
      when 'r'  then t('Room_name_changed', { room_name: this.msg, user_by: this.u.username })
      when 'au' then t('User_added_by', { user_added: this.msg, user_by: this.u.username })
      when 'ru' then t('User_removed_by', { user_removed: this.msg, user_by: this.u.username })
      when 'ul' then t('User_left', { user_left: this.u.username })
      when 'nu' then t('User_added', { user_added: this.u.username })
      when 'uj' then t('User_joined_channel', { user: this.u.username })
      when 'wm' then t('Welcome', { user: this.u.username })
      when 'rm' then t('Message_removed', { user: this.u.username })
      when 'rtc' then RocketChat.callbacks.run 'renderRtcMessage', this
      when 'pdf', 'csv', 'vnd.ms-excel', 'vnd.msword', 'vnd.ms-powerpoint', 'pages', 'numbers', 'key', 'docx', 'mp3' then (
        this.html = this.msg
        message = RocketChat.callbacks.run 'renderMessage', this
        return this.html
        )
      when 'image' then (
        this.html = this.msg
        message = RocketChat.callbacks.run 'renderMessage', this
        return this.html
        )
      else
        this.html = this.msg
        if _.trim(this.html) isnt ''
          this.html = _.escapeHTML this.html
        message = RocketChat.callbacks.run 'renderMessage', this
        this.html = message.html.replace /\n/gm, '<br/>'
        return this.html

  system: ->
    return 'system' if this.t in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj', 'rm']
  edited: ->
    return @ets and @t not in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj', 'rm']
  pinned: ->
    return this.pinned
  canEdit: ->
    return RocketChat.settings.get 'Message_AllowEditing'
  canDelete: ->
    return RocketChat.settings.get 'Message_AllowDeleting'
  canPin: ->
    return RocketChat.settings.get 'Message_AllowPinning'
  showEditedStatus: ->
    return RocketChat.settings.get 'Message_ShowEditedStatus'

Template.message.onViewRendered = (context) ->
  view = this
  this._domrange.onAttached (domRange) ->
    lastNode = domRange.lastNode()
    if lastNode.previousElementSibling?.dataset?.date isnt lastNode.dataset.date
      $(lastNode).addClass('new-day')
      $(lastNode).removeClass('sequential')
    else if lastNode.previousElementSibling?.dataset?.username isnt lastNode.dataset.username
      $(lastNode).removeClass('sequential')

    if lastNode.nextElementSibling?.dataset?.date is lastNode.dataset.date
      $(lastNode.nextElementSibling).removeClass('new-day')
      $(lastNode.nextElementSibling).addClass('sequential')
    else
      $(lastNode.nextElementSibling).addClass('new-day')
      $(lastNode.nextElementSibling).removeClass('sequential')

    if lastNode.nextElementSibling?.dataset?.username isnt lastNode.dataset.username
      $(lastNode.nextElementSibling).removeClass('sequential')

    ul = lastNode.parentElement
    wrapper = ul.parentElement

    if context.urls?.length > 0 and Template.oembedBaseWidget? and RocketChat.settings.get 'API_Embed'
      for item in context.urls
        do (item) ->
          urlNode = lastNode.querySelector('.body a[href="'+item.url+'"]')
          titleNode = lastNode.querySelector('.linkable-title')
          if urlNode? and !titleNode
            $(urlNode).replaceWith Blaze.toHTMLWithData Template.oembedBaseWidget, item

    if not lastNode.nextElementSibling?
      if lastNode.classList.contains('own') is true
        view.parentView.parentView.parentView.parentView.parentView.templateInstance?().atBottom = true
      else
        if view.parentView.parentView.parentView.parentView.parentView.templateInstance?().atBottom isnt true
          newMessage = document.querySelector(".new-message")
          if newMessage
            newMessage.className = "new-message"

clearActive = () ->
  $('.room-icons .icon-home').removeClass('active')
  $('.room-icons .icon-docs').removeClass('active')
  $('.room-icons .icon-calendar').removeClass('active')
  $('.room-icons .icon-user').removeClass('active')
  $('.room-icons .icon-doc').removeClass('active')
  $('.room-icons .icon-notebook').removeClass('active')
  $('.room-icons .icon-graph').removeClass('active')
  $('.room-icons .icon-book-open').removeClass('active')
  Session.set('isClassroom', false)
  Session.set('isCalendar', false)
  Session.set('isFiles', false)
  Session.set('isProfile', false)
  Session.set('isFileDetails', false)
  Session.set('isEventDetails', false)
  Session.set('isFileHistory', false)
  Session.set('isAssignments', false)
  Session.set('isSearch', false)
  if Session.get('isThread')
    Session.set('isThread', false)
