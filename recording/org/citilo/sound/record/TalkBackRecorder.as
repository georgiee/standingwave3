package org.citilo.sound.record {
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.elements.Sample;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.sources.SamplerSource;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	
	import org.citilo.sound.format.SoundBytesToSample;
	import org.osflash.signals.Signal;

	public class TalkBackRecorder {
		private var _recorder:EndlessMicrophoneRecorder;
		private var _pitch:Number=0;
		private var _currentPlayback:IAudioSource;
		private var _player:AudioPlayer
		
		public var microphoneStatusChanged:Signal=new Signal;
		public var rejectedPermissionSignal:Signal=new Signal;
		
		public function isMuted():Boolean{
			return _recorder.isMuted();
		}
		public function TalkBackRecorder() {
			init();
		}

		public function get player():AudioPlayer {
			return _player;
		}

		public function set player(value:AudioPlayer):void {
			_player=value;
			if(_player){
				_player.addEventListener(Event.SOUND_COMPLETE,onPlaybackComplete);
				_player.addEventListener(ProgressEvent.PROGRESS,onProgress);
			}
		}

		public function get pitch():Number {
			return _pitch;
		}

		public function set pitch(value:Number):void {
			_pitch=value;
		}

		private function init():void {
			_recorder=new EndlessMicrophoneRecorder(5000);
			_recorder.silenceSignal.add(onSilenceDetected);
		}
		
		private function handleMicrophoneStatusChanged(accessible:Boolean):void{
			trace("handleMicrophoneStatusChanged",accessible);
			if(!accessible) rejectedPermissionSignal.dispatch();
			microphoneStatusChanged.dispatch(accessible);
		}
		
		/*INTERFACE*/
		public function stop():void {
			_player.stop();
			_recorder.stop();
		}

		public function record():void {
			_recorder.microphoneStatusChanged.add(handleMicrophoneStatusChanged);
			_recorder.record();
		}

		public function clearBuffer():void {
			_recorder.clearBuffer();
		}

		public function playNow():void {
			startPlayback();
		}

		public function debugToggle():void {
			_recorder.debugToggle();
		}

		/*CORE*/
		protected function handleSilence():void {
			startPlayback();
		}

		/*HELPER*/
		private function getRecordedSample():Sample {
			var bytes:ByteArray=_recorder.getBufferContent();
			var sampleRaw:Sample=SoundBytesToSample.createSample(bytes,AudioDescriptor.RATE_44100);
			
			var cleanLeft:int=_recorder.activityWindow.leftSilence * AudioDescriptor.RATE_44100/1000
			var cleanRight:int=_recorder.activityWindow.rightSilence * AudioDescriptor.RATE_44100/1000
			
			var sampleClean:Sample=sampleRaw.getSampleRange(cleanLeft, sampleRaw.frameCount - cleanRight);
			return sampleClean;
		}

		private function startPlayback():void {
			_recorder.pause();
			
			var sample:Sample=getRecordedSample();
			_currentPlayback=new ResamplingFilter(sample, _pitch);
			_player.play(_currentPlayback);
		}

		/*PLAYER CALLBACKS*/
		private function onSilenceDetected():void {
			trace("onSilenceDetected");
			var bufferFillStatus:Boolean=_recorder.bufferStatus.isBufferFullEnough(0.3);
			if (bufferFillStatus) {
				handleSilence();
			}
		}
		public function resume():void{
			_recorder.resume();
		}
		protected function onPlaybackComplete(event:Event):void {
			trace("onPlaybackComplete");
			_recorder.resume(500);
		}

		protected function onProgress(event:Event):void {
			//trace(_player.position);
		}

		/*ACCESSOR*/
		public function get recorder():EndlessMicrophoneRecorder {
			return _recorder;
		}
	}
}