package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import funnel.osc.*;
	
	/**
	 * @copy FunnelEvent#READY
	 */
	[Event(name="ready",type="FunnelEvent")]
	
	/**
	 * @copy FunnelErrorEvent#ERROR
	 */
	[Event(name="error",type="FunnelErrorEvent")]
	
	/**
	 * @copy FunnelErrorEvent#CONFIGURATION_ERROR
	 */
	[Event(name="configurationError",type="FunnelErrorEvent")]
	
	/**
	 * @copy FunnelErrorEvent#REBOOT_ERROR
	 */
	[Event(name="rebootError",type="FunnelErrorEvent")]
	
	/**
	 * 複数のI/Oモジュールから構成されるシステムを表現するためのクラスです。 
	 */
	public class IOSystem extends EventDispatcher
	{	
		/**
		* 出力ポートを手動で更新する場合はfalseにします。
		* @default true
		*/		
		public var autoUpdate:Boolean;
		private var _modules:Object;
		private var _commandPort:CommandPort;
		private var _samplingInterval:int;
		private var _task:Task;

		/**
		 * @param configs Configuration配列
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */		
		public function IOSystem(configs:Array, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			autoUpdate = true;
			_modules = {};
			_commandPort = new CommandPort();
			_commandPort.addEventListener(Event.CHANGE, onReceiveInput);
			
			_task = new Task().complete();
			_task.addCallback(_commandPort.connect, host, portNum);
			sendReset();
			for each (var config:Configuration in configs) {
				var id:uint = config.moduleID;
				_modules[id] = new IOModule(this, config);
				sendConfiguration(id, config.config);
			}
			this.samplingInterval = samplingInterval;
			sendPolling(true);
			_task.addCallback(dispatchEvent, new FunnelEvent(FunnelEvent.READY));
			_task.addErrback(dispatchEvent);
		}
		
		/**
		 * moduleNumで指定した番号のI/Oモジュールを取得します。
		 * @param moduleNum I/Oモジュールの番号。このIDは、Configuration#moduleIDと同じものを指定します。
		 * @return moduleNumで指定したIOModuleオブジェクト
		 * @see IOModule
		 * @see Configuration#moduleID
		 */		
		public function ioModule(moduleNum:uint):IOModule {
			return _modules[moduleNum];
		}
		
		/**
		 * サンプリング間隔
		 * @default 33
		 */		
		public function get samplingInterval():int {
			return _samplingInterval;
		}
			
		public function set samplingInterval(val:int):void {
			_samplingInterval = val;
			sendSamplingInterval(val);
		}
		
		/**
		 * 全ての出力ポートの値を更新します。通常、autoUpdateをfalseに設定して利用します。
		 * @see IOSystem#autoUpdate
		 */		
		public function update():void {
			for each (var module:IOModule in _modules) {
				module.update();
			}
		}
		
		private function onReceiveInput(event:Event):void {
			var message:OSCMessage = _commandPort.inputMessage;
			var portValues:Array = message.value;
			var module:IOModule = _modules[portValues[0].value];
			var startPortNum:uint = portValues[1].value;
			for (var j:uint = 0; j < portValues.length - 2; ++j) {
				var aPort:Port = module.port(startPortNum + j);
				var type:uint = aPort.type;
				if (type == Port.AIN || type == Port.DIN) {
					aPort.value = portValues[j + 2].value;
				}
			}
		}

		private function sendReset():void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/reset"));
		}
		
		private function sendConfiguration(moduleNum:uint, config:Array):void {
			var msg:OSCMessage = new OSCMessage("/configure", new OSCInt(moduleNum));
			for each (var portType:uint in config) {
				msg.addValue(new OSCInt(portType));
			}
			_task.addCallback(_commandPort.writeCommand, msg);
		}
		
		private function sendSamplingInterval(interval:int):void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/samplingInterval", new OSCInt(interval)));
		}
		
		private function sendPolling(enabled:Boolean):void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/polling", new OSCInt(enabled ? 1 : 0)));
		}
		
		/**
		 * @private
		 */		
		internal function sendOut(moduleNum:uint, portNum:uint, portValues:Array):void {
			var message:OSCMessage = new OSCMessage("/out", new OSCInt(moduleNum), new OSCInt(portNum));
			for (var i:uint = 0; i < portValues.length; ++i) {
				message.addValue(new OSCFloat(portValues[i]));
			}
			_task.addCallback(_commandPort.writeCommand, message);
		}
	}
}