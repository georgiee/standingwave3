package org.citilo.sound.record {
	import com.greensock.TweenMax;
	
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	import org.osflash.signals.Signal;

	public class AbstractMicrophoneRecorder extends EventDispatcher {
		private var _gain:uint;
		private var _rate:uint;
		private var _microphone:Microphone;
		private var _pause:Boolean=false;
		public var accessible:Boolean=false;
		public var microphoneStatusChanged:Signal=new Signal;
		
		public function AbstractMicrophoneRecorder(microphone:Microphone=null, gain:uint=85, rate:uint=44) {
			_microphone=microphone;
			_gain=gain;
			_rate=rate;
		}
		protected function fetchMicrophoneInstance():Microphone{
			return Microphone.getMicrophone();
		}
		public function startMicrophone():void{
			trace("startMicrophone");
			if (_microphone == null || true){
				trace("startMicrophone inner");
				_microphone=fetchMicrophoneInstance();
				_microphone.addEventListener(StatusEvent.STATUS,onMicrophoneStatusChanged);
				accessible=!_microphone.muted;
			}
			
		}
		public function isMuted():Boolean{
			if(_microphone==null) return true;
			
			return _microphone.muted;
		}
		public function record():void {
			trace("*****record");
			_pause=true;
			startMicrophone();
			
			_microphone.setSilenceLevel(0); //FORCE ZERO, we DO want to record silent parts
			_microphone.gain=_gain;
			
			_microphone.rate=_rate;
			_microphone.encodeQuality=10;
			_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		}
		
		protected function onMicrophoneStatusChanged(event:StatusEvent):void{
			accessible=!_microphone.muted;
			microphoneStatusChanged.dispatch(accessible);
		}
		
		public function stop():void {
			if(_microphone) _microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			_pause=true;			
			cleanup();
		}
		
		protected function cleanup():void{
			TweenMax.killDelayedCallsTo(_resume);
		}
		
		public function resume(delay:Number=0):void {
			if(delay>0){
				TweenMax.killDelayedCallsTo(_resume);
				TweenMax.delayedCall(delay/1000,_resume);
			}else{
				_resume();
			}
		}
		protected function _resume():void{
			_pause=false;
		}

		public function pause():void {
			TweenMax.killDelayedCallsTo(_resume);
			_pause=true;
		}

		private function onSampleData(event:SampleDataEvent):void {
			trace("onSampleData",_pause)
			if (_pause) return;
			handleSampleData(event.data);
		}

		protected function handleSampleData(bytes:ByteArray):void {
		}
		
		/*ACCESSOR*/
		public function get gain():uint {
			return _gain;
		}
		public function set gain(value:uint):void {
			_gain=value;
		}
		
		public function get rate():uint {
			return _rate;
		}
		public function set rate(value:uint):void {
			_rate=value;
		}
		public function get microphone():Microphone {
			return _microphone;
		}
		
		public function set microphone(value:Microphone):void {
			_microphone=value;
		}
		public function get activityLevel():int{
			return _microphone.activityLevel;
		}
	}
}
