Template.landingPage.helpers
  joinWaitlist: ->
    return Template.instance().waitlistForm.get()

Template.landingPage.events
  'click .nav-btn a': (event) ->
    event.preventDefault();
    $('.landing-page').toggleClass 'nav-active'


  "click .show-waitlist-form": (event, template) ->
    $(".landing-page .logo").css("top", "-10px")
    Template.instance().waitlistForm.set(true)

  "click .close-waitlist-signup": (event, template) ->
    $(".landing-page .logo").css("top", "30px")
    Template.instance().waitlistForm.set(false)

  "click .join-waitlist-signup": (event, template) ->
    validationObj = {}

    termsAgree = $("#termsAgree").is(':checked')
    email = $("#waitlistEmail").val()
    school = $("#waitlistSchool").val()
    name = $("#waitlistName").val()

    unless $("#termsAgree").is(':checked')
      validationObj['termsAgree'] = "Please Accept Terms to Join"

    unless email and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(email)
      validationObj['email'] = t('Invalid_email')

    unless name
      validationObj['name'] = t('Invalid_name')

    unless school
      validationObj['school'] = t('The School Must Not Be Empty')

    unless _.isEmpty validationObj
      for key of validationObj
        console.log(key)
        console.log(validationObj[key])
        toastr.error(validationObj[key])
      return false

    Meteor.call "schoolsNewInsert", email, name, school, (error, result) ->
      if error
        toastr.error(error)
        console.log "error", error
        return
      if result
        toastr.success('Joined Waitlist')
        $(".landing-page .logo").css("top", "30px")

    Template.instance().waitlistForm.set(false)

Template.landingPage.onCreated ->
  this.waitlistForm = new ReactiveVar false

  # add class to landing-page template for animation purposes
  setTimeout (->
    $('.landing-page').addClass 'animate-in'
    return
  ), 100

  $('body').on 'scroll', ->
    if $('.hero').offset().top < 0
      $('header').addClass 'fixed'
    else
      $('header').removeClass 'fixed'
    return
