Meteor.methods
  sendClassmateInvite: (emails) ->
    unless Meteor.userId()
      return

    user = Meteor.user()
    url = Meteor.absoluteUrl()
    schoolId = user.profile.school._id
    oid = new Meteor.Collection.ObjectID(schoolId)

    school = Schools.findOne oid

    SSR.compileTemplate( 'htmlInviteEmail', Assets.getText( 'email-invite.html' ) )

    emailData = {
      name: user.name,
      landingPage: url + 'images/landing-back.png',
      url: url,
      css: url + 'css/invite.css',
      code: school.code,
      register: url + 'register'
    }

    console.log emailData

    _.each emails, (email) ->
      Email.send({
        to: email.email,
        from: "noreply@classmash.com",
        subject: user.name + " has invited you to chat and collaborate on ClassMash",
        html: SSR.render( 'htmlInviteEmail', emailData )
      })
