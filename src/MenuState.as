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
		
		private var _canvas:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0xffffff);
		
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
			for(var i:int = 0; i < MAX_STARS; i++)
				stars.push(new Actor(Math.random() * WIDTH, Math.random() * HEIGHT, starShape, 0, Math.random() * 3 + 2));
			
			// Show game title
			title.x = (GameState.WIDTH - title.width) / 2;
			title.y = 10;
			title.defaultTextFormat = new TextFormat("_typewriter", 30, 0xffffff, true);
			title.autoSize = "center";
			title.text = "ARMADA";
			addChild(title);
			
			// Show "play" button
			playButton.x = (GameState.WIDTH - playButton.width) / 2;
			playButton.y = 300;
			playButton.defaultTextFormat = new TextFormat("_typewriter", 20, 0xffffff, true);
			playButton.autoSize = "center";
			playButton.text = "Play";
			playButton.buttonMode = true;
			addChild(playButton);
			
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); stage.focus = this; });
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
		}
		
		public function destroy():void
		{
			removeChild(title);
			removeChild(playButton);
			playButton.removeEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); });
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);	// To update starry background
		}
	}
}