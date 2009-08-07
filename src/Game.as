//
//  Armada
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

package
{
	
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import com.kongregate.as3.client.KongregateAPI;
	
	public class Game extends Sprite
	{
		static public var main:Object;
		static public var currentState:*;
		
		[Embed(source = "../graphics/cursor-white.svg")] private var WhiteCursor:Class;
		[Embed(source = "../graphics/cursor-black.svg")] private var BlackCursor:Class;
		
		public var cursor:Sprite = new Sprite;
		public var kongregate:KongregateAPI = new KongregateAPI;
		
		public function Game():void
		{
			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void
		{
			// Entry point
			main = this;
			switchState(MenuState);
			
			// For custom mouse cursor
			Mouse.hide();
			cursor.addChild(new WhiteCursor);
			cursor.addChild(new BlackCursor);
			cursor.visible = false;
			addChild(cursor);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent):void { cursor.visible = true;  cursor.x = e.stageX; cursor.y = e.stageY; } );
			stage.addEventListener(Event.MOUSE_LEAVE, function (e:Event):void { cursor.visible = false; } );
			
			// Add Kongregate component
			addChild(kongregate);
		}
		
		public function swapCursorState(e:Event = null):void 
		{
			cursor.swapChildrenAt(0, 1);
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