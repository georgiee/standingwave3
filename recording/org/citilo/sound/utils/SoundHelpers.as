package org.citilo.sound.utils
{
	public class SoundHelpers{
		public static var SAMPLING_RATE:int=44100;
		public static function bufferCursorToTime(cursor:int):String{
			return (cursor/SAMPLING_RATE/2).toFixed(2);
		}
	}
}