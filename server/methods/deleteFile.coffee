Meteor.methods
  deleteFile: (fileId) ->
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] deleteFile -> Invalid user"

    AWS.config.update
      accessKeyId: RocketChat.settings.get('AWSAccessKeyId')
      secretAccessKey: RocketChat.settings.get('AWSSecretAccessKey')

    file = fileCollection.findOne(fileId)
    url = file.url.split('.com/')
    fileKey = url[1]

    s3 = new AWS.S3()

    param = {
      Bucket: RocketChat.settings.get('AWSBucket'),
      Key: fileKey
    }

    s3.deleteObject(param, (err, data) ->
      if (err)
        console.log(err)
        return err
    )

    fileCollection.remove _id:fileId

    message = ChatMessage.findOne({'file._id': fileId}, {_id: 1, rid: 1})

    Meteor.call 'deleteMessage', message, (error, result) ->
      if error
        console.log error
        return error.reason
