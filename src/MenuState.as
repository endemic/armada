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
	
	public class MenuState extends Sprite 
	{
		private var title:TextField = new TextField;
		private var playButton:TextField = new TextField;
		private var storyButton:TextField = new TextField;
		
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
			storyButton.x = (GameState.WIDTH - storyButton.width) / 2;
			storyButton.y = 330;
			storyButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			storyButton.autoSize = "center";
			storyButton.text = "Story";
			storyButton.selectable = false;
			addChild(storyButton);
			
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); } );
			playButton.addEventListener(MouseEvent.MOUSE_OVER, Game.main.swapCursorState);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, Game.main.swapCursorState);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
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
			removeChild(storyButton);
			playButton.removeEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); });
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
		}
	}
}