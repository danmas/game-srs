package srs.sounds 
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class SoundExplosion 
	{
		[Embed(source = '../../Sounds/Explosion.mp3')] 
	
		private var MySound : Class; 		 
		private var sound : Sound; 	

		public function SoundExplosion() {}
		
		/*
		 * Звук варьируется от 0 до 1
		 */ 
		public function play(volume:Number):void {
			sound = (new MySound) as Sound;
			var trans:SoundTransform = new SoundTransform(volume, 0); 
			var channel:SoundChannel = sound.play(0, 1, trans);			
		}
		
		
			
	}
		
}
