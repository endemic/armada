//
//  MenuState
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

package
{
	import flash.display.Sprite;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MenuState extends Sprite 
	{
		private var title:TextField = new TextField;
		private var playButton:TextField = new TextField;
		
		public function MenuState():void
		{
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
			addChild(playButton);
			
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { Game.switchState(GameState); });
		}
		
		public function destroy():void
		{
			removeChild(title);
			removeChild(playButton);
		}
	}
}