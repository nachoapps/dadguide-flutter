# DadGuide for iOS/Android

This repo contains the DadGuide v2 mobile app, written in Flutter.

For the data loader (written in Python) you want [this repo](https://github.com/nachoapps/dadguide-data).

## Work in progress

Everything is kind of a mess right now. I wrote this app to learn Flutter, and I haven't gone back
and cleaned everything up yet.

## Getting Started

For help getting started with Flutter, view the [online documentation](https://flutter.dev/docs).

I've used Android Studio on Linux, Windows, and OSX to build this project. Once you get Dart,
Flutter, Git, and Android Studio installed it should be pretty straightforward.

OSX also requires Xcode and is a pain in the ass. If you're an iOS dev and you'd like to help me
fix some stuff please let me know.

## Important! - Code generation

Take a look at lib/data/README.md; this project uses codegen for some files and you need to start
that while developing.

## Releases

There should be a Milestone attached to each release with the issues (e.g. new features) that were
closed in it. The name can be a placeholder until the release is ready.

When ready to release, determine what the next version would be by checking the most recent
CodeMagic build number and adding 1, e.g. if the last build is 83 the next release tag should
be `2.0.84`.

Update CHANGELOG.md with the release notes and the presumptive release link.

Create a new release with that number, add a description, and link to the 'closed issues' tab of
the release milestone.

Start a new build on codemagic.io and double check that the version is correct.

## Updating the podfile

Periodically I need to update some iOS specific stuff, but I don't have a Mac for dev work. If I
can't get someone to do this for me, the best way to do the change is:

1) Kick off a build in codemagic with 'remote access' enabled.
2) ssh into the machine.
3) Wait until the Android build starts.
4) `kill` the running build process.
5) `cd clone/ios`
6) `pod update`
7) `git add Podfile.lock`
8) `git commit -m 'updating ios dependency versions`
9) `git push`

Doing `pod update` is the most common thing, it updates the ios-specific versions of dependencies.
There might be other things too, but they're hard to do without using xCode.
