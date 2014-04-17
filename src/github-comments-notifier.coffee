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
