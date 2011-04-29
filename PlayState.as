package 
{
	import flash.ui.Mouse;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		//Our emmiter
		private var theEmitter:FlxEmitter;
		
		//Our white pixel (This is to prevent creating 200 new pixels all to a new variable each loop)
		private var whitePixel:FlxParticle;
		
		//Some buttons
		private var collisionButton:FlxButton;
		private var gravityButton:FlxButton;
		private var quitButton:FlxButton;
		
		//The group we'll store some walls in
		private var wallsGroup:FlxGroup;
		
		//We'll use these to track the current state of gravity and collision
		private var isGravityOn:Boolean   = false;
		private var isCollisionOn:Boolean = false;
		
		//Just a useful flxText for notifications
		private var topText:FlxText;
		
		override public function create():void
		{
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			//Here we actually initialize out emitter
			//The parameters are        X   Y                Size (Maximum number of particles the emitter can store)
			theEmitter = new FlxEmitter(10, FlxG.height / 2, 200);
			
			//Now by default the emitter is going to have some properties set on it and can be used immediately
			//but we're going to change a few things.
			
			//First this emitter is on the side of the screen, and we want to show off the movement of the particles
			//so lets make them launch to the right.
			theEmitter.setXSpeed(100, 200);
			
			//and lets funnel it a tad
			theEmitter.setYSpeed( -50, 50);
			
			//Let's also make our pixels rebound off surfaces
			theEmitter.bounce = .8;
			
			//Now let's add the emitter to the state.
			add(theEmitter);
			 
			//Now it's almost ready to use, but first we need to give it some pixels to spit out!
			//Lets fill the emitter with some white pixels
			for (var i:int = 0; i < theEmitter.maxSize/2; i++) {
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(2, 2, 0xFFFFFFFF);
				whitePixel.visible = false; //Make sure the particle doesn't show up at (0, 0)
				theEmitter.add(whitePixel);
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(1, 1, 0xFFFFFFFF);
				whitePixel.visible = false;
				theEmitter.add(whitePixel);
			}
			
			//Now let's setup some buttons for messing with the emitter.
			collisionButton = new FlxButton(2, FlxG.height - 22, "Collision", onCollision);
			add(collisionButton);
			gravityButton = new FlxButton(82, FlxG.height - 22, "Gravity", onGravity);
			add(gravityButton);
			quitButton = new FlxButton(320, FlxG.height - 22, "Quit", onQuit);
			add(quitButton);
			
			//I'll just leave this here
			topText = new FlxText(0, 2, FlxG.width, "Welcome");
			topText.alignment = "center";
			add(topText);
			
			//Lets setup some walls for our pixels to collide against
			wallsGroup = new FlxGroup();
			var wall:FlxSprite = new FlxSprite(100, 100);
			wall.makeGraphic(10, 100, 0x50FFFFFF);//Make it darker - easier on the eyes :)
			wall.visible = wall.solid = false;//Set both the visibility AND the solidity to false, in one go
			wall.immovable = true;//Lets make sure the pixels don't push out wall away! (though it does look funny)
			wallsGroup.add(wall);
			//Duplicate our wall but this time it's a floor to catch gravity affected particles
			wall = new FlxSprite(10, 267);
			wall.makeGraphic(FlxG.width - 20, 10, 0x50FFFFFF);
			wall.visible = wall.solid = false;
			wall.immovable = true;
			wallsGroup.add(wall);
			
			//Don't forget to add the group to the state(Like I did :P)
			add(wallsGroup);
			
			//Now lets set our emitter free.
			//Params:        Explode, Particle Lifespan, Emit rate(in seconds)
			theEmitter.start(false, 3, .01);
			
			//Let's re show the cursors
			FlxG.mouse.show();
			Mouse.hide();
		}
		
		override public function update():void
		{
			//This is just to make the text at the top fade out
			if (topText.alpha > 0) {
				topText.alpha -= .01;
			}
			super.update();
			FlxG.collide(theEmitter, wallsGroup);
		}
		
		//This is run when you flip the collision
		private function onCollision():void {
			isCollisionOn = !isCollisionOn;
			if (isCollisionOn) {
				if (isGravityOn) {
					FlxSprite(wallsGroup.members[1]).solid = true;    //Set the floor to the 'active' collision barrier
					FlxSprite(wallsGroup.members[1]).visible = true;
					FlxSprite(wallsGroup.members[0]).solid = false;
					FlxSprite(wallsGroup.members[0]).visible = false;
				}else {
					FlxSprite(wallsGroup.members[1]).solid = false;   //Set the wall to the 'active' collision barrier
					FlxSprite(wallsGroup.members[1]).visible = false;
					FlxSprite(wallsGroup.members[0]).solid = true;
					FlxSprite(wallsGroup.members[0]).visible = true;
				}
				topText.text = "Collision: ON";
			}else {
				//Turn off all of the walls, completely
				FlxSprite(wallsGroup.members[0]).solid = FlxSprite(wallsGroup.members[1]).solid = FlxSprite(wallsGroup.members[0]).visible = FlxSprite(wallsGroup.members[1]).visible = false;
				topText.text = "Collision: OFF";
			}
			topText.alpha = 1;
			FlxG.log("Toggle Collision");
		}
		
		//This is run when you flip the gravity
		private function onGravity():void {
			isGravityOn = !isGravityOn;
			if (isGravityOn) {
				theEmitter.gravity = 200;
				if (isCollisionOn){
					FlxSprite(wallsGroup.members[1]).visible = true;
					FlxSprite(wallsGroup.members[1]).solid = true;
					FlxSprite(wallsGroup.members[0]).visible = false;
					FlxSprite(wallsGroup.members[0]).solid = false;
				}
				//Just for the sake of completeness let's go ahead and make this change happen 
				//to all of the currently emitted particles as well.
				for (var i:int = 0; i < theEmitter.members.length; i++) {
					FlxParticle(theEmitter.members[i]).acceleration.y = 200;
				}
				topText.text = "Gravity: ON";
			}else {
				theEmitter.gravity = 0;
				if (isCollisionOn){
					FlxSprite(wallsGroup.members[0]).visible = true;
					FlxSprite(wallsGroup.members[0]).solid = true;
					FlxSprite(wallsGroup.members[1]).visible = false;
					FlxSprite(wallsGroup.members[1]).solid = false;
				}
				for (var i:int = 0; i < theEmitter.members.length; i++) {
					FlxParticle(theEmitter.members[i]).acceleration.y = 0;
				}
				topText.text = "Gravity: OFF";
			}
			topText.alpha = 1;
			FlxG.log("Toggle Gravity");
		}
		//This just quits - state.destroy() is automatically called upon state changing
		private function onQuit():void {
			FlxG.switchState(new MenuState());
		}
	}
}
