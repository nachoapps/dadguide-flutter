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

## Running integration tests

We've got one integration test so far. You can run it by running the command 
`flutter drive --target=test_driver/app.dart --no-build` in the root folder.