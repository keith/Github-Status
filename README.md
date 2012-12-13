## Github Status

This is a small menu bar application for OS X using the new [Github Status API](https://status.github.com/api)

## Download

Download the most recent version [here](http://smileykeith.com/media/downloads/GithubStatus.app.zip)

-------------------

### Change time intervals

Currently there isn't a GUI for changing the time refresh intervals. If you'd like to change them you can update them through terminal by using 2 different commands.

    defaults write com.keithsmiley.github-status refreshInterval -int NUM
    defaults write com.keithsmiley.github-status downRefreshInterval -int NUM

Replace `NUM` with the SECONDS you want it to be refreshed by. EX 60 for 1 minute. The `refreshInterval` is the interval for when github is acting normal. The default is 1800 aka 30 minutes. The `downRefreshInterval` is the default time for when Github is down or unreachable. The default is 300 aka 5 minutes.
