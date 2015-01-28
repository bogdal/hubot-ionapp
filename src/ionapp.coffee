# Description:
#   Integration with IONAPP service.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_IONAPP_COMPANY_NAME
#   HUBOT_IONAPP_AUTH_TOKEN
#
# Commands:
#   hubot who's absent - Returns a list of users who are absent at work.
#   hubot who'll be absent tomorrow - Returns a list of users who will be absent tomorrow.
#   hubot who'll be absent on <date> - Returns a list of users who will be absent on specified day (yyyy-mm-dd).
#
# Author:
#   bogdal

chrono = require 'chrono-node'
moment = require 'moment'
companyName = process.env.HUBOT_IONAPP_COMPANY_NAME
authToken = process.env.HUBOT_IONAPP_AUTH_TOKEN
appUrl = "https://#{companyName}.ionapp.com"

module.exports = (robot) ->
  robot.respond /who's absent$/i, (msg) ->
    timeOff msg, new Date

  robot.respond /who('s|'ll be| is| will be) absent (on)?(.*)$/i, (msg) ->
    dateString = msg.match[3]
    date = chrono.parseDate dateString
    if date
      timeOff msg, date
    else
      msg.send "Not sure what #{dateString} means"

timeOff = (msg, date) ->
  if not companyName or not authToken
    msg.send 'Configure this script by setting the HUBOT_IONAPP_COMPANY_NAME and HUBOT_IONAPP_AUTH_TOKEN environment variables'
    return

  dateString = moment(date).format 'YYYY-MM-DD'
  msg.http(appUrl + "/api/timeoff_requests/?format=json&status=pending,accepted&on=#{dateString}")
    .headers(Authorization: "Token #{authToken}")
    .get() (err, res, body) ->
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
          if item['is_home_office']
            message += " - Home office"
          if item['status'] != 'Accepted'
            message += " (#{item['status']})"
          message

        msg.send "List of absent users on #{dateString}:\n" + (buildMessage item for item in json['results']).join('\n')
