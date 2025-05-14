package srs.sounds 
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class SoundTATC {
	
		[Embed(source = '../../Sounds/TATC_short.mp3')] 
	
		private var MySound : Class; 		 
		private var sound : Sound; 	

		public function SoundTATC() { }
		
		/*
		 * Звук варьируется от 0 до 1
		 * n раз повторяется
		 */ 
		public function play(volume:Number, n:int=1):SoundChannel {
			sound = (new MySound) as Sound;
			var trans:SoundTransform = new SoundTransform(volume, 0); 
			//var channel:SoundChannel = 
			return sound.play(0, n, trans);			
		}
		
		
	}

}