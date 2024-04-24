![PacMinerBanner](https://github.com/UoB-COMSM0110/2024-group-13/assets/145793563/01267c16-32d5-4446-8abb-08719795436f)

## Table of Contents
- [Members](#members)
- [Kanban Board](#project-kanban-board)
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Design](#design)
  - [Class Diagram](#class-diagram)
  - [Communication Diagram](#communication-diagram)
  - [Design Summary](#design-summary)
- [Implementation](#implementation)
- [Evaluation](#evaluation)
  - [Qualitative Evaluations](#qualitative-evaluations)
  - [Quantitative Evaluations](#quantitative-evaluations)
  - [Testing](#how-our-code-was-tested)
- [Process](#process)
- [Conclusion](#conclusion)


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
### Initial Concept Discussion
At the outset of this task we decided that in order to settle on a single concept for us to pursue, we would take a broad ideation approach which we would further narrow down through further thought and discussion. To this extent, we created a WhatsApp group to communicate and told each other to come up with two or three ideas for us to discuss in our next meeting. In order to help come up with as many ideas as possible we viewed websites that described older arcade style games (and then thought about in which ways these could be changed to create a novel and engaging concept). Ideas were written down and brought to our next meeting.

### Selection of Game Concepts
Once we had this list of ideas we sat down and pitched them to each other, describing the basic premise and seeing how the group reacted. This was done to narrow our vision down to two main ideas that focussed on the the old arcade games Tank and Pacman, with respective twists (of a protection focus and dynamic multiplayer game play respectively) and the technical challenges that we would be covering in each, as well as a paper prototype to better envision how the game would work and to what extent it would prove as engaging as was the ultimate ambition of the project.

The results of this idea clinic analysis has been captured as per the paper prototypes shown below.

### Game idea 1: Battle of the Tanks
[<img src="https://i.ytimg.com/vi/0xlvFs2NJCI/hqdefault.jpg"
width="70%">](https://www.youtube.com/watch?v=0xlvFs2NJCI
"Game Idea: Tank")

### Game idea 2: Multiplayer Pac-Man
[<img src="https://i.ytimg.com/vi/RZP7WlMi2Jo/hqdefault.jpg"
width="70%">](https://www.youtube.com/watch?v=RZP7WlMi2Jo
"Game Idea: Pacman")

### Combining Ideas
Following these sessions we realised that while both concepts were individually engaging there were a number of overlapping dimensions that might enable us to take the most fun elements of both and combine these into a single game. Much discussion ensued with a version of Pacman that would allow for multiple players  but also allow for mutual collaboration, and the ability to modify the map by means of explosive projectiles.

As soon as this became clear, we found that we could actually build a compelling narrative and story around this involving our pacman character fleeing underground from ghosts and exploitation in arcade machines. Special events could be attributed nicely to the mutations and unexpected occurrences arising from the effects of uranium found underground. Additional potential for altering the game play mechanics through the effect of darkness underground different types of mine wall materials also resulted.

### Requirements Gathering
#### Stakeholder Analysis
Finally we were ready to start more actively thinking about the people that would be involved in using, building, maintaining and assessing the quality of our game and the success of the software as a venture. To do this we made use of models such as the Onion Model to make sure all relevant parties were identified.
These were as follows:

1. Developers (Core Layer): Us as the students working on the project form the core of the onion as we are the most directly involved stakeholders  responsible for designing, coding, and testing the game 
2. Lecturers/Markers (Inner Layer): While not part of the project’s daily development they were critical for helping in guide the process and ultimately responsible for assessing the quality of the software that we produce (much as a client would be)
3. Players (Middle Layer): Different to the lecturers,  who would ultimately be playing the game in the final demo, these individuals were the important testers who helped us by providing valuable feedback and helping to test the game’s functionality and appeal
4. Customers (Outer Layer): In the event that the game is released beyond university any potential existing customers would appear in this layer as people who have an interest in the game but are not currently involved in its development or assessment
5. University as a negative stakeholder (Outer Layer): The school or university could be considered a negative stakeholder in the event of any issues that arise from the game which have an impact on the school’s reputation or resources (e.g. the online multiplayer gaming distracting students from work or using university resources for purposes not aligned with the goals of the institution).


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
