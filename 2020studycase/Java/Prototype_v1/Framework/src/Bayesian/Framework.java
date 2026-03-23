package Bayesian;

import com.sun.opengl.util.Animator;
import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.media.opengl.GL;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLCanvas;
import javax.media.opengl.GLEventListener;
import javax.media.opengl.glu.GLU;
// Librerias JDBC
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.ResultSetMetaData;



/**
 * Framework.java <BR>
 * author: Brian Paul (converted to Java by Ron Cemer and Sven Goethel) <P>
 *
 * This version is equal to Brian Paul's version 1.2 1999/10/21
 */
public class Framework implements GLEventListener {
//public class Framework {
    // Diego Garcia - Viernes, 08 de Mayo de 2015
    // Box and Miller (1958)
    static int N = 5000;
    static double[] u1 = new double[N];
    static double[] u2 = new double[N];
    static double[] x1 = new double[N];
    static double[] x2 = new double[N];
    static int k = 40;
    static Cate[] c = new Cate[k];
    static int offset = -4;
    static float interv = 0.2f;
    static float factor = 1.0f/interv;
    static int n = 1000;
    // implementaci??n Algoritmo Metropolis Hasting - Mayo 20 de 2015 - Diego Garc??a
    static int t = 5000;
    static double[] p = new double[t];
    static double[] x = new double[t];
    static jMEF.PVector[] xR2;
    // Mezcla de gausianas
    static Hasting mh;
    static jMEF.PVector[] points;
    static HistogramR2 h;
    static HistogramR2 r;
    static jMEF.MixtureModel f;    
    static HastingBN mhBN;
    
    public static void init(){
        for (int i=0; i<c.length; i++){
            c[i] = new Cate();
            if (i==0)
                c[i].inicio = offset;
            else
                c[i].inicio = c[i-1].fin;
            c[i].fin = c[i].inicio + interv;
            c[i].frecuencia = 0;
        }
    }
    public static void load(){
        // Conexion a oracle	
        try{
            DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            Connection conn = DriverManager.getConnection
                ("jdbc:oracle:thin:@192.168.56.101:1521:XE", "bio", "bayesian");
            Statement stmt = conn.createStatement();
            ResultSet rset = 
              stmt.executeQuery("select value from dnorm");            
            while (rset.next())
                for (int i=0; i<c.length; i++)
                    if (rset.getFloat(1)>=c[i].inicio && rset.getFloat(1) < c[i].fin )
                        c[i].frecuencia++;
            stmt.close();        
        }
	catch (SQLException e){e.printStackTrace();}
        
        
        
    }

    public static void init2(){
        for (int i=0; i<c.length; i++){
            c[i] = new Cate();
            if (i==0)
                c[i].inicio = offset;
            else
                c[i].inicio = c[i-1].fin;
            c[i].fin = c[i].inicio + interv;
            c[i].frecuencia = 0;
        }
    }
    public static void load2(){
        for(int j=0; j<x.length; j++)
            for (int i=0; i<c.length; i++)
                if (x[j]>=c[i].inicio && x[j] < c[i].fin )
                    c[i].frecuencia++;
    }
    public static void load3(){
        for(int j=0; j<x.length; j++)
            for (int i=0; i<c.length; i++)
                if (x1[j]>=c[i].inicio && x1[j] < c[i].fin )
                    c[i].frecuencia++;
    }
    
    public static double distrNormald(double x, double mu, double tau){
	return Math.sqrt(tau / (2 * Math.PI)) * Math.exp(-tau * (float)Math.pow(x - mu,2)/2);
    }
    public static double distrMixtured(double x, double mu1, double tau1,
                                       double mu2, double tau2, double p){
        double y1 = Math.sqrt(tau1 / (2 * Math.PI)) * Math.exp(-tau1 * (float)Math.pow(x - mu1,2)/2);
        double y2 = Math.sqrt(tau2 / (2 * Math.PI)) * Math.exp(-tau2 * (float)Math.pow(x - mu2,2)/2);
	return y1*(1-p) + y2*p;
    }
    public static long factl(int n){    
        if (n<=1) return (long)1;
        return (long)n*factl(n-1);
    }
    
    public static double combd(int n, int k){
        return (double) factl(n) / ( (double)factl(k) * (double)factl(n-k) );
    }
    
    public static double distrBind(int x, int n, double p){
        
        return  combd(n, x) * Math.pow(p, x) * Math.pow(1-p, n-x);
    }
    
    public static double dnorm(double mu, double sigma2){
        double u1 = Math.random();
        double u2 = Math.random();
        double z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos( 2.0 * Math.PI * u2); //Math.sqrt(-2.0 * Math.log(u1)) * Math.sin( 2.0 * Math.PI * u2);
        return z * Math.sqrt(sigma2) + mu; 
    }
    
    public static double dcat(double x){
        for (int i=0; i<c.length; i++)
            if (x>= c[i].inicio && x<=c[i].fin){
                //System.out.println("frec:"+c[i].frecuencia+" n:"+n+" p:"+((double)c[i].frecuencia / (double)n)*(double)factor);
                return ((double)c[i].frecuencia / (double)n)*(double)factor;
            }
        return 0.0;
    }
    
    public static void main(String[] args) {
        // Diego Garcia - Viernes, 08 de Mayo de 2015
        // Box and Miller (1958)
        /*
        for (int i=0; i<N; i++)
        {
            u1[i] = Math.random();
            u2[i] = Math.random();
            x1[i] = Math.sqrt((double)-2.0 * Math.log(u1[i])) * Math.cos( (double)2.0 * Math.PI * u2[i]);
            x2[i] = Math.sqrt((double)-2.0 * Math.log(u1[i])) * Math.sin( (double)2.0 * Math.PI * u2[i]);
            u1[i] = distrNormald(x1[i], 0, 1);
            u2[i] = distrNormald(x2[i], 0, 1);
        }
        //**********************************************************************
        // implementaci??n Algoritmo Metropolis Hasting - Mayo 20 de 2015 - Diego Garc??a
        //**********************************************************************        
        //t = 1000;
        double sigma2 = 0.1; // varianza
        x[0] = 0.4; // 1. Inicializacion Xo
        p[0] = distrNormald(x[0], x[0], 1.0/sigma2);
        for (int s=0; s < t-1; s++){ // 2. Iteracion
            double X = x[s];  // 3. Define X = Xs
            double Xp = dnorm(X,sigma2); // 4. Sample Xp from proposal distribution
            // 5. Compute acceptance probability (alpha)
            double Px  = dcat(X);
            double Pxp = dcat(Xp);
            double alpha = Pxp / Px; 
            
            double r = (alpha > 1)? 1.0 : Pxp/Px; // Compute r = min (1,alpha)
            // 6. Sample u ~ U(0,1);
            //double u = Math.random();
            // 7. Set new sample to
            //x[s+1] = (u < r)? Xp : x[s];
            //p[s+1] = (u < r)? alpha : p[0]; //distrNormald(x[s+1], x[s+1], 1.0/sigma2);
            
            
            if (alpha >= 1.0)
                x[s+1] = Xp;
            else
                x[s+1] = (Math.random() < alpha)? Xp : x[s];
            p[s+1] = dcat(x[s+1]);//distrNormald(x[s+1], x[s], 1.0/sigma2);                

            //System.out.println("X:"+X+" Xp:"+Xp+" Px:"+Px+ "Pxp:"+Pxp+" alpha:"+alpha);
        }
        //**********************************************************************            
        init();
        load();
        */
        //n = t;        
        //init2();
        //load2();
        //**********************************************************************    
        
        mh = new Hasting();
        mh.stationaryData = new float[5000];
        // Obtenci??n de datos de la mezcla gausiana desde la base de datos Oracle (dmixture)
        /*
          X~dnorm(2.0, 1.0)
          Y~dnorm(-2.0, 3.0)
          Z~dbin(0.3,1)
          P<-X*(1-Z) + Y*Z        
        */
        // 2015-MAY-27 Utilizaci??n bibliotecas fMEF del MIT
//        int n=2;
//        int n=1;
        int dim=2;
        f = new jMEF.MixtureModel( dim );

        // Choosen exponential family
        f.EF = new jMEF.MultivariateGaussian();
        // PARAMETRIZACION
//        for (int i=0; i<n; i++){
//            f.weight[i]=1f/(float)n;
//            f.param[i] = jMEF.PVectorMatrix.RandomDistribution(dim);
//        }
        // Set weights 
//        f.weight[1]=1f;
        f.weight[0]=0.7f;
        f.weight[1]=0.3f;
        
        jMEF.PVectorMatrix m1 = new jMEF.PVectorMatrix(dim);
        jMEF.PVectorMatrix m2 = new jMEF.PVectorMatrix(dim);
        // Mu and sigma R2
//        m1.v.array[0] = 0;
//        m1.v.array[1] = 0;        
//        m1.M.array[0][0] = 1;
//        m1.M.array[0][1] = 0.8;
//        m1.M.array[1][0] = 0.8;
//        m1.M.array[1][1] = 1;        
        
        m1.v.array[0] = 4;
        m1.v.array[1] = 5;
        m1.M.array[0][0] = 1;
        m1.M.array[0][1] = 0.7;
        m1.M.array[1][0] = 0.7;
        m1.M.array[1][1] = 1;       
        m2.v.array[0] = 0.7;
        m2.v.array[1] = 3.5;
        m2.M.array[0][0] = 1;
        m2.M.array[0][1] = -0.7;
        m2.M.array[1][0] = -0.7;
        m2.M.array[1][1] = 1;
        // Set the parameters 
        f.param[0] = m1 ;
        f.param[1] = m2 ;
//        // Let us convert them back to NATURAL parameters in order to use the
//        // centroid function
//        f.param[0]=f.EF.Lambda2Theta(f.param[0]);            
//        f.param[1]=f.EF.Lambda2Theta(f.param[1]);            

        // Choosen exponential family
//        f.EF = new jMEF.UnivariateGaussian( ) ;        
        // Parameters R1        
        jMEF.PVector p1 = new jMEF.PVector( 2 ) ;
        jMEF.PVector p2 = new jMEF.PVector( 2 ) ;
        // Mu and sigma
        p1.array[0] = 2 ; p1.array[1] = 1;
        p2.array[0] = -2 ; p2.array[1] = Math.sqrt(0.3);
        // Set the parameters
//        f.param[0] = p1 ;
//        f.param[1] = p2 ;
        
        // Draw points from the mixture
        jMEF.PVector[] points = f.drawRandomPoints(5000);
        for (int i=0; i<points.length; i++){
            //mh.stationaryData[i] = (float)points[i].array[0];           
            x1[i] = (float)points[i].array[0]; // R1 (X)            
            x2[i] = (float)points[i].array[1]; // R2 (Z)
            //u1[i] = (float)f.EF.density(points[i], f.param[0]); // P (Y)
            //u1[i] = (float)f.density(points[i]); // P (Y)
            
//            System.out.println("x="+x1[i]+", y="+u1[i] +", z="+x2[i]);
//            System.out.println("x="+x1[i]+", z="+x2[i]);
//            System.out.println("{"+x1[i]+","+x2[i]+"}");
        }
//graficacion MEZCLA DE GAUSIANAS EN R2         
h = new HistogramR2(points.length, 0.2f, -2, 8);
h.Load(points);
h.visible = false;
/******************************************************************************/
// GAUSIANA EN R2        
//mm_centroid=MixtureModel(1);
//mm_centroid.EF=MultivariateGaussian;
//mm_centroid.weight(1)=1;
//mm_centroid.param(1)=symmetric_centroid;
//jMEF.MixtureModel mm_centroid = new jMEF.MixtureModel( 1 );
//mm_centroid.EF = new jMEF.MultivariateGaussian();
//mm_centroid.weight[0] = 1;
//mm_centroid.param[0] = m1;
////jMEF.PVector[] points = mm_centroid.drawRandomPoints(N);
//jMEF.PVector[] points = mm_centroid.drawRandomPoints(100);
//for (int i=0; i<points.length; i++){
//    //mh.stationaryData[i] = (float)points[i].array[0];           
//    x1[i] = (float)points[i].array[0]; // R1 (X)            
//    x2[i] = (float)points[i].array[1]; // R2 (Z)
//    //u1[i] = (float)f.EF.density(points[i], f.param[0]); // P (Y)
//    u1[i] = (float)mm_centroid.density(points[i]); // P (Y)
//    //System.out.println("x="+x1[i]+", y="+u1[i] +", z="+x2[i]);
//}
////graficacion GAUSIANA EN R2         
//h = new HistogramR2(points);
/******************************************************************************/
       
        /*****/        
//        mh.stationary = new Histogram(mh.stationaryData);
//        mh.stationary.visible = false;
//        mh.t = 5000;
//        mh.Xo = -0.4f;
//        //mh.q = new NormalDistribution(mh.Xo, 7.5f);                
//        mh.q = new NormalDistribution(mh.Xo, 4.5f);                
//        mh.metropolis();                
        /***/        
        //**********************************************************************
        // implementaci??n Algoritmo Metropolis Hasting - Mayo 20 de 2015 - Diego Garc??a
        //**********************************************************************
        // Param Proposal
        jMEF.PVectorMatrix m = new jMEF.PVectorMatrix(2); // R2
        // Mu and sigma R2
        m.v.array[0] = 0;
        m.v.array[1] = 0;     
        // co-varianza
        m.M.array[0][0] = 1;
        m.M.array[0][1] = 0.0;
        m.M.array[1][0] = 0.0;
        m.M.array[1][1] = 1;  
/******************************************************************************/   
        // deficion Proposal
        jMEF.MixtureModel q = new jMEF.MixtureModel( 2 );
        q.EF = new jMEF.MultivariateGaussian(); // Multivariate R2
        q.weight[0] = 1;
        q.param[0] = m;

        // Instancia
        mhBN = new HastingBN(q);
        mhBN.t = 5000;
        mhBN.x = new jMEF.PVector[mhBN.t];
        mhBN.stationary = h;
        
        mhBN.metropolis();
/******************************************************************************/        
        //graficacion MEZCLA DE GAUSIANAS EN R2 
        mhBN.result = new HistogramR2(mhBN.x.length, 0.2f, -2, 8);        
        mhBN.result.Load(mhBN.x);
        //mhBN.result.visible = false;
        
        //**********************************************************************    
        Frame frame = new Frame("Bayesian Framework");
        GLCanvas canvas = new GLCanvas();

        canvas.addGLEventListener(new Framework());
        frame.add(canvas);
        frame.setSize(640, 480);
        final Animator animator = new Animator(canvas);
        frame.addWindowListener(new WindowAdapter() {

            @Override
            public void windowClosing(WindowEvent e) {
                // Run this on another thread than the AWT event queue to
                // make sure the call to Animator.stop() completes before
                // exiting
                new Thread(new Runnable() {

                    public void run() {
                        animator.stop();
                        System.exit(0);
                    }
                }).start();
            }
        });
        // Center frame
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        animator.start();
        
                
    }

    public void init(GLAutoDrawable drawable) {
        // Use debug pipeline
        // drawable.setGL(new DebugGL(drawable.getGL()));

        GL gl = drawable.getGL();
        System.err.println("INIT GL IS: " + gl.getClass().getName());

        // Enable VSync
        gl.setSwapInterval(1);

        // Setup the drawing area and shading mode
        gl.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        gl.glShadeModel(GL.GL_SMOOTH); // try setting this to GL_FLAT and see what happens.
    }

    public void reshape(GLAutoDrawable drawable, int x, int y, int width, int height) {
        GL gl = drawable.getGL();
        GLU glu = new GLU();

        if (height <= 0) { // avoid a divide by zero error!
        
            height = 1;
        }
        final float h = (float) width / (float) height;
        gl.glViewport(0, 0, width, height);
        gl.glMatrixMode(GL.GL_PROJECTION);
        gl.glLoadIdentity();
        //glu.gluPerspective(45.0f, h, 1.0, 20.0);
        glu.gluPerspective(45.0f, h, 1.0f, 1000.0f);        
        gl.glMatrixMode(GL.GL_MODELVIEW);
        
        gl.glLoadIdentity();
    }
    
    public void display(GLAutoDrawable drawable) {
        GL gl = drawable.getGL();

        // Clear the drawing area
        gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
        // Reset the current matrix to the "identity"
        gl.glLoadIdentity();
        
        // Move the "drawing cursor" around
        //gl.glTranslatef(-1.5f, 0.0f, -6.0f);
        //gl.glTranslatef(0.0f, -2.0f, -6.0f);
//        gl.glTranslatef(0f, -0.2f, -6.0f);
        gl.glTranslatef(-2f, -0.5f, -5f);
        // SUPERIOR
//        gl.glTranslatef(0f, 0f, -5f);
//        gl.glRotatef(90f, 1f, 0f, 0f);        
//        gl.glRotatef(90f, 0f, 1f, 0f);        
        // FRONT (X / Y)
        // SIDE (Z / Y)
//        gl.glRotatef(90f, 0f, 1f, 0f);
        // PERSPECTIVA
        gl.glRotatef(33f, 1f, 0f, 0f); // Z
        gl.glRotatef(66f, 0f, 1f, 0f);
////        gl.glRotatef(-45f, 0f, 1f, 0f);
////        gl.glRotatef(45f, 0f, 0f, 1f);
        
        //gl.glScalef(0.6f, 5f, 1f);
//        gl.glScalef(0.6f, 5f, 0.6f);
        gl.glScalef(0.6f, 5f, 0.6f);
        
        // Salida algoritmo Metropolis Hasting
        // 28-AGO-2015 dgarcia 
        /* Visualizacion de puntos generados por Hasting
        for (int i=0; i<xR2.length; i++){
//        for (int i=0; i<mhBN.x.length; i++){
            gl.glBegin(GL.GL_POINTS);
            //gl.glVertex3f((float)x[i], (float)p[i], 0.0f);   
            gl.glColor3f(0.0f, 1.0f, 0.0f);    // Set the current drawing color to green
            //gl.glVertex3f((float)x1[i], (float)u1[i], 0.0f);
//            gl.glVertex3f((float)x1[i], (float)u1[i], (float)x2[i]);
//            gl.glVertex3f((float)xR2[i].array[1], (float)h.getDensity(xR2[i]), (float)xR2[i].array[0]);            
            gl.glVertex3f((float)xR2[i].array[1], (float)f.density(xR2[i]), (float)xR2[i].array[0]);            
//            gl.glVertex3f((float)mhBN.x[i].array[1], (float)f.density(mhBN.x[i]), (float)mhBN.x[i].array[0]);            
            gl.glColor3f(0.5f, 0.5f, 1.0f);    // Set the current drawing color to light blue
            //gl.glVertex3f(0f, (float)u1[i], (float)x1[i]);
            gl.glEnd();  
        }
        */
        
        
        /* target for Normal Distribution
        for (int i=0; i<N; i++){
            gl.glBegin(GL.GL_POINTS);
            //gl.glBegin(GL.GL_LINES);
                gl.glColor3f(0.5f, 0.5f, 1.0f);    // Set the current drawing color to light blue
                //gl.glVertex3f((float)x1[i], (float)u1[i], 0.0f);  
                
                ////gl.glVertex3f((float)x1[i], (float)u1[i], 0.0f);                  
                
                //gl.glVertex3f((float)x2[i], (float)u2[i], 0.0f);                  
                //gl.glVertex3f(0.0f, 0.0f, (float)i*0.01f);
                gl.glColor3f(0.0f, 1.0f, 0.0f);    // Set the current drawing color to green
               gl.glVertex3f((float)x2[i], (float)u2[i], 0.0f);   
                //gl.glVertex3f(-1.0f, 1.0f, 0.0f);  
                //gl.glVertex3f(1.0f, 1.0f, 0.0f);   
               
            gl.glEnd();  
            
            //gl.glColor3f(0.0f, 0.0f, 1.0f);    // Set the current drawing color to blue
            //if (i<N-1){
            //    //gl.glBegin(GL.GL_LINES);
            //    gl.glBegin(GL.GL_POINTS);
            //        //gl.glScalef(0f, 0.0f, 0.1f);                
            //        gl.glVertex3f((float)x1[i], 0.0f, (float)i*0.001f);
            //        //gl.glVertex3f((float)x1[i+1], 0.0f, (float)(i+1)*0.002f);
            //    gl.glEnd();
            //}
                    
        }
        /* stationary for Normal Distribution
        
        /* stationary for Normal Distribution
        for (int i=0; i<c.length; i++){
            //gl.glBegin(GL.GL_POINTS);
            gl.glBegin(GL.GL_LINES);
                gl.glColor3f(1.0f, 0.0f, 0.0f);    // Set the current drawing color to red
                gl.glVertex3f((float)c[i].inicio,       0f, 0f); // Bottom Left
                
                gl.glVertex3f((float)c[i].inicio,       ((float)c[i].frecuencia/n)*factor, 0f);  // Top Left
                gl.glVertex3f((float)c[i].inicio,       ((float)c[i].frecuencia/n)*factor, 0f);  // Top Left
                gl.glVertex3f((float)(c[i].inicio+interv),  ((float)c[i].frecuencia/n)*factor, 0f);   // Top Right
                gl.glVertex3f((float)(c[i].inicio+interv),  ((float)c[i].frecuencia/n)*factor, 0f);   // Top Right
                
                
                //gl.glVertex3f((float)c[i].inicio,       (float)Px, 0f);  // Top Left
                //gl.glVertex3f((float)c[i].inicio,       (float)Px, 0f);  // Top Left
                //gl.glVertex3f((float)(c[i].inicio+interv),  (float)Px, 0f);   // Top Right
                //gl.glVertex3f((float)(c[i].inicio+interv),  (float)Px, 0f);   // Top Right
                
                gl.glVertex3f((float)(c[i].inicio+interv),  0f, 0f);  // Bottom Right
                gl.glVertex3f((float)(c[i].inicio+interv),  0f, 0f);  // Bottom Right
                gl.glVertex3f((float)c[i].inicio,       0f, 0f); // Bottom Left
            gl.glEnd();  
            
                        
        }
        */


        //mh.display(gl);
//        h.display(gl);
/****
 * 2015-08-18 dgarcia
 * 2015-08-28 dgarcia
 */
       //r.display(gl);
       mhBN.stationary.display(gl);
       mhBN.result.display(gl);
                
        gl.glBegin(GL.GL_LINES);// lineas guia
           gl.glColor3f(1.0f, 1.0f, 1.0f);    // Set the current drawing color to white
           gl.glVertex3f(-5f, 0.0f, 0f); //  X
           gl.glVertex3f(8f, 0.0f, 0f);
           gl.glVertex3f(0f, 0f, 0f); //  Y
           gl.glVertex3f(0f, 1f, 0f);
           gl.glVertex3f(0f, 0.0f, -5f); //  Z
           gl.glVertex3f(0f, 0.0f, 8f);
        gl.glEnd();
//        gl.glBegin(GL.GL_POINTS);// puntos guia
        gl.glBegin(GL.GL_LINES);// puntos guia
           gl.glColor3f(1.0f, 0.0f, 0.0f);    // Set the current drawing color to red
           gl.glVertex3f(0f, 0.0f, 0f); // X
           gl.glVertex3f(1f, 0.0f, 0f);

           gl.glVertex3f(2f, 0.0f, 0f);
           gl.glVertex3f(3f, 0.0f, 0f);
           
           gl.glVertex3f(4f, 0.0f, 0f);
           gl.glVertex3f(5f, 0.0f, 0f);
           
           gl.glVertex3f(6f, 0.0f, 0f);
           gl.glVertex3f(7f, 0.0f, 0f);

           gl.glVertex3f(0f, 0.0f, 0f);
           gl.glVertex3f(-1f, 0.0f, 0f);

           gl.glVertex3f(-2f, 0.0f, 0f);           
           gl.glVertex3f(-3f, 0.0f, 0f);
           
           gl.glVertex3f(-4f, 0.0f, 0f);           
           gl.glVertex3f(-5f, 0.0f, 0f);

           gl.glVertex3f(0f, 0.0f, 0f); // Y
           gl.glVertex3f(0f, 0.1f, 0f);

           gl.glVertex3f(0f, 0.2f, 0f);
           gl.glVertex3f(0f, 0.3f, 0f);

           gl.glVertex3f(0f, 0.4f, 0f);
           gl.glVertex3f(0f, 0.5f, 0f);

           gl.glVertex3f(0f, 0.6f, 0f);
           gl.glVertex3f(0f, 0.7f, 0f);

           gl.glVertex3f(0f, 0.8f, 0f);
           gl.glVertex3f(0f, 0.9f, 0f);

           gl.glVertex3f(0f, 0.0f, 0f); // Z
           gl.glVertex3f(0f, 0.0f, 1f);

           gl.glVertex3f(0f, 0.0f, 2f);
           gl.glVertex3f(0f, 0.0f, 3f);

           gl.glVertex3f(0f, 0.0f, 4f);
           gl.glVertex3f(0f, 0.0f, 5f);

           gl.glVertex3f(0f, 0.0f, 6f);
           gl.glVertex3f(0f, 0.0f, 7f);

           gl.glVertex3f(0f, 0.0f, 0f);
           gl.glVertex3f(0f, 0.0f, -1f);

           gl.glVertex3f(0f, 0.0f, -2f);
           gl.glVertex3f(0f, 0.0f, -3f);

           gl.glVertex3f(0f, 0.0f, -4f);
           gl.glVertex3f(0f, 0.0f, -5f);
           
        gl.glEnd();
        
        // Flush all drawing operations to the graphics card
        gl.glFlush();
    }

    public void displayChanged(GLAutoDrawable drawable, boolean modeChanged, boolean deviceChanged) {
    }
}
class Cate{
    float inicio, fin;
    int frecuencia;
}

/*        
        // binomial
        double p;
        int x;
        double Px;
        for (int i=0; i<c.length; i++)        
            if (c[i].inicio == 0){
                //distrBind(int x, int n, double p)
                //double xbin = distrBind((int)c[i].frecuencia, 1000, (double)c[i].frecuencia/1000.0);
                //gl.glRasterPos2f(95, 20);
                //double 
                p = c[i].frecuencia/1000.0;
                //int 
                x = (int)c[i].frecuencia;
                //int 
                n = 1000;
                //double 
                Px = distrBind(x, n, p);
                // binomial
                System.err.println("****************************************************************");
                System.out.println("x = " + x);
                System.out.println("n = " + n);
                System.out.println("p = " + p);
                System.out.println("Px = " + Px);                
            }
        */
        /*
        // Conexion a oracle 
        try{
            DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            Connection conn = DriverManager.getConnection
                ("jdbc:oracle:thin:@192.168.56.101:1521:XE", "bio", "bayesian");
            // driver@machineName:port:SID           ,  userid,  password
            Statement stmt = conn.createStatement();
            ResultSet rset = 
              //stmt.executeQuery("select id as i, value as x, fnuDistrNormal(value, 0, 1) as u from dnorm");            
              stmt.executeQuery(
                      "select id as i, value as x,"+
                      "fnuDistrMixture(value, 2, 1, -2, 3, 0.3) as u "+
                      "from dmixture");            
            while (rset.next()){
                //System.out.println (rset.getString(1));   // Print col 1
                int i = rset.getInt(1);
                x1[i-1] = rset.getFloat(2);
                u1[i-1] = distrMixtured(x1[i-1],2,1,-2,3,0.3); //rset.getFloat(3); 
                ////mh.stationaryData[i-1] =  rset.getFloat(2);
            }            
            // Para ejecutar INSERT, UPDATE, DELETE;
            // stmt.executeUpdate("INSERT .. ");
            ////for (int i=0; i<t; i++)
                ////stmt.executeUpdate("INSERT INTO result(x,p) VALUES("+x[i]+","+p[i]+")");

            stmt.close();        
        }
	catch (SQLException e){e.printStackTrace();}
        */
