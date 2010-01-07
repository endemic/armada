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
	
	//import caurina.transitions.Tweener;
	
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
			/*scoresButton.x = (GameState.WIDTH - scoresButton.width) / 2;
			scoresButton.y = 330;
			scoresButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			scoresButton.autoSize = "center";
			scoresButton.text = "Best Times";
			scoresButton.selectable = false;
			scoresButton.visible = true;
			addChild(scoresButton);*/
			
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
			//scoresButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.main.kongregate.scores.requestList(showScores) });	// Request kongregate list and add "showScores" as a callback
			//scoresButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			//scoresButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			// Etc.
			creditsButton.addEventListener(MouseEvent.MOUSE_DOWN, function (e:Event):void { navigateToURL(new URLRequest('http://www.bitter-gamer.com/'), '_blank') });
			creditsButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			creditsButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
		}
		
		private function showScores(result:Object):void 
		{
			//title.visible = false;
			title.text = "BEST TIMES";
			
			playButton.visible = false;
			scoresButton.visible = false;
			creditsButton.visible = false;
			
			var scoresText:TextField = new TextField;
			scoresText.x = 10;
			scoresText.y = 60;
			scoresText.width = GameState.WIDTH - 20;
			scoresText.defaultTextFormat = new TextFormat("_typewriter", 12, 0xffffff, true);
			scoresText.autoSize = "left";
			scoresText.selectable = false;
			scoresText.text = "";
			addChild(scoresText);
			
			// Populate the "result" object for local testing purposes
			if(!result.success)
			{
				var result:Object = new Object;
				result.list = 
				{
					0: { 'username': 'user1', 'score': '320s' },
					1: { 'username': 'user2', 'score': '330s' },
					2: { 'username': 'user3', 'score': '340s' },
					3: { 'username': 'user4', 'score': '350s' },
					4: { 'username': 'user5', 'score': '320s' },
					5: { 'username': 'user6', 'score': '320s' },
					6: { 'username': 'user7', 'score': '320s' },
					7: { 'username': 'user8', 'score': '320s' },
					8: { 'username': 'user9', 'score': '320s' },
					9: { 'username': 'user0', 'score': '320s' }
				}
			}
			
			// Only show 10 results
			for(var i:int = 0; i < result.list.length; i++)
			{
				var position:int = i + 1;
				if(position < 10)
					scoresText.appendText("\n " + position + ". " + result.list[i].username + ' - ' + result.list[i].score);	// Adds an extra space
				else if(position == 10)
					scoresText.appendText("\n" + position + ". " + result.list[i].username + ' - ' + result.list[i].score);
				else
					scoresText.appendText("");
			}
			
			// Display button to reset to main screen
			var returnButton:TextField = new TextField;
			returnButton.x = (GameState.WIDTH - returnButton.width) / 2;
			returnButton.y = 320;
			returnButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			returnButton.autoSize = "center";
			returnButton.text = "Back";
			returnButton.selectable = false;
			addChild(returnButton);
			
			returnButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(MenuState); } );
			returnButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			returnButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
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