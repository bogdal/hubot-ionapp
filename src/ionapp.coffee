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

companyName = process.env.HUBOT_IONAPP_COMPANY_NAME
authToken = process.env.HUBOT_IONAPP_AUTH_TOKEN
appUrl = "https://#{companyName}.ionapp.com"

module.exports = (robot) ->
  robot.respond /who's absent$/i, (msg) ->
    timeOff msg, parseDate new Date()

  robot.respond /who'll be absent tomorrow$/i, (msg) ->
    timeOff msg, parseDate new Date(+new Date() + 86400000)

  robot.respond /who'll be absent on(\s(19\d{2}|20\d{2}).(0?[1-9]|1[0-2]).(0?[1-9]|[1-2][0-9]|3[0-1]))?$/i, (msg) ->
    timeOff msg, msg.match[1].trim()

timeOff = (msg, date_on) ->
  if not companyName or not authToken
    msg.send 'Configure this script by setting the HUBOT_IONAPP_COMPANY_NAME and HUBOT_IONAPP_AUTH_TOKEN environment variables'
    return

  msg.http(appUrl + "/api/timeoff_requests/?format=json&status=Accepted&on=#{date_on}")
    .headers(Authorization: "Token #{authToken}")
    .get() (err, res, body) ->
      json = JSON.parse(body)
      if json['detail']
        msg.send json['detail']
        return
      if not json['count']
        msg.send "Hurray. No one planned day off."
      else
        buildMessage = (item) ->
          owner = item['owner']
          message = " - #{owner['first_name']} #{owner['last_name']}"

          end_date = item['end_date'].slice(0, 10)
          if date_on != end_date
            message += " (until #{end_date})"

          if item['is_home_office']
            message += " - Home office"
          message

        msg.send "List of absent users on '#{date_on}':"
        msg.send (buildMessage item for item in json['results']).join('\n')

parseDate = (date) ->
  day = ('00' + date.getDate()).slice(-2)
  month = ('00' + date.getMonth() + 1).slice(-2)
  year = date.getFullYear()
  "#{year}-#{month}-#{day}"
