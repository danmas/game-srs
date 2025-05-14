package srs.utils 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import srs.*;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Utils {
		
		
	/*
	 * Изменяет видимые размеры объектов экрана ИСПОЛЬЗОВАТЬ ТОЛЬКО ВМЕСТЕ С main.ScaleX = ...
	 */ 
	public static function scale(o:DisplayObject,_scale:Number):void {
		if(_scale!=Settings.SCALE_MAIN) {
			o.scaleX = 1.;
			o.scaleY = 1.;
			o.x *= Settings.SCALE_MAIN;
			o.y *= Settings.SCALE_MAIN; 
		} else {
			o.x /=  Settings.SCALE_MAIN;
			o.y /=  Settings.SCALE_MAIN; 
			o.scaleX = 1. / Settings.SCALE_MAIN;
			o.scaleY = 1. / Settings.SCALE_MAIN;
		}
	}

	 
	/*
	 * Вычисляет рассогласование направления объекта,
	 * движущегося в направлении dir_deg из позиции position
	 * на target 
	 */ 
	public static function calcDeltaBattleDeg(position:Point,dir_deg:Number,target:Point):Number	{	
				var angle_way_pt_deg:Number;
				angle_way_pt_deg = Utils.toBattleDegree(Utils.calcAngleRad(position, target)); 
				
				if (angle_way_pt_deg > 180.)
					angle_way_pt_deg = angle_way_pt_deg - 360.;
				if (dir_deg > 180.)
					dir_deg = dir_deg - 360.;
				return dir_deg - angle_way_pt_deg;
	}
	
	/*
	 * Угол между двумя точками в игровых градусах
		var p1 = new Point(0, 0);
		var p2 = new Point(2, 2);
		trace( Utils.toBattleDegree(Utils.getAngleP(p1, p2)));
		p1 = new Point(0, 10);
		p2 = new Point(2, 12);
		trace(Utils.toBattleDegree(Utils.getAngleP(p1, p2)));
		p1 = new Point(0, 0);
		p2 = new Point(2, -2);
		trace(Utils.toBattleDegree(Utils.getAngleP(p1, p2)));
 */ 
	public static function calcAngleBattleDeg (p1:Point, p2:Point):Number {
		return toBattleDegree(calcAngle(p1.x, p1.y, p2.x, p2.y));
	}
	
	/*
	 * Угол между двумя точками в радианах
	 */ 
	public static function calcAngle (x1:Number, y1:Number, x2:Number, y2:Number):Number {
		var dx:Number = x2 - x1;
		var dy:Number = y2 - y1;
		return Math.atan2(dy,dx);
	}
	
	/*
	 * Угол между двумя точками в радианах
	 */ 
	public static function calcAngleRad (p1:Point, p2:Point):Number {
		var dx:Number = p2.x - p1.x;
		var dy:Number = p2.y - p1.y;
		return Math.atan2(dy,dx);
	}
	
	/*
	 * Перевод радиан (0 по оси Х) в градусы (0 - на север) 
	 */ 
	public static function toBattleDegree(rad:Number):Number {
		var ret:Number = rad * 180. / Math.PI + 90;
		if (ret < 0)
			ret = 360. + ret;
		if (ret > 360)
			ret = ret - 360.;
		 return ret;
	}
	
	/*
	 * Перевод градусов (0 - на север) в радианы (0 по оси Х)
	 */ 
	public static function toScreenRad(deg:Number):Number {
		var ret:Number = (deg - 90.) * Math.PI / 180.;
		if (ret < 0)
			ret = 2.*Math.PI + ret;
		if (ret > 2.*Math.PI)
			ret = ret - 2.*Math.PI;
		return ret;
	}
	
		
		
	}

}