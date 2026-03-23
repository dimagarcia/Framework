/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        BayesianModel
 * Description: The Bayesian network model
 * Author:      Diego Garcia
 * Date:        06th March 2016
 *
 * Modification Log:
 * ---------------------------
 * 2016-03-06   Diego Garcia    Creation.
 */
package Likelihood;
import java.math.BigInteger;
import java.math.BigDecimal;
/**
 *
 * @author dgarcia
 */
public class BayesianModel {
    public float p[][][];
    public int n[][][];
    public int v[];
    public int r[];
    public int q[];
    
    public BayesianModel(float[][][] p, int[][][] n, int[] v, int[] r, int[] q)
    {
        this.p = p;
        this.n = n;
        this.v = v;
        this.r = r;
        this.q = q;
    }
    
    private int sum(int[][][] n, int i, int ri, int k){
        int sum = 0;
        for (int j=0; j<ri; j++)
            sum = sum + n[i][j][k];
        return sum;
    }
    
    private double fact(double n){
        if (n == 0 || n==1)
            return 1;
        else
            return n * fact(n-1);
    }
    
    private BigInteger factorial(int n) {
        BigInteger f = new BigInteger("1");
        for (int i = 1; i <= n; i++) {
            f = f.multiply(new BigInteger(i + ""));
        }
        return f;
    } 
    
    private double coefMN(int[][][] n, int i, int ri, int k){
        // num
        int sum = sum(n,i,r[i],k);
        //System.out.print("\t" + sum);
        BigInteger fsum = factorial(sum);
        //System.out.print("\t" + fsum);
        // den
        BigInteger prodf = new BigInteger("1");
        for (int j=0; j<ri; j++)
            prodf = prodf.multiply(factorial(n[i][j][k]));
        // cociente
        BigDecimal coefMN = new BigDecimal (fsum.toString());
        coefMN = coefMN.divide(new BigDecimal(prodf.toString()));
        return new Double(coefMN.toString()).doubleValue();
        
    }
    
    private double prodPho(float[][][] p, int[][][] n, int i, int ri, int k){
        double prodPho = 1f;
        for (int j=0; j<ri; j++){
            System.out.printf("\n\tpow(%.6f,%d)",p[i][j][k],n[i][j][k]);
            prodPho = prodPho * Math.pow((double)p[i][j][k], (double)n[i][j][k]);
        }
        return prodPho;
    }
    
    private BigDecimal pho(float[][][] p, int[][][] n, int i, int ri, int k){
        BigDecimal prodPho = new BigDecimal("1");
        for (int j=0; j<ri; j++){
            System.out.printf("\n\tpow(%.6f,%d)",p[i][j][k],n[i][j][k]);
            BigDecimal pho = new BigDecimal(p[i][j][k]);
            prodPho = prodPho.multiply(pho.pow(n[i][j][k]));
        }
        return prodPho;
    }
    
    public BigDecimal likelihood(){
        BigDecimal likelihood = new BigDecimal("1");
        for (int i=0; i<v.length; i++){
            System.out.print("i=" + (i+1));
            for (int k=0; k<q[i]; k++){ 
                System.out.print("\tk=" + (k+1));
                //Coef multinomial
//                double cMN = coefMN(n,i,r[i],k);
//                System.out.printf("\t%.12f", cMN);
                //Pho Product
//                double pho = prodPho(p,n,i,r[i],k);
                BigDecimal pho = pho(p, n, i, r[i], k);        
                likelihood = likelihood.multiply(pho);//ikelihood * cMN * pho;
                
                System.out.println();
            }
        }
        
        return likelihood;
    }
    
        public BigDecimal loglikelihood(){
        BigDecimal likelihood = new BigDecimal("1");
        for (int i=0; i<v.length; i++){
            System.out.print("i=" + (i+1));
            for (int k=0; k<q[i]; k++){ 
                System.out.print("\tk=" + (k+1));
                //Coef multinomial
//                double cMN = coefMN(n,i,r[i],k);
//                System.out.printf("\t%.12f", cMN);
                //Pho Product
//                double pho = prodPho(p,n,i,r[i],k);
                BigDecimal pho = pho(p, n, i, r[i], k);        
                likelihood = likelihood.multiply(pho);//ikelihood * cMN * pho;
                
                System.out.println();
            }
        }
        
        return likelihood;
    }
    
}
