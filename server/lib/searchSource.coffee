SearchSource.defineSource 'schools', (searchText, options) ->
  lat = options.lat
  lon = options.lon

  options =
    sort: isoScore: -1
    limit: 20

  if searchText and lat and lon
    regExp = buildRegExp(searchText)
    selector =
      name: regExp
      pos: $within: $centerSphere: [
        [
          lat
          lon
        ]
        20.5 / 6371
      ]
  else if searchText
    regExp = buildRegExp(searchText)
    selector = name: regExp

  data = Schools.find(selector, options)
  {
    data: data.fetch()
    metadata: count: data.count()
  }

buildRegExp = (searchText) ->
  words = searchText.trim().split(/[ \-\:]+/)
  exps = _.map(words, (word) ->
    '(?=.*' + word + ')'
  )
  fullExp = exps.join('') + '.+'
  new RegExp(fullExp, 'i')
