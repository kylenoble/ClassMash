Template.landingPage.helpers
  joinWaitlist: ->
    return Template.instance().waitlistForm.get()

Template.landingPage.events
  "click .show-waitlist-form": (event, template) ->
    Template.instance().waitlistForm.set(true)

Template.landingPage.onCreated ->
  this.waitlistForm = new ReactiveVar false
