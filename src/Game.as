//
//  Armada
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

package
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Game extends Sprite
	{
		static public var main:Object;
		static public var currentState:*;
		
		public function Game():void
		{
			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void
		{
			// Entry point
			main = this;
			switchState(GameState);
		}
		
		static public function switchState(state:Class):void
		{
			var newState:* = new state;
			main.addChild(newState);
			
			if(currentState != null)
			{
				main.swapChildren(newState, currentState);
				main.removeChild(currentState);	
				currentState.destroy();
			}
			
			currentState = newState;
		}
	}
}