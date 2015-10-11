Slingshot.fileRestrictions 'fileUploads',
  allowedFileTypes: [
    'image/png'
    'image/jpeg'
    'image/gif'
    'application/pdf'
    'application/vnd.ms-excel'
    'application/vnd.msexcel'
    'application/excel'
    'application/vnd.ms-powerpoint'
    'application/vnd.msword'
    'application/msword'
    'text/csv'
    'text/rtf'
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    '.csv'
    'application/x-excel'
    'application/x-msexcel'
    'application/octet-stream'
    'application/unknown'
    'application/x-iwork-keynote-sffkey'
    'application/x-iwork-pages-sffpages'
    'application/x-iwork-numbers-sffnumbers'
    'application/vnd.apple.keynote'
    'application/vnd.apple.pages'
    'application/vnd.apple.numbers'
    'application/zip'
  ]
  maxSize: 10 * 1024 * 1024

Slingshot.createDirective 'fileUploads', Slingshot.S3Storage,
  bucket: RocketChat.settings.get('AWSBucket')
  AWSAccessKeyId: RocketChat.settings.get('AWSAccessKeyId')
  AWSSecretAccessKey: RocketChat.settings.get('AWSSecretAccessKey')
  acl: "bucket-owner-read"
  region: RocketChat.settings.get('AWSRegion')
  authorize: (file, metaContext) ->
    console.log(file)
    console.log(file.type)
    if !this.userId
      throw new Meteor.Error(error, reason)
    return true
  key: (file, metaContext) ->
    user = Meteor.users.findOne(this.userId)
    if metaContext.type is 'syllabus'
      return [metaContext.roomId, "/syllabus/", encodeURIComponent(file.name)].join("")
    else
      return [metaContext.roomId, "/", user.username, "/", new Date().getTime(), "/",encodeURIComponent(file.name)].join("")
