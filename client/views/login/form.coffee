Template.loginForm.helpers
	userName: ->
		return Meteor.user()?.username	

	addingSchool: ->
		return 'hidden' unless Template.instance().state.get() is 'add-school'		

	forgotPasswordActive: ->
		return 'hidden' unless Template.instance().state.get() is 'forgot-password'

	showName: ->
		return 'hidden' unless Template.instance().state.get() is 'register'

	showPassword: ->
		return 'hidden' unless Template.instance().state.get() in ['login', 'register']

	showConfirmPassword: ->
		return 'hidden' unless Template.instance().state.get() is 'register'

	showEmail: ->
		return 'hidden' unless Template.instance().state.get() in ['login', 'register', 'forgot-password', 'email-verification']

	showRegisterLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showForgotPasswordLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showBackToLoginLink: ->
		return 'hidden' unless Template.instance().state.get() in ['register', 'forgot-password', 'email-verification', 'add-school']

	btnLoginSave: ->
		switch Template.instance().state.get()
			when 'register'
				return t('Find Your School')
			when 'login'
				return t('Login')
			when 'email-verification'
				return t('Send_confirmation_email')
			when 'forgot-password'
				return t('Reset_password')

Template.loginForm.events
	'submit #login-card': (event, instance) ->
		event.preventDefault()

		button = $(event.target).find('button.login')
		RocketChat.Button.loading(button)

		formData = instance.validate()
		if formData
			if instance.state.get() is 'email-verification'
				Meteor.call 'sendConfirmationEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('We_have_sent_registration_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'forgot-password'
				Meteor.call 'sendForgotPasswordEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('We_have_sent_password_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'register'
				formData.email = formData.email.toLowerCase()
				console.log(formData)
				Meteor.call 'registerUser', formData, (error, result) ->
					RocketChat.Button.reset(button)
					console.log("register stuff")
					if error?
						if error.error is 'Email already exists.'
							toastr.error t 'Email_already_exists'
						else
							toastr.error error.reason
						return

					Meteor.loginWithPassword formData.email, formData.pass, (error) ->
						if error?.error is 'no-valid-email'
							toastr.success t('We_have_sent_registration_email')
							instance.state.set 'add-school'
							console.log('email validation')
						else
							element = $("#search-container")
							element.addClass("red-background") 
							element = $(".full-page")
							element.removeClass("green-background") 
							element.addClass("blue-background")     
							element.addClass("red-background")  		 
			else
				Meteor.loginWithPassword formData.email, formData.pass, (error) ->
					RocketChat.Button.reset(button)
					if error?
						if error.error is 'no-valid-email'
							instance.state.set 'email-verification'
						else
							toastr.error error.reason
						return
					FlowRouter.go 'index'

	'click .register': ->
		element = $("#login-card")
		element.removeClass("blue-background")
		element.addClass("green-background") 
		element = $(".full-page")
		element.removeClass("blue-background")    
		element.addClass("green-background")
		$('body').css('background-color', '#E74C3C')   		
		Template.instance().state.set 'register' 			

	'click .back-to-login': ->
		$('#inputSchoolName').val('')
		$('.school-search-result').hide()

		element = $("#login-card")
		element.removeClass("green-background")
		element.removeClass("red-background")
		element.addClass("blue-background") 
		element = $(".full-page")
		element.removeClass("green-background")
		element.removeClass("red-background")    
		element.addClass("blue-background")
		$('body').css('background-color', '#34495e')   		
		Template.instance().state.set 'login'		

	'click .forgot-password': ->
		element = $("#login-card")
		element.removeClass("green-background") 
		element.addClass("blue-background") 
		element = $(".full-page")    
		element.removeClass("green-background") 
		element.addClass("blue-background")  				
		Template.instance().state.set 'forgot-password'

Template.loginForm.onCreated ->
	console.log('hello')
	instance = @
	@state = new ReactiveVar('login')     

	@validate = ->
		formData = $("#login-card").serializeArray()
		console.log('validating')
		console.log(formData)
		formObj = {}
		validationObj = {}

		for field in formData
			formObj[field.name] = field.value

		if instance.state.get() isnt 'login'
			unless formObj['email'] and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(formObj['email'])
				validationObj['email'] = t('Invalid_email')

		if instance.state.get() isnt 'forgot-password'
			unless formObj['pass']
				validationObj['pass'] = t('Invalid_pass')

		if instance.state.get() is 'register'
			unless formObj['name']
				validationObj['name'] = t('Invalid_name')
			if formObj['confirm-pass'] isnt formObj['pass']
				validationObj['confirm-pass'] = t('Invalid_confirm_pass')

		$("#login-card input").removeClass "error"
		unless _.isEmpty validationObj
			button = $('#login-card').find('button.login')
			RocketChat.Button.reset(button)
			$("#login-card h2").addClass "error"
			for key of validationObj
				$("#login-card input[name=#{key}]").addClass "error"
			return false

		$("#login-card h2").removeClass "error"
		$("#login-card input.error").removeClass "error"
		return formObj		

Template.loginForm.onRendered ->
	if this.state.get() is 'login'
		element = $("#login-card")
		element.addClass("blue-background") 
		element = $(".full-page")    
		element.addClass("blue-background")
		$('body').css('background-color', '#34495e')     

	if this.state.get() is 'register'
		element = $("#login-card")
		element.addClass("green-background") 
		element = $(".full-page")    
		element.addClass("green-background") 

	if this.state.get() is 'add-school'
		element = $("#login-card")
		element.addClass("red-background") 
		element = $(".full-page")    
		element.addClass("red-background")  		  	
		
	Tracker.autorun =>
		switch this.state.get()
			when 'login', 'forgot-password', 'email-verification'
				Meteor.defer ->
					$('input[name=email]').select().focus()

			when 'register'
				Meteor.defer ->
					$('input[name=name]').select().focus()

			when 'add-school'
				Meteor.defer ->
					$('input[name=school]').select().focus()


