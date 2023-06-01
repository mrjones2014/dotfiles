# Useful uBlock Origin Filters

- [Youtube](#youtube)
- [Stack Overflow / Stack Exchange](#stack-overflow-stack-exchange)
- [GitHub](#github)
- [Glassdoor](#glassdoor)

## Youtube

```adblock
! Block "ambient mode" garbage
youtube.com###cinematics.ytd-watch-flexy

! Block YouTube's cringe gigantic banner ads on the home screen
www.youtube.com##ytd-statement-banner-renderer
www.youtube.com##.ytd-brand-video-shelf-renderer

! Block YouTube's definitely totally unbiased "misinformation" banners, I can think for myself
www.youtube.com##.ytd-clarification-renderer
www.youtube.com###clarify-box
```

## Stack Overflow / Stack Exchange

```adblock
! Block the cookie banner that covers the entire bottom left corner
*.stackexchange.com##.js-consent-banner
stackoverflow.com##.js-consent-banner
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

## Glassdoor

```adblock
! Block the "hard sell" overlay that tries to force you to pay money just to read a review
www.glassdoor.com##.hardsellOverlay
```
