/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        HistogramRN
 * Description: Histogram R^N. (Case Continuos)
 * Author:      Diego Garcia
 * Date:        14th Octuber 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-10-14   Diego Garcia    Creation.
 * 2015-11-24   DGarcia         Modificación
 *                              Metodo <Init>
 *                              se genneran las categarias con rangos establecidos
 *                              en vez de hacerlo basado en los datos.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class HistogramRN {
    // Properties    
    int classes; // number of classes
    public float width [] = new float[3]; // wide of interval
    public int n=0; // size of samples
    public ClassInterval[][][] c ;     
    float min[] = new float[3];
    float max[] = new float[3];
    //List<HistogramRN> var;
    public HistogramRN(int classes){
        this.classes = classes;
        this.c = new ClassInterval[classes][classes][classes];
    }
    public void Init(List<String> s[]){
//        n = n + s.length;        
        min[0] = min[1] = min[2] = Float.MAX_VALUE;        
        max[0] = max[1] = max[2] = Float.MIN_VALUE;
        
        for (int t=0; t<s.length; t++){
            ListNode<String> l = s[t].queryNodeFromFront();
            int z = 0;
            while (l != null){
                float f = new Float(l.data).floatValue();
                if ( f < min[z]) min[z] = f;
                if ( f > max[z]) max[z] = f;
                l = l.nextNode;
                z++;
            }
        }
        
        width[0] = Math.abs(max[0] - min[0]) / classes;
        width[1] = Math.abs(max[1] - min[1]) / classes;
        width[2] = Math.abs(max[2] - min[2]) / classes;
            
//        System.out.println(
//                "min[0]:"+min[0] + "max[0]" + max[0] +
//                "min[1]:"+min[1] + "max[1]" + max[1] +
//                "min[2]:"+min[2] + "max[2]" + max[2]
//        );
        
        for (int i=0; i<c.length; i++)
            for (int j=0; j<c[i].length; j++)            
                for (int k=0; k<c[i][j].length; k++){
                    c[i][j][k] = new ClassInterval(3);  
                    c[i][j][k].startPoint[0] = (i==0)? min[0] : c[i-1][j][k].endPoint[0]; 
                    c[i][j][k].startPoint[1] = (j==0)? min[1] : c[i][j-1][k].endPoint[1]; 
                    c[i][j][k].startPoint[2] = (k==0)? min[2] : c[i][j][k-1].endPoint[2];                     
                    c[i][j][k].endPoint[0] = (i==c.length)? max[0] : c[i][j][k].startPoint[0] + width[0];
                    c[i][j][k].endPoint[1] = (j==c[i].length)? max[1] : c[i][j][k].startPoint[1] + width[1];    
                    c[i][j][k].endPoint[2] = (k==c[i][j].length)? max[2] : c[i][j][k].startPoint[2] + width[2];                     
                }
        
    }

    public void Init(float[][] range){

        for (int idx=0; idx< range.length; idx++){
            min[idx] = range[idx][0];
            max[idx] = range[idx][1];                    
        }
        
        width[0] = Math.abs(max[0] - min[0]) / classes;
        width[1] = Math.abs(max[1] - min[1]) / classes;
        width[2] = Math.abs(max[2] - min[2]) / classes;
            
//        System.out.println(
//                "min[0]:"+min[0] + "max[0]" + max[0] +
//                "min[1]:"+min[1] + "max[1]" + max[1] +
//                "min[2]:"+min[2] + "max[2]" + max[2]
//        );
        
        for (int i=0; i<c.length; i++)
            for (int j=0; j<c[i].length; j++)            
                for (int k=0; k<c[i][j].length; k++){
                    c[i][j][k] = new ClassInterval(3);  
                    c[i][j][k].startPoint[0] = (i==0)? min[0] : c[i-1][j][k].endPoint[0]; 
                    c[i][j][k].startPoint[1] = (j==0)? min[1] : c[i][j-1][k].endPoint[1]; 
                    c[i][j][k].startPoint[2] = (k==0)? min[2] : c[i][j][k-1].endPoint[2];                     
                    c[i][j][k].endPoint[0] = (i==c.length)? max[0] : c[i][j][k].startPoint[0] + width[0];
                    c[i][j][k].endPoint[1] = (j==c[i].length)? max[1] : c[i][j][k].startPoint[1] + width[1];    
                    c[i][j][k].endPoint[2] = (k==c[i][j].length)? max[2] : c[i][j][k].startPoint[2] + width[2];                     
                }
        
    }    
    
    
    public boolean sampleInInterval(List<String> l, int i, int j, int k){
        float err = 0.00001f;
        // l's rows are visited
        ListNode<String> lnode = l.queryNodeFromFront(); 
        int z = 0;
        while (lnode!=null ){
            
            float s = new Float(lnode.data).floatValue();
            if (  s < c[i][j][k].startPoint[z] - err ||
                  s > c[i][j][k].endPoint[z] + err  )
                return false;
            
            lnode = lnode.nextNode;                
            z++;
            if (lnode == null) return true;                      
        }                    
        return false;
    }        
    public void updateFrecuency(List<String> s){
        for (int i=0; i<c.length; i++)
            for (int j=0; j<c[i].length; j++)
                for (int k=0; k<c[i][j].length; k++)
                {
//                    System.out.println("i:"+i+" j:"+j+" k:"+k);
//                    System.out.println("c[i][j][k].startPoint[0]:" + c[i][j][k].startPoint[0]+
//                    " c[i][j][k].startPoint[1]:" + c[i][j][k].startPoint[1]+
//                    " c[i][j][k].startPoint[2]:" + c[i][j][k].startPoint[2]);
//                    System.out.println("c[i][j][k].endPoint[0]:" + c[i][j][k].endPoint[0]+
//                    " c[i][j][k].endPoint[1]:" + c[i][j][k].endPoint[1]+
//                    " c[i][j][k].endPoint[2]:" + c[i][j][k].endPoint[2]);                     
//                    s.print();
                    boolean belong = sampleInInterval(s, i, j, k);
//                    System.out.println((belong)?"belong":"no belong");
                    if (belong)
                        c[i][j][k].frequency++;
                }
    }    
    public void loadSamples(List<String> s[]){
        n = n + s.length;
        for (int t=0; t<s.length; t++)
            updateFrecuency(s[t]);
    }    
    
    public float getRelativeFrecuency(jMEF.PVector point ){
        for (int i=0; i<c.length; i++)
            for (int j=0; j<c[i].length; j++)
                for (int k=0; k<c[i][j].length; k++)
                    if ( (point.array[0] >= c[i][j][k].startPoint[0] && 
                          point.array[0] <= c[i][j][k].endPoint[0]) &&
                         (point.array[1] >= c[i][j][k].startPoint[1] && 
                          point.array[1] <= c[i][j][k].endPoint[1]) &&  
                         (point.array[2] >= c[i][j][k].startPoint[2] && 
                          point.array[2] <= c[i][j][k].endPoint[2])   )
                        return ((float)c[i][j][k].frequency / (float)n);
        return 0f;
    }
    
    public float getDensity(jMEF.PVector point){
        return getRelativeFrecuency(point)/(width[0]*width[1]*width[2]);
    }    
    
}
