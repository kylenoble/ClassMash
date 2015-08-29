Slingshot.fileRestrictions 'fileUploads',
  allowedFileTypes: [
    'image/png'
    'image/jpeg'
    'image/gif'
  ]
  maxSize: 10 * 1024 * 1024

Slingshot.createDirective 'fileUploads', Slingshot.S3Storage,
  bucket: RocketChat.settings.get('AWSBucket')
  AWSAccessKeyId: RocketChat.settings.get('AWSAccessKeyId')
  AWSSecretAccessKey: RocketChat.settings.get('AWSSecretAccessKey')
  acl: "public-read"
  region: RocketChat.settings.get('AWSRegion')
  authorize: (file, metaContext) ->
    if !this.userId
      message = "Please login before posting files"
      throw new Meteor.Error("Login Required", message)
    return true;
  key: (file, metaContext) ->
    user = Meteor.users.findOne(this.userId)
    return [metaContext.roomId, "/", user.username, "/", file.name].join("")
