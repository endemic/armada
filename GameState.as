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
	
	import flash.text.TextField;
	import flash.text.TextFormat;
		
	[SWF(width="200", height="400", frameRate="30", backgroundColor="0x000000")]
	
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
		private var enemyShape:Shape = new Shape;
		private var bulletShape:Shape = new Shape;
		private var enemyBulletShape:Shape = new Shape;
		private var starShape:Shape = new Shape;
		private var particleShape:Shape = new Shape;
		
		private var spacePressed:Boolean;
		
		// Scoring, display, etc.
		private var enemiesKilled:int = 0;
		private var enemiesKilledDisplay:TextField = new TextField;
		private var timerDisplay:TextField = new TextField;
		
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
			shipShape.graphics.beginFill(0xffffff);
			shipShape.graphics.moveTo(5, 0);
			shipShape.graphics.lineTo(10, 10);
			shipShape.graphics.lineTo(0, 10);
			shipShape.graphics.lineTo(5, 0);
			shipShape.graphics.endFill();
			
			// Create shape for enemies
			enemyShape.graphics.lineStyle(2, 0xff0000);
			enemyShape.graphics.moveTo(5, 0);
			enemyShape.graphics.lineTo(10, 10);
			enemyShape.graphics.lineTo(0, 10);
			enemyShape.graphics.lineTo(5, 0);
			
			// Create shape for bullet
			bulletShape.graphics.lineStyle(1, 0xffffff);
			bulletShape.graphics.drawCircle(1, 1, 1);
			
			// Create shape for enemy bullet
			enemyBulletShape.graphics.lineStyle(1, 0x00ff00);
			enemyBulletShape.graphics.drawCircle(2, 2, 2);
			
			// Create shape for stars
			starShape.graphics.lineStyle(1, 0x666666);
			starShape.graphics.drawCircle(0, 0, 1);
			
			// Create shape for explosion particles
			particleShape.graphics.lineStyle(1, 0xff0000);
			particleShape.graphics.drawCircle(0, 0, 1);
			
			// Create "hoshizora" background
			for(var i:int = 0; i < MAX_STARS; i++)
				stars.push(new Actor(Math.random() * WIDTH, Math.random() * HEIGHT, starShape, 0, Math.random() * 3 + 2));
			
			// Add some random enemies
			for(i = 0; i < 5; i++)
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShape));
			
			// Init player
			player = new Actor(100, 300, shipShape);
			
			// Init keyboard values
			for(i = 0; i < _keys.length; i++) _keys[i] = 0;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { if(_keys[e.keyCode] == 0) _keys[e.keyCode] = 1; } );
		    stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { _keys[e.keyCode] = 0; } );
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
			timerDisplay.text = String(Math.round(seconds * 10) / 10);
			if(timerDisplay.text.indexOf(".") == -1) timerDisplay.appendText(".0");	// Append .0 if a whole number
			
			// Counters
			var i:int = 0, j:int = 0;
			
			// Update player position
			if (_keys[0x25] || _keys[0x41]) player.position.x += -1; 
	        if (_keys[0x26] || _keys[0x57]) player.position.y += -1; 
	        if (_keys[0x27] || _keys[0x44]) player.position.x +=  1; 
	        if (_keys[0x28] || _keys[0x53]) player.position.y +=  1;
			
			// Shoot
			if(_keys[32] == 1)
				bullets.push(new Actor(player.position.x, player.position.y, bulletShape, 0, -5));
			
			// Update enemy position
			for(i = 0; i < enemies.length; i++)
			{
				// Change velocity based on rotation
				enemies[i].velocity.x = Math.cos(enemies[i].rotation);
				enemies[i].velocity.y = Math.sin(enemies[i].rotation);
				
				// Move 'em
				enemies[i].update();
				
				// Shoot every so often - between 1 - 3 seconds
				if(enemies[i].ticksSinceSpawned % (60 * int(Math.random() * 3 + 1)) == 0)
					enemyBullets.push(new Actor(enemies[i].position.x + Math.cos(enemies[i].rotation) - enemies[i].width / 2, enemies[i].position.y + Math.sin(enemies[i].rotation) - enemies[i].height / 2, enemyBulletShape, Math.cos(enemies[i].rotation) * 2, Math.sin(enemies[i].rotation) * 2));
			}
			
			// Spawn a new enemy every 5 seconds
			if(_ticks % 300 == 0)
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShape));
			
			// Update bullet position
			for(i = 0; i < bullets.length; i++)
			{
				if(!bullets[i].update())
				{
					bullets.splice(i, 1);
					i--;
					continue;
				}
				
				// Check collisions between player bullets and enemies
				for(j = 0; j < enemies.length; j++)
				{
					if(enemies[j].collidesWith(bullets[i]))
					{
						// Create particle explosion
						for(var k:int = 0; k < MAX_PARTICLES; k++)
						{	
							var particleDirection:Number = Math.random() * 2 * Math.PI;		// Random angle in radians
							particles.push(new Actor(enemies[j].position.x, enemies[j].position.y, particleShape, Math.cos(particleDirection) * 2, Math.sin(particleDirection) * 2));
						}
						
						// Destroy enemy, but instantly create a new one to take its place
						enemies.splice(j, 1, new Actor(Math.random() * WIDTH, 0, enemyShape));
						
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
				if(enemyBullets[i].collidesWith(player))
					resetGame();
					
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
			
			// Spawn some new enemies
			for(var i:int = 0; i < 5; i++)
				enemies.push(new Actor(Math.random() * WIDTH, 0, enemyShape));
				
			// Reset player
			player.position.x = 100;
			player.position.y = 300;
		}
		
		private function updateKeys():void
		{
			for(var i:int = 0; i < _keys.length; i++)
				if(_keys[i] > 0) _keys[i] = 2;
		}
	}
}