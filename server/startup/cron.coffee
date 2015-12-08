# Config and Start SyncedCron
SyncedCron.config
  collectionName: 'rocketchat_cron_history'

Meteor.startup ->
  Meteor.defer ->

    # Generate and save statistics every hour
    SyncedCron.add
      name: 'Generate and save statistics',
      schedule: (parser) -># parser is a later.parse object
        return parser.text 'every 1 hour'
      job: ->
        statistics = RocketChat.statistics.save()
        return

    SyncedCron.start()
