# addingSchool = new ReactiveVar(false)
# lat = new ReactiveVar(null)
# lon = new ReactiveVar(null)
#
# fields = [ 'name' ]
#
# options =
#   lat: lat.get(),
#   lon: lat.get()

# SchoolSearch = new SearchSource('schools', fields, options)
#
# Template.schoolSearchBox.created = ->
#   $('.school-search-result').hide()
#
#   location = Meteor.setInterval (->
#     navigator.geolocation.getCurrentPosition (position) ->
#       lat.set(position.coords.latitude)
#       lon.set(position.coords.longitude)
#       return
#     return
#   ), 500

Template.schoolSearchBox.events
  'click .add-user-school': (e, template) ->
    code = $('#inputSchoolCode').val().trim()

    console.log(code)
    unless code.length > 0
      toastr.error("Don't forget to add a code")
      return

    Meteor.call 'checkSchoolCode', code, (error, response) ->
      if error
        toastr.error(error.reason)
      else
        Meteor.clearInterval(location)
        element = $("#login-card")
        element.removeClass("green-background")
        element.addClass("light-blue-background")
        element = $(".full-page-username")
        element.css('background-color', '#9BC4F2')
        $('body').css('background-color', '#9BC4F2')
        Session.set 'isAddingUserName', true

Template.schoolSearchBox.rendered = ->
  Session.set('registerInvite', false)

  # 'keyup #inputSchoolName': _.throttle(((e) ->
  #   options =
  #     lat: lat.get(),
  #     lon: lon.get()
  #   Meteor.clearInterval(location)
  #   text = $(e.target).val().trim()
  #   SchoolSearch.search text, options
  #   addingSchool.set(false)
  #   $('body').css('background-color', '#e74c3c')
  #   return
  # ), 200)
#
# Template.schoolSearchResult.helpers
#   errorContent: () ->
#     Session.get('errorContent')
#   error: () ->
#     Session.get('error')
#   stepTwo: () ->
#     Session.get('stepTwo')
#   stepThree: () ->
#     Session.get('stepThree')
#   getSchools: ->
#     SchoolSearch.getData
#       transform: (matchText, regExp) ->
#         matchText.replace regExp, '<b>$&</b>'
#       sort: isoScore: -1
#   isLoading: ->
#     SchoolSearch.getStatus().loading
#   showNoSchools: ->
#     if SchoolSearch.getMetadata().count < 1 && $('#inputSchoolName').val() != ''
#       return true
#     false
#   addSchool: () ->
#     addingSchool.get()
#
# Template.schoolSearchResult.events
#   'click .show-add-school': (event, instance) ->
#     event.preventDefault()
#     addingSchool.set(true)
#
#   'click .school-search-result': (event, instance) ->
#     event.preventDefault()
#     schoolDiv = document.getElementById(event.currentTarget.id)
#     schoolId = event.currentTarget.id
#     schoolName = $(schoolDiv).children('.school-search-result-name').text()
#
#     $('#inputSchoolName').val(schoolName)
#
#     $('.school-search-result').hide()
#     $(schoolDiv).show()
#
#     $(schoolDiv).addClass('selected-school')
#     Session.set('selectedSchoolId', schoolId)
#     Session.set('selectedSchoolName', schoolName)
#
#
#   'click .add-user-school': (event, instance) ->
#     event.preventDefault()
#     schoolId = Session.get('selectedSchoolId')
#     schoolName = Session.get('selectedSchoolName')
#     schoolNameInput = $('#inputSchoolName').val()
#     # Session.set('stepTwo',false)
#     # Session.set('stepThree',true)
#     console.log(schoolId + ' ' + schoolName)
#     if (
#       schoolId != '' and
#       schoolName != '' and
#       schoolNameInput != ''
#     )
#       Meteor.call 'userAddSchool', schoolId, schoolName, (error, response) ->
#         if error
#           toastr.error(error.reason)
#         else
#           Meteor.clearInterval(location)
#           element = $("#login-card")
#           element.removeClass("green-background")
#           element.addClass("light-blue-background")
#           element = $(".full-page-username")
#           element.css('background-color', '#3498DB')
#           $('body').css('background-color', '#3498DB')
#           Session.set 'isAddingUserName', true
#     else
#       toastr.error("Uhoh, You Forgot To Select A School")
#       ## Reset Search
#       Session.set('selectedSchoolId', '')
#       Session.set('selectedSchoolName', '')
#       $('#inputSchoolName').val('')
#
#   'click button.close': (event, instance) ->
#     event.preventDefault()
#     Session.set('error',false)
#     Session.set('message',false)
#
# Template.addSchoolForm.rendered = ->
#   schoolName = $('#inputSchoolName').val()
#   $('#addSchoolName').val(schoolName)
#
# Template.addSchoolForm.events
#   'click .add-school-button': (event, instance) ->
#     event.preventDefault()
#     schoolName = instance.find('#addSchoolName').value
#
#     if schoolName != ''
#       Meteor.call 'schoolsNewInsert', schoolName, (error, response) ->
#         if error
#           Session.set('error',true)
#           Session.set('errorContent',error.reason)
#       FlowRouter.go 'login'
#     else
#       Session.set('error',true)
#       Session.set('errorContent',
#         "Uhoh, doesn't seem like you added a school name")
#
#   'click button.close': (event, instance) ->
#     event.preventDefault()
#     Session.set('error',false)
