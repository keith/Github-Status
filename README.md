# Github Status

This is a small menu bar application for OS X using the [Github Status API](https://status.github.com/api)

Download a pre-built binary from the [releases
page](https://github.com/Keithbsmiley/Github-Status/releases)

---

![https://raw.github.com/Keithbsmiley/Github-Status/master/screenshot.png]()

---

### Change time intervals

Currently there isn't a GUI for changing the time refresh intervals. If
you'd like to change them you can through terminal by using these
commands:

```sh
defaults write com.keithsmiley.github-status KSGithubStatusRefreshInterval -int NUM
defaults write com.keithsmiley.github-status KSGithubStatusDownRefreshInterval -int NUM
```
As you may expect the first is the normal refresh time while the second
is the refresh time when the last status reported Github as being down.

Replace `NUM` with the **seconds** you want it to be refreshed by. 60
for 1 minute etc. The refresh interval default is 1800 (30 minutes). The
down refresh interval default is 300 (5 minutes).
