package org.citilo.sound.format
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.Sample;
	
	import flash.utils.ByteArray;

	public class SoundBytesToSample
	{
		public static function createSample(bytes:ByteArray,rate:Number=44100):Sample{
			var s:Sample=new Sample(new AudioDescriptor(rate),bytes.length/8);
			s.readBytes(bytes);
			return s;
		}
	}
}