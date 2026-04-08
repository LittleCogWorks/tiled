
I've been working on a little party-type game and was hoping you could check it out. 
"Tiled" is a game for 2 or more players/teams. The aim of the game is to reach the score target first. To win point you need to answer questions correctly and the questions are presented on the board. But it's not quite as simple as that, the question has been tiled over, take it in turns to reveal words in the questions and try to be the first to get the answer.

To play the game you need:
- PC running Windows or Linux
- Mobile devices
- A network that the devices are connected to

To Play:
You'll need to run the game executable on a PC and you will also need a mobile device that is on the same network as the PC. The mobile device will be your controller. 

%% some instructions here %%

![[Screenshot 2026-03-29 191102.png]]

Pressing start will take you to the setup where some default options are already chosen. 
![[Screenshot 2026-04-08 191012.png]]

I'm going to kick off talking about **multiplayer**, the way it was meant to be played.

Multiplayer: This mode you need your phone or tablet connected to the same network as the PC. The game runs on the host machine (PC/Laptop) and players answer/participate in the rounds from their phone. 

When you press "GO" on the setup screen you will be taken to the lobby.
![[Screenshot 2026-04-08 191427.png]]

The game code is for future use, but under "How to join" it should display the IP address of the computer the game is running on. 
*I know this isn't the simplest but its been worked on!*

From the mobiles devices, head to a browser and enter the IP:PORT combo in the instructions (NOTE: annoyingly the chances are you will need to include http://).

![[Screenshot_20260408-2.png|345]]

Press "Connect" to join the host and the player will get to enter their name and pick their avatar.
Enter the details and press "Join" and then when happy, press "ready"
![[Screenshot_20260408-192019 1.png|350]]

They can change their name and update whilst waiting.
![[Screenshot_20260408-192031.png|350]]


When the game starts the players will see the play screen. The tiles are shown as buttons, and are greyed out when it is not their turn. 
![[Screenshot_20260408-192239 1.png|307]]

On your turn: press a button to reveal the word and pass to the next player.
![[Screenshot_20260408-192248.png|323]]

Or press guess and enter your answer. 
![[Screenshot_20260408-192305.png|323]]

Changes are reflected on the main game screen as well as the updates on the controller.
![[Pasted image 20260408204510.png]]


Single player: This is not fully implemented. Actually it's only here because of my testing so far. 


The game doesn't need the internet, but it does need the devices connected to the same local network. If you're using wifi at home you'll probably be fine. Running the game, it will use local ports 9080 (Godot WebSocket) and 8000 (webserver - html for controllers)


A few things: 
This is still at the early stages. Content is limited and may even be wrong. Further content will be added in future iterations. 