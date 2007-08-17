// Funnel alias
static private const enable:Boolean = true;
static private const disable:Boolean = false;

static private const GAINER_MODE1:Array = Configuration.GAINER_MODE1;
static private const GAINER_MODE2:Array = Configuration.GAINER_MODE2;
static private const GAINER_MODE3:Array = Configuration.GAINER_MODE3;
static private const GAINER_MODE4:Array = Configuration.GAINER_MODE4;
static private const GAINER_MODE5:Array = Configuration.GAINER_MODE5;
static private const GAINER_MODE6:Array = Configuration.GAINER_MODE6;
static private const GAINER_MODE7:Array = Configuration.GAINER_MODE7;
static private const GAINER_MODE8:Array = Configuration.GAINER_MODE8;

static private const INPUT:uint = PortDirection.INPUT;
static private const OUTPUT:uint = PortDirection.OUTPUT;
static private const DIGITAL:uint = PortType.DIGITAL;
static private const ANALOG:uint = PortType.ANALOG;

static private const AIN:uint = Port.AIN;
static private const AOUT:uint = Port.AOUT;
static private const DIN:uint = Port.DIN;
static private const DOUT:uint = Port.DOUT;

static private const READY:String = FunnelEvent.READY;
static private const FATAL_ERROR:String = FunnelEvent.FATAL_ERROR;
static private const RISING_EDGE:String = PortEvent.RISING_EDGE;
static private const FALLING_EDGE:String = PortEvent.FALLING_EDGE;
static private const UPDATE:String = PortEvent.UPDATE;
/*
static private const LPH:Array = funnel.filter.Convolution.LPF;
static private const HPF:Array = funnel.filter.Convolution.HPF;
static private const MOVING_AVERAGE:Array = funnel.filter.Convolution.MOVING_AVERAGE;

static private const LINEAR:Function = funnel.filter.Scaler.LINEAR;
static private const LOG:Function = funnel.filter.Scaler.LOG;
static private const EXP:Function = funnel.filter.Scaler.EXP;
static private const SQUARE:Function = funnel.filter.Scaler.SQUARE;
static private const SQUARE_ROOT:Function = funnel.filter.Scaler.SQUARE_ROOT;
static private const CUBE:Function = funnel.filter.Scaler.CUBE;
static private const CUBE_ROOT:Function = funnel.filter.Scaler.CUBE_ROOT;

static private const SIN:Function = funnel.Osc.SIN;
static private const SAW:Function = funnel.Osc.SAW;
static private const IMPULSE:Function = funnel.Osc.IMPULSE;
static private const SQUARE:Function = funnel.Osc.SQUARE;
static private const TRIANGLE:Function = funnel.Osc.TRIANGLE;
*/