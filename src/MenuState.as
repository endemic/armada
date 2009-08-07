//
//  MenuState
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

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
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import caurina.transitions.Tweener;
	
	public class MenuState extends Sprite 
	{
		private var title:TextField = new TextField;
		private var playButton:TextField = new TextField;
		private var scoresButton:TextField = new TextField;
		private var creditsButton:TextField = new TextField;
		
		private var _canvas:BitmapData = new BitmapData(GameState.WIDTH, GameState.HEIGHT, false, 0xffffff);
		
		private var stars:Array = new Array;
		private var starShape:Shape = new Shape;
		
		public function MenuState():void
		{
			// Do all drawing on this
			addChild(new Bitmap(_canvas));
			
			// Create shape for stars
			starShape.graphics.lineStyle(1, 0x666666);
			starShape.graphics.drawCircle(0, 0, 1);
			
			// Create "hoshizora" background
			for(var i:int = 0; i < GameState.MAX_STARS; i++)
				stars.push(new Actor(Math.random() * GameState.WIDTH, Math.random() * GameState.HEIGHT, starShape, 0, Math.random() * 3 + 2));
			
			// Show game title
			title.x = (GameState.WIDTH - title.width) / 2;
			title.y = 20;
			title.defaultTextFormat = new TextFormat("_typewriter", 30, 0xffffff, true);
			title.autoSize = "center";
			title.text = "ARMADA";
			title.selectable = false;
			addChild(title);
			
			// Show "play" button
			playButton.x = (GameState.WIDTH - playButton.width) / 2;
			playButton.y = 300;
			playButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			playButton.autoSize = "center";
			playButton.text = "Play";
			playButton.selectable = false;
			addChild(playButton);
			
			// Show "story" button
			scoresButton.x = (GameState.WIDTH - scoresButton.width) / 2;
			scoresButton.y = 330;
			scoresButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			scoresButton.autoSize = "center";
			scoresButton.text = "Best Times";
			scoresButton.selectable = false;
			scoresButton.visible = true;
			addChild(scoresButton);
			
			// Show "credits" button
			creditsButton.x = (GameState.WIDTH - creditsButton.width) / 2;
			creditsButton.y = 380;
			creditsButton.defaultTextFormat = new TextFormat("_typewriter", 10, 0xffffff, true);
			creditsButton.autoSize = "center";
			creditsButton.text = "bitter-gamer.com";
			creditsButton.selectable = false;
			addChild(creditsButton);
			
			// Event listeners for "play" button
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); } );
			playButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			// Add event listeners for "scores" button
			scoresButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.main.kongregate.scores.requestList(showScores) });	// Request kongregate list and add "showScores" as a callback
			scoresButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			scoresButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			// Etc.
			creditsButton.addEventListener(MouseEvent.MOUSE_DOWN, function (e:Event):void { navigateToURL(new URLRequest('http://www.bitter-gamer.com/'), '_blank') });
			creditsButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			creditsButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
		}
		
		private function showScores(result:Object):void 
		{
			title.visible = false;
			playButton.visible = false;
			scoresButton.visible = false;
			creditsButton.visible = false;

			var scoresText:TextField = new TextField;
			scoresText.x = 10;
			scoresText.y = 20;
			scoresText.width = GameState.WIDTH - 20;
			scoresText.defaultTextFormat = new TextFormat("_typewriter", 12, 0xffffff, true);
			scoresText.autoSize = "left";
			//storyText.wordWrap = true;
			scoresText.selectable = false;
			//storyText.text = "Earth is at war. The evil Hisnap Armada has been terrorizing the galaxy for years, systema- tically conquering one civilization after another. Your fighter squadron was the last line of defense against the Hisnaps. Their Armada is attacking today. The problem is that your squadmates all drank a little too much last night, and are nursing powerful, gut-wrenching hangovers. You probably can't count on them in a fight. It's up to you to destroy the Hisnaps by yourself. They're not too smart, but there are a lot of 'em. Are you up to the challenge?";
			scoresText.text = "";
			addChild(scoresText);
			
			for(var i:int = 0; i < result.list.length; i++)
			{
				var position:int = i + 1;
				scoresText.appendText("\n" + position + ". " + result.list[i].username + ' - ' + result.list[i].score);
			}
			
			//Tweener.addTween(storyText, { transition: 'linear', y: 0 - storyText.height, time: 20, onComplete: function():void { storyText.visible = false; title.visible = true; playButton.visible = true; storyButton.visible = true; } } );
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

			// Draw stars
			for each(var star:Actor in stars)
				_canvas.copyPixels(star.bitmap, star.bitmap.rect, star.position);

			// Unlock canvas
			_canvas.unlock();
			
			/**
			END DRAWING
			*/
			
			// Update star position
			for(var i:int = 0; i < stars.length; i++)
				if(!stars[i].update())
					stars.splice(i, 1, new Actor(Math.random() * GameState.WIDTH, 0, starShape, 0, Math.random() * 3 + 2)); 
		}
		
		public function destroy():void
		{
			removeChild(title);
			removeChild(playButton);
			removeChild(scoresButton);
			playButton.removeEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); });
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
		}
	}
}