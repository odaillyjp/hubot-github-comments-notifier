# Description:
#   An HTTP Listener that notifies about new Github issues and pull request comments
#
# Dependencies:
#   "url"         : "~0.7.9"
#   "querystring" : "~0.2.0"
#
# Configuration:
#   You will have to do the following:
#   1. Create a new webhook for your `myuser/myrepo` repository at:
#      https://github.com/myuser/myrepo/settings/hooks/new
#
#   2. Add the url: <HUBOT_URL>:<PORT>/hubot/gh-comments?room=<room>
#
#   3. Add the event trigger: "Send me everything" or
#      select "Pull request", "Pull request review comment", "Issues", "Issue comment" events
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
eventTypes    = ['issues', 'issue_comment', 'pull_request', 'pull_request_review_comment']

module.exports = (robot) ->
  robot.router.post "/hubot/gh-comments", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = JSON.parse(req.body.payload)
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
    console.log "Github comments notifier warn: Undefined #{eventType} event."

eventTypeActions =
  issues: (data, callback) ->
    analyzeData(data, 'issue', callback)
  issue_comment: (data, callback) ->
    analyzeData(data, 'issue', callback)
  pull_request: (data, callback) ->
    analyzeData(data, 'pull_request', callback)
  pull_request_review_comment: (data, callback) ->
    eventActions.reviewed(data, 'pull_request', callback)

analyzeData = (data, eventType, callback) ->
  if eventActions[data.action]?
    eventActions[data.action](data, eventType, callback)
  else
    console.log "Github comments notifier warn: Undefined #{data.action} action."

eventActions =
  opened: (data, eventType, callback) ->
    messageData =
      user:      data[eventType].user.login
      action:    'opened'
      eventType: eventType
      url:       data[eventType].html_url
      title:     data[eventType].title
      body:      data[eventType].body
    buildMessage(messageData, callback)

  created: (data, eventType, callback) ->
    messageData =
      user:      data.comment.user.login
      action:    'commented on'
      eventType: eventType
      url:       data.comment.html_url
      title:     data[eventType].title
      body:      data.comment.body
    buildMessage(messageData, callback)

  closed: (data, eventType, callback) ->
    messageData =
      user:      data.sender.login
      action:    'closed'
      eventType: eventType
      url:       data[eventType].html_url
      title:     data[eventType].title
      body:      ''
    buildMessage(messageData, callback)

  reopened: (data, eventType, callback) ->
    messageData =
      user:      data[eventType].user.login
      action:    'reopened'
      eventType: eventType
      url:       data[eventType].html_url
      title:     data[eventType].title
      body:      data[eventType].body
    buildMessage(messageData, callback)

  reviewed: (data, eventType, callback) ->
    messageData =
      user:      data.comment.user.login
      action:    'commented on'
      eventType: eventType
      url:       data.comment.html_url
      title:     data.comment.path
      body:      data.comment.body
    buildMessage(messageData, callback)

filterComments = (body) ->
  body.replace /\<\!--.*?--\>/g, ''

replaceBreakTags = (body) ->
  body.replace /\<\/?br\/?\>/gi, '\n'

parseWithQuote = (body) ->
  body.match(/[^`]+|`[^`]*`/g) || ['']

stripTags = (body) ->
  resolved_body = ''
  sentences = parseWithQuote(body)
  sentences.forEach (sentence) ->
    if sentence.charAt(0) == '`'
      resolved_body += sentence
    else
      resolved_body += replaceBreakTags(filterComments(sentence))
  resolved_body

buildMessage = (data, callback) ->
  callback "#{data.user} #{data.action} #{data.eventType} #{data.url} - #{data.title}\n#{stripTags(data.body)}"
