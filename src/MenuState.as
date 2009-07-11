//
//  MenuState
//
//  Created by Nathan Demick on 2009-07-06.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

package
{
	import flash.display.Sprite;
	
	public class MenuState extends Sprite {
		public function MenuState():void
		{
			var s:Sprite = new Sprite;
			s.graphics.lineStyle(2, 0xff0000);
			s.graphics.moveTo(5, 0);
			s.graphics.lineTo(10, 10);
			s.graphics.lineTo(0, 10);
			s.graphics.lineTo(5, 0);
			addChild(s)
		}
		
		public function destroy():void
		{
			
		}
	}
}