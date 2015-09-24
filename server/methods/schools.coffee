Meteor.methods
  checkSchoolCode: (code) ->
    school = Schools.findOne(code: code)
    if school
      Meteor.users.update(
        {_id: Meteor.userId()}, {
          $set: {
            'profile.school':
              {_id: school._id._str, name: school.name}
          }
        }
      )

      {_id: Meteor.userId()}
      return
    else
      throw new Meteor.Error 203, 'Incorrect Code'


  userAddSchool: (schoolId, schoolName) ->
    # user = Meteor.users.findOne(
    #   { emails: { $elemMatch: { address: "kyle.noble@me.com" } } }
    # )
    check(Meteor.userId(), String)
    check(schoolName, String)
    check(schoolId, String)

    schoolId = schoolId.split("\"")

    oid = new Meteor.Collection.ObjectID(schoolId[1])
    school = Schools.findOne(oid)

    Meteor.users.update(
      {_id: Meteor.userId()}, {
        $set: {
          'profile.school':
            {_id: school._id._str, name: school.name}
        }
      }
    )

    {_id: Meteor.userId()}

  schoolsNewInsert: (schoolName) ->
    user = Meteor.user()

    check(user._id, String)

    schoolsNew = {
      created_at: new Date()
      emails: user.emails[0].address
      schoolName: schoolName
    }

    Meteor.users.remove(user._id)

    schoolsNewId = SchoolsNew.insert(schoolsNew)

    {_id: schoolsNewId}
