# Some Useful uBlock Origin Filters

## Youtube

```adblock
! Block "ambient mode" garbage
youtube.com###cinematics.ytd-watch-flexy
```

## Stack Overflow / Stack Exchange

```adblock
! Block the cookie banner that covers the entire bottom left corner
*.stackexchange.com##.js-consent-banner.r16.l16.b16.bar-lg.fc-white.bg-black-750.sm\:p16.p32.sm\:w-auto.ws4.z-nav-fixed.ps-fixed.ff-sans
stackoverflow.com##.js-consent-banner.r16.l16.b16.bar-lg.fc-white.bg-black-750.sm\:p16.p32.sm\:w-auto.ws4.z-nav-fixed.ps-fixed.ff-sans
```

## GitHub

```adblock
! Block GitHub's cringe algorithmic social media style feed
github.com###feed-next
github.com##[aria-labelledby="feed-next"]

! Block the corporate changelog above the "Explore Repositories" section
github.com##.dashboard-changelog.mb-4

! Block GitHub's ads above the corporate changelog
github.com##.js-notice
```
