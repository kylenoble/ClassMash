# Meteor.startup ->
#   RocketChat.MessageAction.addButton
#     id: 'jump-to-search-message'
#     icon: 'icon-right-hand'
#     i18nLabel: 'Jump_to_message'
#     action: (event, instance) ->
#       message = @_arguments[1]
#       $('.message-dropdown:visible').hide()
#       RoomHistoryManager.getSurroundingMessages(message, 50)
#
#     order: 100


Template.messageSearch.helpers
  tSearchMessages: ->
    return "Enter Search Term"

  searchResultMessages: ->
    return Template.instance().searchResult.get()?.messages

  hasMore: ->
    return Template.instance().hasMore.get()

  currentSearchTerm: ->
    return Template.instance().currentSearchTerm.get()

  ready: ->
    return Template.instance().ready.get()

Template.messageSearch.events
  "keydown .morphsearch-input": (e) ->
    amplitude.logEvent("MESSAGE_SEARCH")
    $('.morphsearch').addClass('open')
    if e.keyCode is 13
      e.preventDefault()

  "keyup .morphsearch-input": _.debounce (e, t) ->
    value = e.target.value.trim()
    if value is '' and t.currentSearchTerm.get()
      t.currentSearchTerm.set ''
      t.searchResult.set undefined
      t.hasMore.set false
      return
    else if value is t.currentSearchTerm.get()
      return

    t.hasMore.set true
    t.limit.set 20
    t.search()
  , 500

  'click .morphsearch-close': (e, t) ->
    $('.morphsearch').removeClass('open')
    $('.morphsearch').removeClass('search')
    $('.morphsearch-input').val('')
    Session.set('isSearch', false)

  'click .message-cog': (e, t) ->
    e.stopPropagation()
    e.preventDefault()
    message_id = $(e.currentTarget).closest('.message').attr('id')
    $('.message-dropdown:visible').hide()
    $(".search-messages-list \##{message_id} .message-dropdown").remove()
    message = Blaze.getData($("\.search-messages-list ##{message_id}")?[0])?._arguments?[1]
    if message
      actions = RocketChat.MessageAction.getButtons message
      el = Blaze.toHTMLWithData Template.messageDropdown, { actions: actions }
      $(".search-messages-list \##{message_id} .message-cog-container").append el
      dropDown = $(".search-messages-list \##{message_id} .message-dropdown")
      dropDown.show()

  'scroll .morphsearch-content': _.throttle (e, t) ->
    if e.target.scrollTop >= e.target.scrollHeight - e.target.clientHeight
      t.limit.set(t.limit.get() + 20)
      t.search()
  , 200

Template.messageSearch.onCreated ->
  @currentSearchTerm = new ReactiveVar ''
  @searchResult = new ReactiveVar

  @hasMore = new ReactiveVar true
  @limit = new ReactiveVar 20
  @ready = new ReactiveVar true

  @search = =>
    @ready.set false
    value = @$('.morphsearch-input').val()
    Tracker.nonreactive =>
      Meteor.call 'messageSearch', value, Session.get('openedRoom'), @limit.get(), (error, result) =>
        @currentSearchTerm.set value
        @ready.set true
        if result? and (result.messages?.length > 0 or result.users?.length > 0 or result.channels?.length > 0)
          @searchResult.set result
          if result.messages?.length + result.users?.length + result.channels?.length < @limit.get()
            @hasMore.set false
        else
          @searchResult.set()
