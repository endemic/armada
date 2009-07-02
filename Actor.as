package
{
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.display.BitmapData;
	
	public class Actor
	{
		public var position:Point = new Point(0, 0);
		public var velocity:Point = new Point(0, 0);
		public var acceleration:Point = new Point(0, 0);
		public var rotation:Number = 1.57079633;		// 90 degrees, neutral
		
		public var bitmap:BitmapData;
		public var width:int;
		public var height:int;
		public var ticksSinceSpawned:int = 0;
		
		public function Actor(X:Number, Y:Number, s:Shape, VelX:Number = 0, VelY:Number = 0):void
		{
			position.x = X; position.y = Y;
			width = s.width; height = s.height;
			
			bitmap = new BitmapData(s.width, s.height, true, 0xffffff);
			bitmap.draw(s);
			
			velocity.x = VelX; velocity.y = VelY;
		}
		
		public function update():Boolean
		{
			ticksSinceSpawned++;
			
			position.x += velocity.x;
			position.y += velocity.y;
			
			if(position.x < 0 || position.x > GameState.WIDTH || position.y < 0 || position.y > GameState.HEIGHT) return false;
			return true;
		}
		
		public function collidesWith(a:Actor):Boolean {
			
			var other:Object = { 
				left: a.position.x - a.width,
				right: a.position.x,
				top: a.position.y,
				bottom: a.position.y - a.height
			};
			
			var self:Object = {
				left: position.x - width,
				right: position.x,
				top: position.y,
				bottom: position.y - height
			};
			
			// Simple AABB collision detection
			if(other.left > self.right || other.right < self.left || other.bottom > self.top || other.top < self.bottom) return false;
			
			// If still here, that means a collision
			return true
		}
	}
}