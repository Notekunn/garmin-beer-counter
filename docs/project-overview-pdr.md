# Product overview

## Purpose

The app exists for fun and for showing off. The target moment is sitting at a table with friends and raising a wrist to show the beer count, a funny title, and the session's stats. It is not a health tracker, so decisions favour speed, visibility, and humour over completeness.

## Product requirements

- Input must work with wet hands after a few drinks: tap anywhere to add a beer, get vibration feedback, and always be able to fix one mistaken tap.
- The count must never be lost when the app exits.
- A session ends manually with a confirmation, followed by a summary screen to show off. If the user forgets, the app starts a new session after a long time without taps.
- Nothing requires a phone, a network, or a server during use.

## Non-goals

Server, leaderboard, phone connection, session history, Garmin Connect activities, Connect IQ Store release, other watches, Vietnamese text on the watch, and clink-gesture detection.

Clink detection was rejected because the accelerometer would miscount, and a wrong count removes the app's reason to exist. History was rejected because the goal is showing off the current session, not long-term tracking.

## What the numbers mean

Heart rate and stress are there for fun. The app does not estimate blood alcohol and does not say whether anyone can drive.

## Terminology

- **Session:** the period from the first tap until the user ends it or the app auto-resets.
- **Title:** a funny name tied to a beer-count milestone. The list lives in `titleFor` in `source/BeerSession.mc`.
- **Sideload:** copying a `.prg` file directly to the watch over USB, without the store.
