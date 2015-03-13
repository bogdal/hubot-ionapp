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
#   hubot who's absent - Returns a list of users who are absent today.
#   hubot who'll be absent on <date> - Returns a list of users who will be absent on specified day.
#   hubot who's at home - Returns a list of users who are working at home.
#   hubot who'll be working at home on <date> - Returns a list of users who will be working at home on specified day.
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
