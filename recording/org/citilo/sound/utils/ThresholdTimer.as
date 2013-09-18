package org.citilo.sound.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	public class ThresholdTimer
	{
		public static var KEEP_ABOVE:String="above";
		public static var KEEP_BELOW:String="below";
		private var _mode:String;
		private var _duration:int;
		private var _threshold:Number;
		private var _timer:Timer;
		private var _satisfied:Boolean=false;
		public var satisfiedSignal:Signal=new Signal();
		public function ThresholdTimer(){
			_timer=new Timer(0,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onSatisfied);
		}
		
		protected function onSatisfied(event:TimerEvent):void{
			_satisfied=true;
			satisfiedSignal.dispatch();
		}
		public function get delay():int{
			return _duration;
		}
		public function setThreshold(threshold:Number, duration:int, mode:String):void{
			_mode=mode;
			_threshold=threshold;
			_duration=duration;
			
			_timer.delay=duration;
		}
		
		public function test(value:Number):void{
			var testResult:Boolean=false;
			switch(_mode){
				case KEEP_BELOW: testResult=value<=_threshold;break;
				case KEEP_ABOVE: testResult=value>_threshold;break;
				default:testResult = false;
			}
			if(!testResult){
				stop();
			}else if(testResult && !_timer.running && !_satisfied){
				start();
			}
		}
		
		private function start():void{
			_timer.start();
		}
		private function stop():void{
			_satisfied=false;
			_timer.stop();
			_timer.reset();
		}
		public function reset():void{
			satisfiedSignal.removeAll();
			stop();
		}
	}
}