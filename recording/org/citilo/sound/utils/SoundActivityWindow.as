package org.citilo.sound.utils {
	import org.citilo.sound.buffering.CircularBufferPosition;
	import org.citilo.sound.buffering.SoundBufferCircular;
	import org.osflash.signals.Signal;

	public class SoundActivityWindow {
		private var _soundActivityObserver:SoundActivityObserver;
		private var _buffer:SoundBufferCircular;
		private var _silencePosition:int=-1;
		private var _recordPosition:int=-1;
		private var _calculatedLeftSilence:int=0;
		private var _calculatedRightSilence:int=0;
		public var silenceSignal:Signal=new Signal();
		public var verbose:Boolean=false;

		public function SoundActivityWindow(buffer:SoundBufferCircular, silenceDelay:int,recordDelay:int=250) {
			_buffer=buffer;
			_soundActivityObserver=new SoundActivityObserver();
			_soundActivityObserver.setRecordThreshold(15, recordDelay); //record delay 0.25 of silence delay ie.e 250 vs 2000
			_soundActivityObserver.setMuteThreshold(5, silenceDelay);
			_soundActivityObserver.recordSatisfied.add(onRecord);
			_soundActivityObserver.muteSatisfied.add(onSilence);
			_buffer.sampleSignal.add(onSample);
			_buffer.cycledSignal.add(onCycled);
		}

		/*INTERFACE*/
		public function updateLevel(activityLevel:Number):void {
			_soundActivityObserver.updateLevel(activityLevel);
		}

		public function get leftSilence():int {
			return _calculatedLeftSilence;
		}

		public function get rightSilence():int {
			return _calculatedRightSilence;
		}
		
		/*CORE*/
		private function saveSilencePosition():void {
			_silencePosition=_buffer.cursorNonCycled;
		}

		private function saveRecordPosition():void {
			_recordPosition=_buffer.cursorNonCycled;
		}

		private function calculateClearingPositions():void {
			var silenceTime:int=_silencePosition / 44.1 / 2; //to ms
			var recordTime:int=_recordPosition / 44.1 / 2; //to ms
			recordTime-=_soundActivityObserver.recordDelay*2; //add the delays so we get the sounds before the events happened
			var bufferLength:int=_buffer.bufferRealLength;
			var playbackTime:int=silenceTime - recordTime;
			var totalTime:int=bufferLength / 44.1 / 2
			_calculatedLeftSilence=Math.max(0, totalTime - playbackTime);
			_calculatedRightSilence=_soundActivityObserver.muteDelay;
		}

		/*SIGNALS*/
		private function onRecord():void {
			trace("onRecord now");
			saveRecordPosition();
		}

		private function onSilence():void {
			trace("onSilence");
			saveSilencePosition();
			calculateClearingPositions();
			silenceSignal.dispatch();
		}

		/*DEBUG*/
		private function onCycled():void {
			if (!verbose)
				return;
			var cursor:String=SoundHelpers.bufferCursorToTime(_buffer.cursor);
			var cursorNonCy:String=SoundHelpers.bufferCursorToTime(_buffer.cursorNonCycled);
			trace("\n", "*****onCycled", cursor, cursorNonCy, "\n");
		}

		private function onSample():void {
			if (!verbose)
				return;
			var cursor:String=SoundHelpers.bufferCursorToTime(_buffer.cursor);
			var cursorNonCy:String=SoundHelpers.bufferCursorToTime(_buffer.cursorNonCycled);
			var bufferSize:String=SoundHelpers.bufferCursorToTime(_buffer.bufferLength);
			var silence:String=SoundHelpers.bufferCursorToTime(_silencePosition);
			var record:String=SoundHelpers.bufferCursorToTime(_recordPosition);
			if (verbose)
				trace("*****onSample", cursor, cursorNonCy, "---", record, silence, bufferSize);
		}
		
		public function reset():void{
			_soundActivityObserver.reset();
		}
	}
}