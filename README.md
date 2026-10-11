# Prism

A no-jailbreak Theos tweak for Spotify on iOS, injected into your own decrypted IPA.

## Build (no Mac needed)

1. Push this folder to a new GitHub repo.
2. Upload your **decrypted** Spotify `.ipa` somewhere with a direct download link.
3. Actions → **Build IPA** → Run workflow → paste the link.
4. Download `Prism-ipa` from the run, then sign and install it with SideStore, Feather or Sideloadly.

## Use

Long-press anywhere in Spotify with three fingers to open Prism's settings.

## Layout

| File | What it does |
| --- | --- |
| `Tweak.x` | Logos hooks: the entry point (`%ctor`) and the `UIWindow` hook that adds the gesture |
| `PrismSettings.m` | Stored settings and the settings screen |
| `Makefile` / `control` | Theos build and package metadata |
| `.github/workflows/build.yml` | Builds the `.deb` on macOS and injects it into the IPA with cyan |
