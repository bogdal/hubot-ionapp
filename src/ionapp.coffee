# Description:
#   Integration with IONAPP service.
#
# Dependencies:
#   "chrono-node": "~1.0.2",
#   "coffee-script": "~1.6",
#   "moment": "~2.9.0"
#
# Configuration:
#   HUBOT_IONAPP_COMPANY_NAME
#   HUBOT_IONAPP_AUTH_TOKEN
#
# Commands:
#   hubot who's absent - Returns a list of users who are absent.
#   hubot who'll be absent on <date> - Returns a list of users who will be absent on specified day.
#   hubot who's at home - Returns a list of users who are working at home.
#   hubot who'll be working at home on <date> - Returns a list of users who will be working at home on specified day.
#   hubot show me the team - Displays a list of IONapp team members and chat users mapped with them.
#   hubot remember me as <username> - Maps current user to the IONapp username.
#   hubot I will be working at home on <date/date range> - Adds a home office requests.
#
# Author:
#   bogdal

chrono = require 'chrono-node'
moment = require 'moment'
companyName = process.env.HUBOT_IONAPP_COMPANY_NAME
authToken = process.env.HUBOT_IONAPP_AUTH_TOKEN
appUrl = "https://#{companyName}.ionapp.com"

module.exports = (robot) ->

  robot.respond /who('s| is) absent$/i, (msg) ->
    renderResponse timeOff, msg

  robot.respond /who('s|'ll be| is| will be) absent (on)?(.*)$/i, (msg) ->
    dateString = msg.match[3]
    renderResponse timeOff, msg, dateString

  robot.respond /who('s| is| works)( working)? (at|from) home$/i, (msg) ->
    renderResponse homeOffice, msg

  robot.respond /who('s|'ll be|'ll work| is| will be| will work)( working)? (at|from) home (on)?(.*)$/i, (msg) ->
    dateString = msg.match[5]
    renderResponse homeOffice, msg, dateString

  robot.respond /show me the team$/i, (msg) ->
    url = "/api/users/?format=json"
    requestGet(msg, url) (err, res, body) ->
      json = JSON.parse(body)
      usersMap = {}
      for own key, user of robot.brain.users()
        if user.ionappUsername
          usersMap[user.ionappUsername] = user
      buildMessage = (item) ->
        message = " - #{item['first_name']} #{item['last_name']} (#{item['username']})"
        systemUser = usersMap[item['username']]
        if systemUser
          message += " as @#{systemUser['name']}"
        message
      msg.send "Here is a list of IONapp team members:\n" + (buildMessage item for item in json['results']).join('\n')

  robot.respond /remember me as ([a-z0-9-.]+)\s*$/i, (msg) ->
    url = "/api/users/?format=json"
    requestGet(msg, url) (err, res, body) ->
      json = JSON.parse(body)
      username = msg.match[1].toLowerCase()
      if username == 'john.doe'
        msg.message.user.ionappUsername = null
        msg.send "I got it. See No Evil, Hear No Evil."
        return
      for item in json['results']
        if username == item['username']
          name = "#{item['first_name']} #{item['last_name']}"
          msg.message.user.ionappUsername = username
          msg.send "Roger that. I will remember you as #{name}."
          return
      msg.send "WAT? Are you sure '#{username}' is a correct username?"

  robot.respond /I('ll| will) ((be working|work) (at|from)|be staying|stay) home (on)?(.*)$/i, (msg) ->
    dateString = msg.match[6]
    date = chrono.parse dateString
    parsedResult = date[0]
    if not parsedResult
      msg.send "Not sure what#{dateString} means"
      return
    if not msg.message.user.ionappUsername
      msg.send "Sorry buddy! I don't know who you are."
      return
    baseUrl = "/api/schedule_occurences/?format=json"
    url = baseUrl + "&user=#{msg.message.user.ionappUsername}"
    startDate = moment(parsedResult.start.date()).format 'YYYY-MM-DD'
    if parsedResult.end
      endDate = moment(parsedResult.end.date()).format 'YYYY-MM-DD'
      url += "&since=#{startDate}&until=#{endDate}"
      messageDate = "from #{startDate} to #{endDate}"
    else
      url += "&on=#{startDate}"
      messageDate = "#{startDate}"
    requestGet(msg, url) (err, res, body) ->
      json = JSON.parse(body)
      for item in json
        if item['location']['name'] != 'home'
          data = {
            'owner': msg.message.user.ionappUsername,
            'start_date': item['start_date'],
            'end_date': item['end_date'],
            'location': 'home',
            'comment': 'added by hubot'}
          requestPost(msg, baseUrl, JSON.stringify(data)) (err, res, body) ->
            if err
              msg.send "Ops! Houston, we have a problem: #{err}"
      msg.send "OK. I'm adding a home office requests (#{messageDate})"

timeOff = (msg, dateString) ->
  url = "/api/timeoff_requests/?format=json&status=pending,accepted&on=#{dateString}"
  requestGet(msg, url) (err, res, body) ->
      json = JSON.parse(body)
      if json['detail']
        msg.send json['detail']
        return
      if not json['count']
        msg.send "Hurray! No one planned a day off on #{dateString}."
      else
        buildMessage = (item) ->
          owner = item['owner']
          message = " - #{owner['first_name']} #{owner['last_name']}"
          end_date = item['end_date'].slice(0, 10)
          if end_date != dateString
            message += " (until #{end_date})"
          if item['status'] != 'Accepted'
            message += " (#{item['status']})"
          message
        msg.send "List of absent users on #{dateString}:\n" + (buildMessage item for item in json['results']).join('\n')

homeOffice = (msg, dateString) ->
  url = "/api/schedule_occurences/?format=json&on=#{dateString}"
  requestGet(msg, url) (err, res, body) ->
      json = JSON.parse(body)
      home_office = []
      for request in json
        if request['location']['name'] == 'home'
          home_office.push(request)
      if not home_office.length
        msg.send "Hurray! No one planned work at home on #{dateString}."
      else
        buildMessage = (item) ->
          owner = item['owner']
          " - #{owner['first_name']} #{owner['last_name']}"
        msg.send "Users who scheduled a home office on #{dateString}:\n" + (buildMessage item for item in home_office).join('\n')

requestGet = (msg, url) ->
  msg.http(appUrl + url)
    .headers(Authorization: "Token #{authToken}")
    .get()

requestPost = (msg, url, data) ->
  msg.http(appUrl + url)
    .headers(
      Authorization: "Token #{authToken}",
      "Content-type": "application/json")
    .post(data)

renderResponse = (func, msg, dateString=null) ->
  if not companyName or not authToken
    msg.send 'Configure this script by setting the HUBOT_IONAPP_COMPANY_NAME and HUBOT_IONAPP_AUTH_TOKEN environment variables'
    return
  if dateString
    date = chrono.parseDate dateString
    if not date
      msg.send "Not sure what#{dateString} means"
      return
  else
    date = new Date
  func msg, moment(date).format 'YYYY-MM-DD'
