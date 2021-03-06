# Deny Account.createUser in client
Accounts.config { forbidClientAccountCreation: true }

Accounts.emailTemplates.siteName = "ClassMash"
Accounts.emailTemplates.from = "ClassMash <no-reply@classmash.com>"

verifyEmailText = Accounts.emailTemplates.verifyEmail.text

Accounts.emailTemplates.verifyEmail.subject = (user) ->
  return "Welcome to ClassMash!"

Accounts.emailTemplates.verifyEmail.html = (user, url) ->
  url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
  html = """
    Thank you for registering.  Please click below to verify your email address: \r\n\n
    <br>
    <br>
    <a href="#{url}">
      <button style="
        background-color: #5dca8b;
        border: solid 1px #5dca8b;
        color: white;
        padding: 9px 12px;
        font-weight: 500;
        font-size: 13px;
        margin: 4px;
        word-spacing: 0;
        border-radius: 5px;
        line-height: 16px;
        cursor: pointer;">Verify Email</button>
      </a>
  """
  return html

resetPasswordText = Accounts.emailTemplates.resetPassword.text
Accounts.emailTemplates.resetPassword.text = (user, url) ->
  url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
  verifyEmailText user, url

Accounts.onCreateUser (options, user) ->
  # console.log 'onCreateUser ->',JSON.stringify arguments, null, '  '
  # console.log 'options ->',JSON.stringify options, null, '  '
  # console.log 'user ->',JSON.stringify user, null, '  '

  RocketChat.callbacks.run 'beforeCreateUser', options, user

  user.status = 'offline'
  user.active = not RocketChat.settings.get 'Accounts_ManuallyApproveNewUsers'

  # when inserting first user, set admin: true
  unless Meteor.users.findOne()
    user.admin = true

  if not user?.name? or user.name is ''
    if options.profile?.name?
      user.name = options.profile?.name

  if user.services?
    for serviceName, service of user.services
      if not user?.name? or user.name is ''
        if service.name?
          user.name = service.name
        else if service.username?
          user.name = service.username

      if not user.emails? and service.email?
        user.emails = [
          address: service.email
          verified: true
        ]

  Meteor.defer ->
    RocketChat.callbacks.run 'afterCreateUser', options, user

  return user


Accounts.validateLoginAttempt (login) ->
  login = RocketChat.callbacks.run 'beforeValidateLogin', login

  if login.allowed isnt true
    return login.allowed

  if login.user?.active isnt true
    throw new Meteor.Error 'inactive-user', TAPi18next.t 'project:User_is_not_activated'
    return false

  if login.type is 'password' and RocketChat.settings.get('Accounts_EmailVerification') is true
    validEmail = login.user.emails.filter (email) ->
      return email.verified is true

    if validEmail.length is 0
      throw new Meteor.Error 'no-valid-email'
      return false

  Meteor.users.update {_id: login.user._id}, {$set: {lastLogin: new Date}}
  Meteor.defer ->
    RocketChat.callbacks.run 'afterValidateLogin', login

  return true
