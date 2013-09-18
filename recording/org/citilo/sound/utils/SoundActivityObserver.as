package org.citilo.sound.utils
{
	import org.osflash.signals.Signal;

	public class SoundActivityObserver
	{
		private var _activityLevel:Number;
		private var _muteThreshold:ThresholdTimer;
		private var _recordThreshold:ThresholdTimer;
		
		public var recordSatisfied:Signal=new Signal();
		public var muteSatisfied:Signal=new Signal();
		public function SoundActivityObserver(){
			_muteThreshold=new ThresholdTimer();
			_recordThreshold=new ThresholdTimer();
			reset();
		}
		public function get muteDelay():int{
			return _muteThreshold.delay;
		}
		public function get recordDelay():int{
			return _recordThreshold.delay;
		}
		public function reset():void{
			_recordThreshold.reset();
			_muteThreshold.reset();
			_recordThreshold.satisfiedSignal.addOnce(onRecordSatisfied);
		}
		
		private function onRecordSatisfied():void{
			_muteThreshold.satisfiedSignal.addOnce(onMuteSatisfied);
			recordSatisfied.dispatch();
		}
		private function onMuteSatisfied():void{
			_recordThreshold.satisfiedSignal.addOnce(onRecordSatisfied);
			muteSatisfied.dispatch();
		}
		
		public function setMuteThreshold(threshold:int, duration:int):void{
			_muteThreshold.setThreshold(threshold,duration,ThresholdTimer.KEEP_BELOW);	
		}
		
		public function setRecordThreshold(threshold:int, duration:int):void{
			_recordThreshold.setThreshold(threshold,duration,ThresholdTimer.KEEP_ABOVE);	
		}
		
		public function updateLevel(activityLevel:Number):void{
			trace("updateLevel",activityLevel);
			_activityLevel=activityLevel;
			_muteThreshold.test(activityLevel);
			_recordThreshold.test(activityLevel);
		}
	}
}