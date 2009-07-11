//
//  Preloader
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
// To compile: mxmlc Preloader.as -frame start Map -output Map.swf

package {
	import flash.events.Event;
	import flash.display.*;
	import flash.utils.getDefinitionByName;
	
	[SWF(width="200", height="400", frameRate="30", backgroundColor="0x000000")]
	
	public class Preloader extends MovieClip 
	{
		public function Preloader() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			addEventListener(Event.ENTER_FRAME, checkFrame);
			//shows Preloader
 
		}
 
		private function checkFrame(e:Event):void 
		{
			//Updates Preloader
			if (currentFrame == totalFrames) {
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				startup();
			}
		}
 
		private function startup():void 
		{
			//Hides Preloader
			stop();
			var mainClass:Class = getDefinitionByName("Game") as Class;
			addChild(new mainClass() as DisplayObject);
		}
	}
}