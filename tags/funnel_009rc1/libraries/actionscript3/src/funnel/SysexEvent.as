﻿package funnel {	import flash.events.Event;	/**	 * Sysexに関連するイベントを表すクラスです。	 */	public class SysexEvent extends Event {		public static  const SYSEX:String = "sysex";		public static  const I2C:String = "i2c";		public static  const STRING:String = "string";		public static  const VERSION:String = "version";		public function SysexEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {			super(type, bubbles, cancelable);		}	}}