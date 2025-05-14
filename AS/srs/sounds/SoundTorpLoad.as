package srs.sounds 
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class SoundTorpLoad 
	{
		
		[Embed(source = '../../Sounds/load_torpedo_short.mp3')] 
	
		private var MySound : Class; 		 
		private var sound : Sound; 	

		public function SoundTorpLoad() { }
		
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