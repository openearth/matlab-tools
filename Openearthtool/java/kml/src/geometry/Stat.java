package geometry;

/**
 * a lightweight class that calculates the mean and standard deviation of a population.
 * Useful for hugh populations for which it is impossible to remember all members.
 * @author kleuskensmhp
 *
 */
public class Stat {
	private double weight;
	private double ex2;
	private double sum;

	public Stat(){
		reset();
	}

	public Stat(double weight,double mean, double std){
		double var=std*std;
		sum=mean*weight;
		this.weight=weight;
		ex2=(var+Math.pow(mean,2))*weight;
	}

	public void reset(){
		weight=0;
		ex2=0;
		sum=0;
	}

	public boolean add(double value){
		return add(value,1);
	}

	public boolean add(double[] values){
		boolean isSuccesful=true;
		for(double value:values){
			if(!add(value,1)) isSuccesful=false;
		}
		return isSuccesful;
	}

	public void add(Stat stat){
		weight+=stat.weight;
		ex2+=stat.ex2;
		sum+=stat.sum;
	}

	public boolean add(double value,double weight){
		if(Double.isNaN(value)||Double.isInfinite(value)){
			return false;
		}else{
			this.weight+=weight;
			sum+=value*weight;
			ex2+=value*value*weight;
			return true;
		}
	}

	public double getSum(){
		return sum;
	}

	public double getMean(){
		if(weight>0){
			return sum/weight;
		}
		else return 0;
	}
	
	public double getMean(int r){
		if(weight>0){
			return Round(sum/weight,r);
		}
		else return 0;
	}

	public double getWeight(){
		return weight;
	}

	public double getWeight(int r){
		return Round(weight,r);
	}

	public double getVar(){
		if(weight>0){
			return ex2/weight-Math.pow(getMean(),2);
		}else return 0;
	}

	public double getStd(){
		return Math.sqrt(getVar());
	}
	public double getStd(int r){
		return Round(Math.sqrt(getVar()),r);
	}

	/**
	 * calculates the chance of this value assuming a gaussian distribution
	 * @param value
	 */
	public double getChance(double value){
		double var=getVar();
		double mean=getMean();
		double a=1./Math.sqrt(2*var*Math.PI);
		if(var>0){
			return a*Math.exp(-(value-mean)*(value-mean)/2/var);
		}else return 0;
	}

	public static double Round(double Rval, int Rpl) {
		double p = (double)Math.pow(10,Rpl);
		Rval = Rval * p;
		double tmp = Math.round(Rval);
		return tmp/p;
	}
}
