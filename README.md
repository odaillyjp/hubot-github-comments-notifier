# Hubot Github Comments Notifier
An HTTP Listener that notifies about new Github issues and pull request comments

# Install
- Add `hubot-github-comments-notifier` as a dependency in `package.json`
- Add `hubot-github-comments-notifier` to your `external-scripts.json`
- install dependencies with `npm install`

# Bot Settings
- Create a new webhook for your repository
- Payload URL: `<HUBOT_URL>:<PORT>/hubot/gh-comments?room=<room>`
- Event Trigger: `Send me everything`, or select 'Pull request', 'Pull request review comment', 'Issues', 'Issue comment' events

# Licence
CC0
