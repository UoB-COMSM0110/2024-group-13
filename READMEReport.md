<img src="PacMinerBanner.png"
alt="PacMiner" width="70%">

## Members

Finn Lawton,
Haolan Zhao,
Daniel Parschau,
Yunpeng Yang,
Chao Gao

<img src="resources/group13-members-photo.jpg"
alt="Group Members" width="70%">

## Project Kanban Board

[Kanban](https://github.com/orgs/UoB-COMSM0110/projects/62)

## Introduction
Welcome to multiplayer Pac-Man, a thrilling game that pits two players against each other on a mostly traditional Pac-Man map with an exciting twist: the ability to break through walls. This game is named Pac-Miner. Both players compete against each other to gather as many points as possible by collecting the coins generated throughout the map. Each player starts with 3 lives and aims to avoid ghosts while trying to outscore their opponent. Scattered in the map are different types of power-ups which can temporarily improve the players’ character or negatively affect their opponent. The ability to destroy barriers and kill ghosts using bullets enables the players to escape imminent death! The game ends when one player loses all three of their lives and the winner is the player with the most points. 

As our game is multiplayer, the players could target one another to score more points by killing their opponent or work peacefully and focus on collecting points instead. Our game has two modes of play: local or online multiplayer. The game strategy differs depending on which you choose. In the local version, you are able to see the whole map including your opponent, however in the online version a smaller area of the map is visible so you won’t always see your opponent.


## Requirements
Text


## Design
### Class Diagram
At the beginning of this project, we decided that we would take our time planning the architecture for the system before coding the game. This decision was made so that we could think through how we could implement the online multiplayer version without having to do major code refactoring further into the project. This process was complicated and resulted in a long time deliberating and discussing the options before starting the minimum viable product (MVP), however, this approach has allowed our coding to be very structured and align with our implementation challenges.

The image below is the class diagram we agreed upon before starting implementation. As mentioned, this structure evolves around implementing the online multiplayer aspect of the game. Therefore, we had the classes: localItems and synchronisedItems which both extended Items. LocalItems would be used to implement objects which were only updated and displayed to the local computer, for example, buttons and labels. Conversely, SynchronisedItems were used to make objects which required updating on both server and client machines, for example, player icons, ghosts, walls and coins. 

<img src="resources/PacClassDiagram.jpg"
alt="ClassDiagram" width="70%">

### Communication Diagram
Text

<img src="resources/PacCommunicationDiagram.jpg"
alt="CommunicationDiagram" width="70%">

### Design Summary
Text


## Implementation
Text


## Evaluation

### Qualitative Evalutations
We first did three types of qualitative evaluations at different points of the development process in order to have constant feedback and help navigate the final product design. This section will highlight the main results from the think aloud evaluation, heuristic evaluation and focus group.

#### Think Aloud Evaluation 11/03/2024

#### Heuristic Evaluation {DATE}

#### Focus Group 09/05/2024
Based off additional research, we found that hosting a focus group would provide further feedback. In this 40 minute session we asked the following quetions:

>*How did you find playing the game?*
>> P1 - Pretty good.
>>
>> P2 - I liked the traditional game play of Pac-Man but it was good to have the competition between players.
>>
>> P3 - Really cool, I really liked it.
>
>*What is the twist on the game?*
>> P2 - Playing multiplayer.
>>
>> P3 - That you can shoot through the walls and it’s underground.
>
>*Was there anything you expected to find that was not there?*
>> P4 - I think having a list of power ups would be good.
>>
>> P1 - Sound effects would make it more engaging.
>>
>> P5 - No I don’t think so, maybe more help information on controls
>
>*What was difficult or strange about the game?*
>> P1 - Seeing the fps, I have no idea what that was. Also it was not difficult enough.
>>
>> P5 - I thought it was difficult working out what the green things do.
>>
>> P2 - Getting movement stuck, is this because of powerups?
>>
>> P4 - Ghosts can get away by going through walls and the ghosts are a lot smaller than the path which makes it easier to escape them.
>>
>> P3 - I agree, but I guess that could be the twist.
>
>*What did you like about the game?*
>> P2 - Everything.
>>
>> P3 - All worked pretty well, reappearing coins was good, the competitive version was good, and looked pretty professional.
>>
>> P5 - It’s fun to play, I like this version of Pac-Man
>
>*Visually, was there anything that did not look the way you expected?*
>> P1 - Ghosts moving randomly through the walls, have mining features but more bright colours.
>>
>> P2 - I would change the font on the help page, I liked it for the titles and labels but it was difficult to read the help instructions.
>
>*What is one thing you would change about the game?*
>> P1 - Choice of avatar colour. Also to get more points if you kill a ghost or the other player.
>>
>> P3 - I agree, or maybe even making them different colours so you don’t get mixed up between them
>>
>> P4 - I agree, also possibly a way to pause the game.
>>
>> P5 - I think it would be good to have the help instructions when you press ‘start game’ so you are forced to read it.

The feedback from the focus group was valuable in showing personal user experience. It also highlighted that our twist to the traditional Pac-Man was evident, however, gave us useful changes we could make to further improve our game.


### Quantitative Evaluations


### How our code was tested


## Process
Text


## Conclusion
Text
