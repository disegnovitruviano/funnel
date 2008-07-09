package processing.funnel;

import java.lang.reflect.Method;
import java.util.*;

import processing.core.*;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class Osc{

	PApplet parent;
	Method onUpdate;
	
	public static final int SIN = 1;
	public static final int SQUARE = 2;
	public static final int SAW = 3;
	public static final int TRIANGLE = 4;
	public static final int IMPULSE = 5;
	
	
	public static final int UPDATE = 600;
	
	int wave;//�^�C�v
	private OscFunction wavefunc;
	
	public float value;
	public float freq;
	public float amplitude;
	public float offset;
	public float phase;
	public int times;
	
	public static int serviceInterval = 0;//serviceInterval��0�̂Ƃ���auto update���Ȃ�
	private static OscThread serviceThread = null;

	private long startTickMillis;//��̎���
	private long spendTickMillis;
	
	private boolean isMoving = false;

	
	public Osc(PApplet parent, int wave, float freq, int times){
		
		this(parent,wave,freq,1,0,0,times);
	}
	
	public Osc(PApplet parent, int wave, float freq, float amp, float offset, float phase, int times){

		this.parent = parent;
		
		this.wave = wave;
		this.freq = freq;
		this.amplitude = amp;
		this.offset = offset;
		this.phase = phase;
		this.times = times;
		
		if(freq < 0){
			PApplet.println("Frequency should be larger than 0.");
			parent.exit();
		}
		
		switch(wave){
		case SIN:
			wavefunc = new OscFunctionSIN();
			break;
		case SQUARE:
			wavefunc = new OscFunctionSQUARE();
			break;
		case SAW:
			wavefunc = new OscFunctionSAW();
			break;
		case TRIANGLE:
			wavefunc = new OscFunctionTRIANGLE();
			break;
		case IMPULSE:
			wavefunc = new OscFunctionIMPULSE();
			break;
		default:
			PApplet.println("Error !! Osc function type");
			parent.exit();
			break;
		}
		

		//1�������ʂ�serviceThread
		if(serviceThread == null || !serviceThread.isAlive()){
			serviceThread = new OscThread(wave);
			serviceThread.startThread();
		}
		
		parent.registerDispose(this);

	}
	
	public void dispose(){

		serviceThread.stopThread();
		
		System.out.println("dispose osc");
	}
	
	public void start(){
		if(!isMoving){
			startTickMillis = System.currentTimeMillis();
			serviceThread.addOsc(this);
			isMoving = true;
		}
	}
	
	public void stop(){
		if(isMoving){	
			isMoving=false;
			serviceThread.removeOsc(this);
		}
	}
	
	public void reset(){
		startTickMillis = System.currentTimeMillis();
		spendTickMillis = 0;
	}
	
	public void addEventListener(int event,String methodName){
			
		if(event == Osc.UPDATE){
			
			try {
				onUpdate = 
					parent.getClass().getMethod(methodName,new Class[] { Osc.class });
			} catch (Exception e) {
				System.out.println(methodName + "����`����Ă��܂���");
	      // no such method, or an error.. which is fine, just ignore
			}		
		}else{
			System.out.println("���̃C�x���g�͒ǉ��ł��܂���");
		}
	}
	
	public void update(){

		long now = System.currentTimeMillis();
		float sec = (float)(now-startTickMillis)/1000;
		
		if(times != 0 && freq*sec >=times){
			stop();
			sec = times/freq;
		}
		
		value = amplitude * wavefunc.calculate(freq * (sec + phase)) + offset;
		
		if(onUpdate != null ){
			
			try{

				onUpdate.invoke(parent,new Object[]{ this });
				
			}catch(Exception e){
				e.printStackTrace();
				onUpdate = null;
//				errorMessage("onRisingEdge handler error !!");
			}
		}

	}
	
	public void update(long millis){
		
		spendTickMillis += millis;
		float sec = (float)(spendTickMillis)/1000;
		
		value = amplitude * wavefunc.calculate(freq * (sec + phase)) + offset;
	}
	
	class OscThread extends Thread{
		boolean isWorking = false;
		long serviceTickMillis;
//		List oscList;
		Vector oscList;

		public OscThread(int id){
			super("OscServiceThread");
//			oscList = Collections.synchronizedList(new LinkedList());
			oscList = new Vector();
		}
		
		public void startThread(){
			isWorking = true;
			super.start();
		}
		
		public void stopThread(){
			isWorking = false;
			
			if(serviceThread!=null){
				try {
					serviceThread.join();
				} catch (InterruptedException e) {
					// TODO �����������ꂽ catch �u���b�N
					e.printStackTrace();
				}
			}
		}
		
		public synchronized void addOsc(Osc osc){

			oscList.add(osc);
		}
		
		public synchronized void removeOsc(Osc osc){
			
			oscList.remove(osc);
		}
		
		public void run(){
			long updateTickMillis = 0;
			System.out.println("OscServiceThread start");
			
			while(isWorking){
				long processMillis = System.currentTimeMillis() - updateTickMillis;//�J��Ԃ��܂ł̏����ɂ�����������

				if((processMillis > Osc.serviceInterval) && Osc.serviceInterval != 0){
					
					synchronized (oscList){

//						ListIterator it;
//						int i=0;
//						do{
//							it = oscList.listIterator(i++);
//							if(it.hasNext()){
//								Osc osc = (Osc)oscList.iterator().next();
//								osc.update();
//							}
//						}while(it.hasNext());
						
						for(int i=0;i<oscList.size();i++){
							Osc osc = (Osc)oscList.get(i);
							osc.update();		
						}

					}

					updateTickMillis = System.currentTimeMillis();
				}
				
				try{
						Thread.sleep(1);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			
			System.out.println("OscServiceThread out");
		}
		

	}
	
	interface OscFunction {
		
		public float calculate(float val);
	}
	
	class OscFunctionSIN implements OscFunction{
		
		public float calculate(float val){
			return 0.5f * (float)(1 + Math.sin(2*Math.PI * val));
		}
	}
	
	class OscFunctionSQUARE implements OscFunction{
		
		public float calculate(float val){
			return (val%1 <= 0.5) ? 1.0f: 0;
		}
	}
	
	class OscFunctionTRIANGLE implements OscFunction{
		
		public float calculate(float val){
			val %= 1;
			if(val <= 0.25){
				return 2*val+0.5f;
			}else if(val <= 0.75){
				return -2*val+1.5f;
			}else{
				return 2*val-1.5f;
			}
			
		}
	}
	
	class OscFunctionSAW implements OscFunction{
		
		public float calculate(float val){
			val %=1;
			if(val <0.5){
				return val+0.5f;
			}else{
				return val-0.5f;
			}
		}
	}
	
	class OscFunctionIMPULSE implements OscFunction{
		
		public float calculate(float val){
			if(val <= 1.0){
				return 1.0f;
			}else{
				return 0;
			}
		}
	}
	
}