package
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class GameState extends Sprite
	{
		public static var WIDTH:int = 200;
		public static var HEIGHT:int = 400;
		public static var MAX_STARS:int = 50;
		public static var MAX_PARTICLES:int = 25;
		
		private var _canvas:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0xffffff);
		private var _keys:Array = new Array(256);
		private var _ticks:int = 0;
		
		private var player:Actor;
		private var enemies:Array = new Array;
		private var enemyBullets:Array = new Array;
		private var bullets:Array = new Array;
		private var stars:Array = new Array;
		private var particles:Array = new Array;
		
		private var shipShape:Shape = new Shape;	// ha ha ha "ship shape"
		//private var enemyShape:Shape = new Shape;
		private var enemyShapes:Array = new Array;
		private var bulletShape:Shape = new Shape;
		private var enemyBulletShape:Shape = new Shape;
		private var starShape:Shape = new Shape;
		private var particleShapes:Array = new Array;
		//private var particleShape:Shape = new Shape;
		private var playerParticleShape:Shape = new Shape;
		
		// Sounds/music
		private var soundChannel:SoundChannel = new SoundChannel;
		
		[Embed(source="../sounds/enemyshoot.mp3")] private var EnemyShootSound:Class;
		private var enemyShootSound:Sound = new EnemyShootSound() as Sound;
		[Embed(source="../sounds/enemydie.mp3")] private var EnemyDieSound:Class;
		private var enemyDieSound:Sound = new EnemyDieSound() as Sound;
		[Embed(source="../sounds/die.mp3")] private var PlayerDieSound:Class;
		private var playerDieSound:Sound = new PlayerDieSound() as Sound;
		[Embed(source="../sounds/pew2.mp3")] private var PlayerShootSound:Class;
		private var playerShootSound:Sound = new PlayerShootSound() as Sound;
		[Embed(source="../music/bg.mp3")] private var BackgroundMusic:Class;
		private var backgroundMusic:Sound = new BackgroundMusic() as Sound;
		
		private var spacePressed:Boolean;
		private var shootDelay:int = 0;
		
		// Scoring, display, etc.
		private var shotsFired:int = 0;
		private var enemiesSpawned:int = 0;
		private var enemiesKilled:int = 0;
		private var enemiesKilledDisplay:TextField = new TextField;
		private var timerDisplay:TextField = new TextField;
		private var gameOver:Boolean = false;
		private var gamePaused:Boolean = false;
		
		public function GameState():void
		{	
			// Do all drawing on this
			addChild(new Bitmap(_canvas));
			
			// Kill counter
			addChild(enemiesKilledDisplay);
			
			enemiesKilledDisplay.x = WIDTH - enemiesKilledDisplay.width;
			enemiesKilledDisplay.y = 0;

			enemiesKilledDisplay.defaultTextFormat = new TextFormat("_typewriter", 16, 0xffffff, true);
			enemiesKilledDisplay.autoSize = "right";
			enemiesKilledDisplay.text = enemiesKilled + "/1000";
			
			// Timer
			addChild(timerDisplay);
			timerDisplay.x = 0;
			timerDisplay.y = 0;
			timerDisplay.defaultTextFormat = new TextFormat("_typewriter", 16, 0xffffff, true);
			timerDisplay.autoSize = "left";
			timerDisplay.text = "0.0";
			
			// Create shape for ship
			//shipShape.graphics.beginFill(0xffffff);
			shipShape.graphics.lineStyle(1, 0xffffff);
			shipShape.graphics.moveTo(5, 0);
			shipShape.graphics.lineTo(10, 10);
			shipShape.graphics.lineTo(5, 8);
			shipShape.graphics.lineTo(0, 10);
			shipShape.graphics.lineTo(5, 0);
			shipShape.graphics.endFill();
			
			// red, purple, blue, cyan, yellow, orange
			var enemyColors:Array = new Array(0xff0000, 0xff00ff, 0x0000ff, 0x00ccff, 0xffff00, 0xff6600);
			
			for(var i:int = 0; i < enemyColors.length; i++)
			{
				// Create enemy shapes
				enemyShapes.push(new Shape);
				enemyShapes[i].graphics.lineStyle(2, enemyColors[i]);
				enemyShapes[i].graphics.moveTo(5, 0);
				enemyShapes[i].graphics.lineTo(10, 10);
				enemyShapes[i].graphics.lineTo(0, 10);
				enemyShapes[i].graphics.lineTo(5, 0);
				
				// Create enemy particle shapes
				particleShapes.push(new Shape);
				particleShapes[i].graphics.lineStyle(1, enemyColors[i]);
				particleShapes[i].graphics.drawCircle(0, 0, 1);
			}
			
				
			// Create shape for bullet
			bulletShape.graphics.lineStyle(1, 0xffffff);
			bulletShape.graphics.drawCircle(1, 1, 1);
			
			// Create shape for enemy bullet
			enemyBulletShape.graphics.lineStyle(1, 0x00ff00);
			enemyBulletShape.graphics.drawCircle(2, 2, 2);
			
			// Create shape for stars
			starShape.graphics.lineStyle(1, 0x666666);
			starShape.graphics.drawCircle(0, 0, 1);
			
			// Create shape for player explosion particles
			playerParticleShape.graphics.lineStyle(1, 0xffffff);
			playerParticleShape.graphics.drawCircle(0, 0, 1);
			
			// Create "hoshizora" background
			for(i = 0; i < MAX_STARS; i++)
				stars.push(new Actor(Math.random() * WIDTH, Math.random() * HEIGHT, starShape, 0, Math.random() * 3 + 2));
			
			// Add some random enemies
			for (i = 0; i < 5; i++)
			{
				enemiesSpawned++;
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShapes[Math.floor(enemiesSpawned / (1000 / enemyShapes.length))],0,0,enemiesSpawned));
			}
			
			// DEBUG
			//enemiesSpawned = 700;
			//enemiesKilled = 695;
			
			// Init player
			player = new Actor(100, 300, shipShape, 1, 1);
			
			// Init keyboard values
			for(i = 0; i < _keys.length; i++) _keys[i] = 0;
			
			// Start music
			soundChannel = backgroundMusic.play(0, 9999);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			Game.main.stage.focus = null;		// Reset focus
			Game.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { if(_keys[e.keyCode] == 0) _keys[e.keyCode] = 1; } );
		    Game.main.stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { _keys[e.keyCode] = 0; } );
			Game.main.stage.addEventListener(FocusEvent.FOCUS_OUT, function (e:Event):void { gamePaused = true; trace("Focus event!" + e.type); } );
		}
		
		private function onEnterFrame(e:Event):void
		{
			/**
			BEGIN DRAWING
			*/
			// Lock canvas so all drawing operations are done at the same time (when unlock() is called)
			_canvas.lock();
			
			// Draw alpha overlay over all canvas content, slowly fading drawn objects
			var cr:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, 0.8);
			_canvas.colorTransform(cr, ct);
			
			// Draw player
			if(!gameOver)
				_canvas.copyPixels(player.bitmap, player.bitmap.rect, new Point(player.position.x - (player.width / 2), player.position.y - (player.height / 2)));
			//_canvas.draw(player.bitmap, matrix, null, null, null, true);
			
			// Draw enemies
			var matrix:Matrix = new Matrix();
			for each(var enemy:Actor in enemies)
			{
				// Find angle between enemy and player
				enemy.rotation = Math.atan2(player.position.y - enemy.position.y, player.position.x - enemy.position.x);
				matrix = new Matrix();
				matrix.rotate(enemy.rotation + 1.57079633);
				//matrix.translate(enemy.position.x - (enemy.width / 2), enemy.position.y - (enemy.height / 2));
				matrix.translate(enemy.position.x, enemy.position.y);
				_canvas.draw(enemy.bitmap, matrix, null, null, null, true);
			}
			
			// Draw bullets
			for each(var bullet:Actor in bullets)
				_canvas.copyPixels(bullet.bitmap, bullet.bitmap.rect, bullet.position);
			
			// Draw enemy bullets
			for each(var enemyBullet:Actor in enemyBullets)
				_canvas.copyPixels(enemyBullet.bitmap, enemyBullet.bitmap.rect, enemyBullet.position);
			
			// Draw stars - last, so they don't overlap anything
			for each(var star:Actor in stars)
				_canvas.copyPixels(star.bitmap, star.bitmap.rect, star.position);
			
			// Draw particles
			for each(var particle:Actor in particles)
				_canvas.copyPixels(particle.bitmap, particle.bitmap.rect, particle.position);
			
			// Unlock canvas
			_canvas.unlock();
			
			/**
			END DRAWING
			*/
			
			// Update ticks
			_ticks++;
			
			// Calculate time played
			var seconds:Number = _ticks / 30;
			if (!gameOver)
			{
				timerDisplay.text = String(Math.round(seconds * 10) / 10);
				if (timerDisplay.text.indexOf(".") == -1) 
					timerDisplay.appendText(".0");	// Append .0 if a whole number
			}
			
			if (!gameOver)
				Game.main.cursor.visible = false;	// Hide mouse cursor
			
			// Counters
			var i:int = 0, j:int = 0, k:int = 0;
			
			// For particle explosions
			var particleDirection:Number;
			
			// Update player position
			if (_keys[0x25] || _keys[0x41]) player.position.x -= player.velocity.x; 
	        if (_keys[0x26] || _keys[0x57]) player.position.y -= player.velocity.y; 
	        if (_keys[0x27] || _keys[0x44]) player.position.x += player.velocity.x; 
	        if (_keys[0x28] || _keys[0x53]) player.position.y += player.velocity.y;
			
			// Enforce boundaries
			if (player.position.x > WIDTH) player.position.x = WIDTH;
			if (player.position.x < 0) player.position.x = 0;
			if (player.position.y > HEIGHT) player.position.y = HEIGHT;
			if (player.position.y < 0) player.position.y = 0;
			
			// Shoot
			if (_keys[32] && !gameOver)
				if (shootDelay++ > 6 / player.velocity.x || _keys[32] == 1) 
				{
					shootDelay = 0;
					playerShootSound.play();
					bullets.push(new Actor(player.position.x - 2, player.position.y, bulletShape, 0, -5));
					shotsFired++;
				}
			
			// Update enemy position
			var projectionVector:Point;
			
			for(i = 0; i < enemies.length; i++)
			{
				// Change velocity based on rotation
				enemies[i].velocity.x = Math.cos(enemies[i].rotation);
				enemies[i].velocity.y = Math.sin(enemies[i].rotation);
				
				// Move 'em
				enemies[i].update();
				
				// Shoot every so often - randomly between 1 - 3 seconds
				if (enemies[i].ticksSinceSpawned % (60 * int(Math.random() * 3 + 1)) == 0)
				{
					enemyBullets.push(new Actor(enemies[i].position.x + Math.cos(enemies[i].rotation) - enemies[i].width / 2, enemies[i].position.y + Math.sin(enemies[i].rotation) - enemies[i].height / 2, enemyBulletShape, Math.cos(enemies[i].rotation) * 2, Math.sin(enemies[i].rotation) * 2));
					enemyShootSound.play();
				}
			}
			
			// Spawn a new enemy every 8 seconds -- 5 seconds seemed too much
			if(_ticks % 480 == 0 && !gameOver && enemiesSpawned < 1000)
			{
				enemiesSpawned++;
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShapes[Math.floor(enemiesSpawned / (1000 / enemyShapes.length))], 0, 0, enemiesSpawned));
			}
			
			// Update bullet position
			for(i = 0; i < bullets.length; i++)
			{
				if(!bullets[i].update())
				{
					// If goes off edge of screen, remove it
					bullets.splice(i, 1);
					i--;
					continue;
				}
				
				// Check collisions between player bullets and enemies
				for(j = 0; j < enemies.length; j++)
				{
					if(enemies[j].collidesWith(bullets[i]))
					{
						enemyDieSound.play();
						
						// Create particle explosion
						for(k = 0; k < MAX_PARTICLES; k++)
						{	
							particleDirection = Math.random() * 2 * Math.PI;		// Random angle in radians
							particles.push(new Actor(enemies[j].position.x, enemies[j].position.y, particleShapes[Math.floor(enemies[j].spawnNumber / (1000 / enemyShapes.length))], Math.cos(particleDirection) * 2, Math.sin(particleDirection) * 2));
						}
						
						// Destroy enemy, but instantly create a new one to take its place
						if(enemiesSpawned < 1000)
						{
							enemies.splice(j, 1, new Actor(Math.random() * WIDTH, 0, enemyShapes[Math.floor(enemiesSpawned / (1000 / enemyShapes.length))], 0, 0, enemiesSpawned));
							enemiesSpawned++;
						}
						else
						{
							enemies.splice(j, 1);
						}
						
						// Increment counter/display
						enemiesKilled++;
						enemiesKilledDisplay.text = enemiesKilled + "/1000";
						
						// Remove bullet as well
						bullets.splice(i, 1); 
						i--;
						break;
					}
				}
			}
			
			// Update enemy bullet position
			for(i = 0; i < enemyBullets.length; i++)
			{
				// Check for collision between enemy bullets and player
				if (enemyBullets[i].collidesWith(player))
				{
					// Create particle explosion
					for(k = 0; k < MAX_PARTICLES; k++)
					{	
						particleDirection = Math.random() * 2 * Math.PI;		// Random angle in radians
						particles.push(new Actor(player.position.x, player.position.y, playerParticleShape, Math.cos(particleDirection) * 2, Math.sin(particleDirection) * 2));
					}
					playerDieSound.play();
					//resetGame();
					endGame();
					break;
				}
					
				if(!enemyBullets[i].update())
				{
					enemyBullets.splice(i, 1);
					i--;
				}
			}
			
			// Update star position
			for(i = 0; i < stars.length; i++)
				if(!stars[i].update())
					stars.splice(i, 1, new Actor(Math.random() * WIDTH, 0, starShape, 0, Math.random() * 3 + 2)); 
			
			// Update particles
			for(i = 0; i < particles.length; i++)
			{
				if(!particles[i].update() || particles[i].ticksSinceSpawned > 30)	// one second
				{
					particles.splice(i, 1);
					i--;
				}
			}
			
			// Makes values in key array "2" if button is held down
			updateKeys();
			
			// Increase player movement/shooting speed for every enemy killed - this may be too fast		
			player.velocity.x = 1 + 0.0025 * enemiesKilled;
			player.velocity.y = 1 + 0.0025 * enemiesKilled;
			
			// Implement "win" condition
			if (enemiesKilled == 1000)
			{
				enemiesKilled = 1001;
				winGame();
			}
		}
		
		private function resetGame():void
		{
			// Remove all bullets, enemies
			while(bullets.length > 0) bullets.splice(0, 1);
			while(enemyBullets.length > 0) enemyBullets.splice(0, 1);
			while(enemies.length > 0) enemies.splice(0, 1);
			
			// Make the screen flash white
			var cr:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 255, 255);
			_canvas.colorTransform(cr, ct);
			
			// Reset enemy kill count
			enemiesKilled = 0;
			enemiesKilledDisplay.text = enemiesKilled + "/1000";
			
			// Reset game ticks
			_ticks = 0;
			
			// Spawn some new enemies
			for(var i:int = 0; i < 5; i++)
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShapes[Math.floor(enemiesSpawned / (1000 / enemyShapes.length))]));
			enemiesSpawned = 5;
				
			// Reset player
			player.position.x = 100;
			player.position.y = 300;
		}
		
		private function endGame():void
		{
			gameOver = true;
			Game.main.cursor.visible = true;
			soundChannel.stop();
			
			// Remove all bullets, enemies
			while(bullets.length > 0) bullets.splice(0, 1);
			while(enemyBullets.length > 0) enemyBullets.splice(0, 1);
			while(enemies.length > 0) enemies.splice(0, 1);
			
			// Make the screen flash white
			var cr:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 255, 255);
			_canvas.colorTransform(cr, ct);
			
			// Figure out some stats
			var accuracyPercentage:String = String(Math.round(enemiesKilled / shotsFired * 1000) / 10);
			if (accuracyPercentage == "NaN") accuracyPercentage = "0";		// If division by zero 'cos no shots fired
			var timePlayed:String = timerDisplay.text;
			
			// Display "game over" title
			var title:TextField = new TextField;
			title.x = (GameState.WIDTH - title.width) / 2;
			title.y = 20;
			title.defaultTextFormat = new TextFormat("_typewriter", 30, 0xffffff, true);
			title.autoSize = "center";
			title.text = "GAME OVER";
			title.selectable = false;
			addChild(title);
			
			// Display stats
			var stats:TextField = new TextField;
			stats.x = (GameState.WIDTH - stats.width) / 2;
			stats.y = 60;
			stats.defaultTextFormat = new TextFormat("_typewriter", 15, 0xffffff, true, null, null, null, null, "center");
			stats.autoSize = "center";
			stats.text = "";
			stats.appendText("Time Played: " + timePlayed + "s\n");
			stats.appendText("Shots Fired: " + shotsFired + "\n");
			stats.appendText("Enemies Killed: " + enemiesKilled + "\n");
			stats.appendText("Accuracy: " + accuracyPercentage + "%\n");
			stats.selectable = false;
			addChild(stats);
			
			// Submit stats to Kongregate
			Game.main.kongregate.stats.submit('Time Played', timePlayed);
			Game.main.kongregate.stats.submit('Shots Fired', shotsFired);
			Game.main.kongregate.stats.submit('Enemies Killed', enemiesKilled);
			Game.main.kongregate.stats.submit('Accuracy', accuracyPercentage);
			
			// Submit time "score"
			//Game.main.kongregate.scores.setMode('Normal');
			//Game.main.kongregate.scores.submit(timePlayed);
			
			// Display button to play again
			var playButton:TextField = new TextField;
			playButton.x = (GameState.WIDTH - playButton.width) / 2;
			playButton.y = 300;
			playButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			playButton.autoSize = "center";
			playButton.text = "Play Again";
			playButton.selectable = false;
			addChild(playButton);
			
			// Display button to quit
			var quitButton:TextField = new TextField;
			quitButton.x = (GameState.WIDTH - quitButton.width) / 2;
			quitButton.y = 340;
			quitButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			quitButton.autoSize = "center";
			quitButton.text = "Quit";
			quitButton.selectable = false;
			addChild(quitButton);
			
			// Can probably improve this by just calling another function in the GameState class to start the play state over
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); } );
			playButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			quitButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(MenuState); } );
			quitButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			quitButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
		}
		
		private function winGame():void 
		{
			gameOver = true;
			Game.main.cursor.visible = true;
			soundChannel.stop();
			
			// Remove all bullets, enemies
			while(bullets.length > 0) bullets.splice(0, 1);
			while(enemyBullets.length > 0) enemyBullets.splice(0, 1);
			while(enemies.length > 0) enemies.splice(0, 1);
			
			// Make the screen flash white
			var cr:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 255, 255);
			_canvas.colorTransform(cr, ct);
			
			// Figure out some stats
			var accuracyPercentage:String = String(Math.round(enemiesKilled / shotsFired * 1000) / 10);
			if (accuracyPercentage == "NaN") accuracyPercentage = "0";		// If division by zero 'cos no shots fired
			var timePlayed:String = timerDisplay.text;
			
			// Display "game over" title
			var title:TextField = new TextField;
			title.x = (GameState.WIDTH - title.width) / 2;
			title.y = 20;
			title.defaultTextFormat = new TextFormat("_typewriter", 30, 0xffffff, true);
			title.autoSize = "center";
			title.text = "A WINNER\n IS YOU";
			title.selectable = false;
			addChild(title);
			
			// Display stats
			var stats:TextField = new TextField;
			stats.x = (GameState.WIDTH - stats.width) / 2;
			stats.y = 100;
			stats.defaultTextFormat = new TextFormat("_typewriter", 15, 0xffffff, true, null, null, null, null, "center");
			stats.autoSize = "center";
			stats.text = "";
			stats.appendText("Time Played: " + timePlayed + "s\n");
			stats.appendText("Shots Fired: " + shotsFired + "\n");
			stats.appendText("Enemies Killed: 1000\n");
			stats.appendText("Accuracy: " + accuracyPercentage + "%\n");
			stats.selectable = false;
			addChild(stats);
			
			// Submit stats to Kongregate
			Game.main.kongregate.stats.submit('Time Played', timePlayed);
			Game.main.kongregate.stats.submit('Shots Fired', shotsFired);
			Game.main.kongregate.stats.submit('Enemies Killed', 1000);
			Game.main.kongregate.stats.submit('Accuracy', accuracyPercentage);
			
			// Submit time "score"
			Game.main.kongregate.scores.setMode('Normal');
			Game.main.kongregate.scores.submit(timePlayed);
			
			// Display button to play again
			var playButton:TextField = new TextField;
			playButton.x = (GameState.WIDTH - playButton.width) / 2;
			playButton.y = 300;
			playButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			playButton.autoSize = "center";
			playButton.text = "Play Again?";
			playButton.selectable = false;
			addChild(playButton);
			
			// Display button to quit
			var quitButton:TextField = new TextField;
			quitButton.x = (GameState.WIDTH - quitButton.width) / 2;
			quitButton.y = 340;
			quitButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			quitButton.autoSize = "center";
			quitButton.text = "Quit";
			quitButton.selectable = false;
			addChild(quitButton);
			
			// Can probably improve this by just calling another function in the GameState class to start the play state over
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); } );
			playButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			quitButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(MenuState); } );
			quitButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			quitButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
		}
		
		private function updateKeys():void
		{
			for(var i:int = 0; i < _keys.length; i++)
				if(_keys[i] > 0) _keys[i] = 2;
		}
		
		public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			Game.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { if(_keys[e.keyCode] == 0) _keys[e.keyCode] = 1; } );
		   	Game.main.stage.removeEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { _keys[e.keyCode] = 0; } );
		}
	}
}
