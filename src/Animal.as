package
{
    
    import flash.display.MovieClip;

	import fl.transitions.Tween;
	import fl.transitions.easing.*;

	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Quad;
    
    public class Animal extends MovieClip
    {
        public var row:int;
        public var column:int;
        public var moving:Boolean=false;
        public var moved:Boolean=false;
        public var removed:Boolean=false;

        public function Animal()
        {
			mouseEnabled = true;
			buttonMode = true;
        }

        public function moveTo(duration:Number, targetX:Number, targetY:Number)
        {
        	moving = true;

        	Actuate.tween(this, duration, { x: targetX, y: targetY } )
        	       .ease(Quad.easeOut)
        	       .onComplete(this_onMoveToComplete);
        }

		public function remove(animate:Boolean=true):void
		{
			if (!removed) {
				if (animate) {
					mouseEnabled = false;
					buttonMode = false;
					
					parent.addChildAt(this, 0);
					gotoAndPlay("over");
					
				} else {
				}
			}
			removed = true;
		}

		function this_onMoveToComplete():void
		{
			moving = false;
		}

    }
}
