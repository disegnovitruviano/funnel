package funnel
{
	public class DigitalInput extends InputPort
	{
		override public function get type():uint {
			return PortType.DIGITAL;
		}
	}
}