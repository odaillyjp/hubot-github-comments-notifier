# Description:
#   An HTTP Listener that notifies about new Github issues and pull request comments
#
# Configuration:
#   You will have to do the following:
#   1. Create a new webhook for your `myuser/myrepo` repository at:
#      https://github.com/myuser/myrepo/settings/hooks/new
#
#   2. Select the individual events to minimize the load on your Hubot.
#
#   3. Add the url: <HUBOT_URL>:<PORT>/hubot/gh-comments?room=<room>
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/gh-comments?room=<room>
#
# Notes:
#   None
#
# Authors:
#   odaillyjp

url           = require('url')
querystring   = require('querystring')
eventTypes    = ['issues', 'pull_request']

module.exports = (robot) ->
  robot.router.post "/hubot/gh-comments", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = req.body
    room = query.room
    eventType = req.headers["x-github-event"]

    try
      if eventType in eventTypes
        notifierComment data, eventType, (msg) ->
          robot.messageRoom room, msg
      else
        console.log "Github comments notifier info: Ignoring #{eventType} event."
    catch error
      console.log "Github comments notifier error: #{error}."

    res.end ""

notifierComment = (data, eventType, callback) ->
  if eventTypeActions[eventType]?
    eventTypeActions[eventType](data, callback)
  else
    console.log "Github comments notifier warn: Undefine #{eventType} event."

eventTypeActions =
  issues: (data, callback) ->
    analyzeData(data, 'issue', callback)
  pull_request: (data, callback) ->
    analyzeData(data, 'pull_request', callback)

analyzeData = (data, eventType, callback)
  if eventActions[data.action]?
    eventActions[data.action](data[eventType], data[comment], eventType, callback)
  else
    console.log "Github comments notifier warn: Undefine #{data.action} action."

eventActions =
  opened: (dataType, comment, eventType, callback) ->
    messageData =
      user:      dataType.user.login
      action:    'opened'
      eventType: eventType
      url:       comment.html_url
      title:     dataType.title
      body:      dataType.body
    buildMessage(messageData, callback)

  created: (dataType, comment, eventType, callback) ->
    messageData =
      user:      comment.user.login
      action:    'commented on'
      eventTyoe: eventType
      url:       comment.html_url
      title:     dataType.title
      body:      dataType.body
    buildMessage(messageData, callback)

  closed: (dataType, comment, eventType, callback) ->
    messageData =
      user:      dataType.user.login
      action:    'closed'
      eventType: eventType
      url:       comment.html_url
      title:     dataType.title
      body:      dataType.body
    buildMessage(messageData, callback)

  reopened: (dataType, comment, eventType, callback) ->
    messageData =
      user:      dataType.user.login
      action:    'reopened'
      eventType: eventType
      url:       comment.html_url
      title:     dataType.title
      body:      dataType.body
    buildMessage(messageData, callback)

buildMessage = (data, callback) ->
  callback "#{data.user} #{data.action} #{data.eventType} #{data.url} #{data.title}\n#{data.body}"
