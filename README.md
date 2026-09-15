<div align='center'><img src="docs/readme_images/FNF_logo.png" width="800">

<h2>Friday Night Funkin' is a rhythm game. Built using HaxeFlixel for <a href="https://ldjam.com/events/ludum-dare/47">Ludum Dare 47.</a></h2>

This game was made with love to Newgrounds and its community. Extra love to Tom Fulp.

</div>

- [Playable web demo on Newgrounds!](https://www.newgrounds.com/portal/view/770371)
- [Demo download builds for Windows, Mac, and Linux from Itch.io!](https://ninja-muffin24.itch.io/funkin)
- [Download Android builds from Google Play!](https://play.google.com/store/apps/details?id=me.funkin.fnf)
- [Download iOS builds from the App Store!](https://apps.apple.com/app/id6740428530)

<div align='center'>
<table>
  <tr>
    <td><img src="docs/readme_images/Title_Card.gif" alt="Title Screen" width="350"/></td>
    <td><img src="docs/readme_images/Menu.png" alt="Main Menu" width="350"/></td>
  </tr>
</table>
</div>

# Getting Started

**PLEASE USE THE LINKS ABOVE IF YOU JUST WANT TO PLAY THE GAME**

To learn how to install the necessary dependencies and compile the game from source, please follow our [Compiling Guide](/docs/COMPILING.md).

# Contributing

Check out our [Contributing Guide](/docs/CONTRIBUTING.md) to learn how you can actively contribute to the development of Friday Night Funkin'!

# Modding

Feel free to start learning to mod the game by reading our [documentation](https://funkincrew.github.io/funkin-modding-docs/) and guide to modding.

# Credits and Special Thanks

Full credits can be found in-game, or in the `credits.json` file which is located [here](https://github.com/FunkinCrew/funkin.assets/blob/main/exclude/data/credits.json).

## Programming
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Lead Programmer
- [EliteMasterEric](https://twitter.com/EliteMasterEric) - Programmer
- [MtH](https://twitter.com/emmnyaa) - Charting and Additional Programming
- [GeoKureli](https://twitter.com/Geokureli/) - Additional Programming
- [ZackDroid](https://x.com/ZackDroidCoder) - Lead Mobile Programmer
- [MAJigsaw77](https://github.com/MAJigsaw77) - Mobile Programmer
- [Karim-Akra](https://x.com/KarimAkra_0) - Mobile Programmer
- [Sector_5](https://github.com/sector-a) - Mobile Programmer
- [Luckydog7](https://github.com/luckydog7) - Mobile Programmer
- Our contributors on GitHub

## Art / Animation / UI
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) - Artist and Animator
- [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Moawling](https://twitter.com/moawko) - Week 6 Pixel Art
- [IvanAlmighty](https://twitter.com/IvanA1mighty) - Misc UI Design

## Music
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician
- [BassetFilms](https://twitter.com/Bassetfilms) - Music for "Monster", Additional Character Design

## Special Thanks
- [Tom Fulp](https://twitter.com/tomfulp) - For being a great guy and for Newgrounds
- [JohnnyUtah](https://twitter.com/JohnnyUtahNG/) - Voice of Tankman
- [L0Litsmonica](https://twitter.com/L0Litsmonica) - Voice of Mommy Mearest

# Using This Template

This repository is a build-ready template based on the base Friday Night Funkin' source, set up to compile for Windows, Linux, MacOS, Android, and iOS via GitHub Actions — including 32-bit and 64-bit Android builds and an unsigned IPA for iOS.

## Requirements

- [Haxe 4.3.7](https://haxe.org/download/)
- [HMM](https://lib.haxe.org/p/hmm) for dependency management
- Git, with submodule support (this repo pulls `art` and `assets` from FunkinCrew as submodules)

## Setting Up Locally

```bash
git clone --recurse-submodules <your-fork-url>
cd Funkin-Template
haxelib install hmm
haxelib run hmm install
```

If you already cloned without `--recurse-submodules`, run:

```bash
git submodule update --init --recursive
```

## Building Locally

Once dependencies are installed, build with Lime for your target platform:

```bash
haxelib run lime build windows
haxelib run lime build linux
haxelib run lime build mac
haxelib run lime build android
haxelib run lime build ios -nosign
```

See the [Compiling Guide](/docs/COMPILING.md) for platform-specific setup (Android SDK/NDK, Xcode, etc).

## Building via GitHub Actions

This template ships with two reusable workflows:

- **`.github/workflows/main.yml`** — a manually triggered (`workflow_dispatch`) matrix build that covers every supported platform: Windows (x64/x32), Linux, MacOS, Android (x64/x32), and iOS.
- **`.github/workflows/build.yml`** — the reusable build job called by `main.yml` for each matrix entry; handles Haxe/Xcode setup, dependency installation, platform-specific configuration, compiling, IPA packaging, and artifact upload.

To run a full build, go to the **Actions** tab of your repo, select **Main**, and click **Run workflow**. Each platform's output is uploaded as a separate downloadable artifact once the job finishes.

To add or change a target platform, edit the `matrix.include` list in `main.yml` — each entry defines the runner OS, Lime build args, and where the resulting artifact is found.
