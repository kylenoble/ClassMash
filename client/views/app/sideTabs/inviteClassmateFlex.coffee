Template.inviteClassmateFlex.helpers
  selectedUsers: ->
    return Template.instance().selectedUsers.get()

  error: ->
    return Template.instance().error.get()

Template.inviteClassmateFlex.events
  'click .icon-invite': (e, instance) ->
    users = Template.instance().selectedUsers.get()
    email = $("#invite-email").val()
    if /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(email)
      users.push {'email': email}
      Template.instance().selectedUsers.set(users)
      email = $("#invite-email").val('')
    else
      toastr.error "Please enter a valid email address"

  'keydown #invite-email': (e, instance) ->
    users = Template.instance().selectedUsers.get()
    if e.keyCode is 13
      email = $("#invite-email").val()
      if /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(email)
        users.push {'email': email}
        Template.instance().selectedUsers.set(users)
        email = $("#invite-email").val('')
      else
        toastr.error "Please enter a valid email address"

  'click .remove-room-member': (e, instance) ->
    self = @

    users = Template.instance().selectedUsers.get()
    users = _.reject Template.instance().selectedUsers.get(), (_id) ->
      return _id is self.valueOf()

    Template.instance().selectedUsers.set(users)

    $('#channel-members').focus()

  'click header': (e, instance) ->
    SideNav.closeFlex ->
      instance.clearForm()

  'click .cancel-invite': (e, instance) ->
    SideNav.closeFlex ->
      instance.clearForm()

  'mouseenter header': ->
    SideNav.overArrow()

  'mouseleave header': ->
    SideNav.leaveArrow()

  'keydown input[type="text"]': (e, instance) ->
    Template.instance().error.set([])

  'click .send-invite': (e, instance) ->
    err = SideNav.validate()
    users = instance.selectedUsers.get()
    unless users.length > 0
      toastr.error "Please add a user before sending"
      return
    if not err
      Meteor.call 'sendClassmateInvite', instance.selectedUsers.get(), (err, result) ->
        if err
          console.log err
          if err.error is 'name-invalid'
            instance.error.set({ invalid: true })
            return
          if err.error is 'duplicate-name'
            instance.error.set({ duplicate: true })
            return
          else
            return toastr.error err.reason

        SideNav.closeFlex ->
          instance.clearForm()
					
    else
      console.log err
      instance.error.set({ fields: err })

Template.inviteClassmateFlex.onCreated ->
  instance = this
  instance.selectedUsers = new ReactiveVar []
  instance.selectedUserNames = {}
  instance.error = new ReactiveVar []
  instance.roomName = new ReactiveVar ''

  instance.clearForm = ->
    instance.error.set([])
    instance.roomName.set('')
    instance.selectedUsers.set([])
    instance.find('#channel-name').value = ''
    instance.find('#channel-members').value = ''
    instance.find('#channel-teacher').value = ''
    instance.find('#channel-name').value = ''
    instance.find('#channel-term').value = 'Select a Term'
