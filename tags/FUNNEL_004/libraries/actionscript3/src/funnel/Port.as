package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @copy PortEvent#CHANGE
	 */
	[Event(name="change",type="PortEvent")]
	
	/**
	 * @copy PortEvent#RISING_EDGE
	 */
	[Event(name="risingEdge",type="PortEvent")]
	
	/**
	 * @copy PortEvent#FALLING_EDGE
	 */
	[Event(name="fallingEdge",type="PortEvent")]
	
	/**
	 * I/Oモジュールの入出力ポートを表すクラスです。
	 */	
	public class Port extends EventDispatcher
	{
		/**
		* アナログ入力
		*/		
		public static const AIN:uint = 0;
		
		/**
		* デジタル入力
		*/		
		public static const DIN:uint = 1;
		
		/**
		* アナログ出力
		*/		
		public static const AOUT:uint = 2;
		
		/**
		* デジタル出力
		*/		
		public static const DOUT:uint = 3;
		
		private var _value:Number;
		private var _lastValue:Number;
		private var _number:uint;
		private var _type:uint;	
		private var _filters:Array;
		private var _generator:IGenerator;
		private var _sum:Number;
		private var _average:Number;
		private var _minimum:Number;
		private var _maximum:Number;
		private var _numSamples:Number;
		private static const MAX_SAMPLES:Number = Number.MAX_VALUE;
		
		/**
		 * 
		 * @param number ポート番号
		 * @param type ポートのタイプ(AIN、DIN、AOUT、DOUT)
		 * 
		 */		
		public function Port(number:uint, type:uint) {
			_number = number;
			_type = type;
			_value = 0;
			_lastValue = 0;
			_minimum = 1;
			_maximum = 0;
			_average = 0;
			_sum = 0;
			_numSamples = 0;
		}
		
		/**
		 * ポート番号
		 * 
		 */		
		public function get number():uint {
			return _number;
		}
		
		/**
		 * ポートのタイプ(AIN、DIN、AOUT、DOUT)
		 * 
		 */		
		public function get type():uint {
			return _type;
		}
		
		/**
		 * センサからの入力値、またはアクチュエータへの出力値
		 * 
		 */		
		public function get value():Number {
			return _value;
		}
		
		public function set value(val:Number):void {
			calculateMinimumMaximumAndMean(val);
			_lastValue = _value;
			_value = applyFilters(val);
			detectEdge(_lastValue, _value);
		}
		
		/**
		 * ポートの変化する前の値
		 * 
		 */		
		public function get lastValue():Number {
			return _lastValue;
		}
		
		/**
		 * 
		 * 平均値
		 * 
		 */		
		public function get average():Number {
			return _average;
		}
		
		/**
		 * 
		 * 最小値
		 * 
		 */		
		public function get minimum():Number {
			return _minimum;
		}
		
		/**
		 * 
		 * 最大値
		 * 
		 */		
		public function get maximum():Number {
			return _maximum;
		}
		
		/**
		 * ポートに適応するフィルタ配列
		 * 
		 */		
		public function get filters():Array {
			return _filters;
		}
		
		public function set filters(array:Array):void {
			if (_generator != null) {
				_generator.removeEventListener(GeneratorEvent.UPDATE, autoSetValue);
			}
			
			if (array == null || array.length == 0) {
				filters = array;
				return;
			}
			
			var lastIndexOfGenerator:uint = 0;
			for (var i:int = array.length - 1; i >= 0; --i) {
				if (array[i] is IFilter) {
					;
				} else if (array[i] is IGenerator) {
					lastIndexOfGenerator = i;
					_generator = array[i] as IGenerator;
					_generator.addEventListener(GeneratorEvent.UPDATE, autoSetValue);
					break;
				} else {
					return;
				}
			}
			_filters = array.slice(lastIndexOfGenerator);
		}
		
		private function autoSetValue(event:Event):void {
			value = _generator.value;
		}
		
		/**
		 * ヒストリをリセットします。
		 * 
		 */		
		public function clear():void {
			_minimum = _maximum = _average = _lastValue = _value;
			clearWeight();
		}
		
		private function clearWeight():void {
			_sum = _average;
			_numSamples = 1;
		}
		
		private function calculateMinimumMaximumAndMean(val:Number):void {
			_minimum = Math.min(val, _minimum);
			_maximum = Math.max(val, _maximum);
			
			_sum += val;
			_average = _sum / (++_numSamples);
			if (_numSamples >= MAX_SAMPLES) {
				clearWeight();
			}
		}
		
		private function detectEdge(oldValue:Number, newValue:Number):void {
			if (oldValue == newValue) return;

			dispatchEvent(new PortEvent(PortEvent.CHANGE));
			
			if (oldValue == 0 && newValue != 0) {
				dispatchEvent(new PortEvent(PortEvent.RISING_EDGE));
			} else if (oldValue != 0 && newValue == 0) {
				dispatchEvent(new PortEvent(PortEvent.FALLING_EDGE));
			}

		}
		
		private function applyFilters(val:Number):Number {
			if (_filters == null) return val;
			
			var result:Number = val;
			for (var i:uint = 0; i < _filters.length; ++i) {
				if (_filters[i] is IFilter) {
					result = _filters[i].processSample(result);
				}
			}
			return result;
		}
		
	}
}