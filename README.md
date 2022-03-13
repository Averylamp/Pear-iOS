
# Pear iOS App

Pear is an iOS App made by the Pear Team (Brian Gu, Joshua Liu, Joel Aguero, and me Avery Lamp).

#### The General Problem

We want to build a social matchmaking service. This is distinct from a dating service in that we pay special attention to the user experience of the matchmaker. 

Openly displaying interest in dating (whether in real life or by participating in online dating) is stigmatized across all demographics. Adding a layer of indirection (i.e. outsourcing profile-creation and inbound management to a friend) reduces the signaling cost of joining a platform to date. For most young adults, managing an online dating profile is something to be done in private; female users in particular often report feeling anything from “shame” to “disgust” in using Tinder.



### Installation

Using cocoapods for dependency management
To install cocoapods
`sudo gem install cocoapods`

To install dependencies run:
`pod install`

We are also using Fastlane to manage build uploads
To deploy a new beta build:
`bundle exec fastlane beta`

