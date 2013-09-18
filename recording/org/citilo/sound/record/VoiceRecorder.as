package org.citilo.sound.record {
	import flash.utils.ByteArray;

	public class VoiceRecorder {
		public var minDuration:Number;
		public var maxDuration:Number;
		private var _recorder:StandardMicrophoneRecorder;
		public function VoiceRecorder() {
			_recorder=new StandardMicrophoneRecorder();
		}
		public function prepare():void{
			_recorder.prepare();
		}
		public function record():void{
			_recorder.resume();
		}
		public function stop():void{
			_recorder.stop();
		}
		public function get recorder():StandardMicrophoneRecorder{
			return _recorder;
		}
		public function getRecordedVoice():ByteArray{
			return _recorder.recordData;
		}
	}
}
