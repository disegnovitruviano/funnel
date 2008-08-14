/**
 * ain 0に接続したCdSの値が一定値よりも低くなる（暗くなる）と
 * LEDが点滅する
 */

import processing.funnel.*;

Gainer gainer;
Osc osc;

void setup()
{
  size(200, 200);
  frameRate(30);
  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.6, 0.05)
  };
  gainer.analogInput(0).filters = filters;

  osc = new Osc(this, Osc.SQUARE, 1.0, 0);
  osc.serviceInterval = 30;
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw()
{
  background(100);
}

void oscUpdated(Osc osc)
{
  gainer.led().value = osc.value;
}

void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    println("BRIGHT");
    osc.stop();
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    println("DARK");
    osc.reset();
    osc.start();
  }
}
