package
{
	import caurina.transitions.properties.SoundShortcuts;
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
		public var width:Number;
		public var height:Number;
		public var ticksSinceSpawned:int = 0;
		public var spawnNumber:int = 0;
		// Add "spawnNumber" here... use an array to push enemy shapes/explosions
		// i.e. spawnNumber = 103, create enemy/particles with enemyShape[103], particleShape[103]
		public function Actor(X:Number, Y:Number, s:Shape, VelX:Number = 0, VelY:Number = 0, SpawnNumber:int = 0):void
		{
			position.x = X; position.y = Y;
			width = s.width; height = s.height;
			
			bitmap = new BitmapData(s.width, s.height, true, 0xffffff);
			bitmap.draw(s);
			
			velocity.x = VelX; velocity.y = VelY;
			
			// Used to keep track of what color/shape to use for the instance
			spawnNumber = SpawnNumber;
		}
		
		public function update():Boolean
		{
			ticksSinceSpawned++;
			
			position.x += velocity.x;
			position.y += velocity.y;
			
			if(position.x < 0 || position.x > GameState.WIDTH || position.y < 0 || position.y > GameState.HEIGHT) return false;
			return true;
		}
		
		public function collidesWith(a:Actor):Point {
			
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
			
			var projectionVector:Point = new Point(0, 0);
			
			// Simple AABB collision detection
			if(other.left > self.right || other.right < self.left || other.bottom > self.top || other.top < self.bottom) return null;
			
			// Calculate the projection vector to push objects out of each other
			if (Math.abs(other.left - self.right) > Math.abs(self.left - other.right))
				projectionVector.x = self.left - other.right;
			else
				projectionVector.x = other.left - self.right;
			
			if (Math.abs(other.bottom - self.top) > Math.abs(other.top - self.bottom))
				projectionVector.y = other.top - self.bottom;
			else
				projectionVector.y = other.bottom - self.top;
			
			// Find the smallest one
			if (Math.abs(projectionVector.x) > Math.abs(projectionVector.y))
				projectionVector.x = 0;
			else
				projectionVector.y = 0;
				
			// If still here, that means a collision
			return projectionVector;
		}
	}
}