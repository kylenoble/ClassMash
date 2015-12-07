Slingshot.fileRestrictions 'fileUploads',
  allowedFileTypes: null
  maxSize: 10 * 10 * 1024 * 1024

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
