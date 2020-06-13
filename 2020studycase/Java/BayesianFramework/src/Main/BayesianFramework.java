package Main;

import BN.CoefNode;
import BN.List;
import BN.Trace;
import com.sun.opengl.util.Animator;
import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.media.opengl.GL;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLCanvas;
import javax.media.opengl.GLEventListener;
import javax.media.opengl.glu.GLU;

/**
 * BayesianFramework.java <BR>
 * author: Brian Paul (converted to Java by Ron Cemer and Sven Goethel) <P>
 *
 * This version is equal to Brian Paul's version 1.2 1999/10/21
 */
public class BayesianFramework implements GLEventListener {

    public static void main(String[] args) {
        Frame frame = new Frame("Simple JOGL Application");
        GLCanvas canvas = new GLCanvas();

        canvas.addGLEventListener(new BayesianFramework());
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
//        frame.setVisible(true);
//        animator.start();
        /**********************************************************************/
        /** Modeling a Bayesian network continuos case (2015-10) */
        /**********************************************************************/
        // Defining the  nodes
        jMEF.PVector param;
        BN.BayesianNode<String> e = new BN.BayesianNode<String>();
        e.name ="Environmental Potential";
        e.sample = null; e.cpt = null; e.coef = null;
        e.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        e.cpd.EF = new jMEF.UnivariateGaussian(); // Choosen exponential family
        // Set the parameters
        param = new jMEF.PVector( 2 ) ;        
        // Mu and sigma
        param.array[0] = 50;
        param.array[1] = 100;
        e.cpd.param[0] = param ;
        // Set weights
        e.cpd.weight[0]=1f;        
        // Coef Linear Gaussian Model
        e.coef = new BN.List < CoefNode >();
        e.coef.insertAtFront(new BN.CoefNode(null, 50f));          
        
        BN.BayesianNode<String> g = new BN.BayesianNode<String>();
        g.name ="Genetic Potential";
        g.sample = null; g.cpt = null;  g.coef = null;
        g.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        g.cpd.EF = new jMEF.UnivariateGaussian(); // Choosen exponential family
        // Set the parameters
        param = new jMEF.PVector( 2 ) ;        
        // Mu and sigma
        param.array[0] = 50;
        param.array[1] = 100;
        g.cpd.param[0] = param ;
        // Set weights
        g.cpd.weight[0]=1f;  
        // Coef Linear Gaussian Model
        g.coef = new BN.List < CoefNode >();
        g.coef.insertAtFront(new BN.CoefNode(null, 50f));         

        BN.BayesianNode<String> v = new BN.BayesianNode<String>();
        v.name ="Vegetative Organs";
        v.sample = null; v.cpt = null; v.coef = null;
        v.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        v.cpd.EF = new jMEF.UnivariateGaussian(); // Choosen exponential family
        // Set the parameters
        param = new jMEF.PVector( 2 ) ;        
        // Mu and sigma
        param.array[0] = -10.35534; // -10.35534 + 0.5G + 0.7711E
        param.array[1] = 25;
        v.cpd.param[0] = param ;
        // Set weights
        v.cpd.weight[0]=1f;        
        // Coef Linear Gaussian Model
        v.coef = new BN.List < CoefNode >();
        v.coef.insertAtFront(new BN.CoefNode(null, -10.35534f));        
        v.coef.insertAtFront(new BN.CoefNode(g, 0.5f));
        v.coef.insertAtFront(new BN.CoefNode(e, 0.7711f));
        
        // Connecting the nodes
        e.children = new BN.List<BN.BayesianNode>();
        e.children.insertAtBack(v);
        
        g.children = new BN.List<BN.BayesianNode>();
        g.children.insertAtBack(v);
        
        v.parents = new BN.List<BN.BayesianNode>();
        v.parents.insertAtBack(e);
        v.parents.insertAtBack(g);

        // Building the network
        BN.BayesianNetwork< Integer > bn = new BN.BayesianNetwork< Integer >(); // create a BN 
        bn.roots = new BN.List<BN.BayesianNode>();
        bn.roots.insertAtBack(e);
        bn.roots.insertAtBack(g);

        // To sample from BN
        BN.Sampling sampler = new BN.Sampling();
//        Trace.active = true;
        BN.List<BN.BayesianNode> aTopologicalOrder = sampler.findATopologicalOrder(bn);   
        
        // Is aTopologicalOrder right ? Yes it's!
        System.out.println(aTopologicalOrder.queryNodeFromFront().data.name);
        System.out.println(aTopologicalOrder.queryNodeFromFront().nextNode.data.name);
        System.out.println(aTopologicalOrder.queryNodeFromFront().nextNode.nextNode.data.name);
        System.out.println(aTopologicalOrder.queryNodeFromFront().nextNode.nextNode.nextNode);

        int N = 15624; // size of X
        BN.List<String> X[] = new BN.List[N];
        for (int i=0; i<N; i++){
            X[i] = sampler.forwardSample(aTopologicalOrder); 
            X[i].print();
        }
       
        int degradeOfFree = 5;
        BN.HistogramRN hR3 = new BN.HistogramRN(degradeOfFree);
        float[][] range = new float[3][2];
        range[0][0] = 30f; //20f;
        range[0][1] = 70f; //80f;
        range[1][0] = 30f; //20f;
        range[1][1] = 70f; //80f;
        range[2][0] = 30f; //20f;
        range[2][1] = 70f; //80f;                
        hR3.Init(range);
        hR3.loadSamples(X);
        
        for (int i=0; i< hR3.c.length; i++)
            for (int j=0; j< hR3.c[i].length; j++)
                for (int k=0; k< hR3.c[i][j].length; k++){
                    System.out.println(
//                            "\nStart ["+i+"]["+j+"]["+k+"]("+
//                            hR3.c[i][j][k].startPoint[0] + "," +
//                            hR3.c[i][j][k].startPoint[1] + "," +
//                            hR3.c[i][j][k].startPoint[2] + ")" +
//                            "\nendPoint ["+i+"]["+j+"]["+k+"]("+
//                            hR3.c[i][j][k].endPoint[0] + "," +
//                            hR3.c[i][j][k].endPoint[1] + "," +
//                            hR3.c[i][j][k].endPoint[2] + ")\n" + 
//                            hR3.c[i][j][k].frequency
                            //((float)hR3.c[i][j][k].frequency / (float)hR3.n ) / (hR3.width[0]*hR3.width[1]*hR3.width[2]) 
                            hR3.c[i][j][k].startPoint[0] + ";" +
                            hR3.c[i][j][k].startPoint[1] + ";" +
                            hR3.c[i][j][k].startPoint[2] + ";" +
                            hR3.c[i][j][k].endPoint[0] + ";" +
                            hR3.c[i][j][k].endPoint[1] + ";" +
                            hR3.c[i][j][k].endPoint[2] + ";" + 
                            hR3.c[i][j][k].frequency
                    );
                }
        
//        for (int i=0; i<h.x.length; i++)
//            System.out.println(h.frequency[i]+"\t"+h.getRelativeFrecuency(h.x[i]));
//            System.out.printf("%d\t%.6f\n",h.frequency[i],h.getRelativeFrecuency(h.x[i]));
        
        /**********************************************************************/        
        // Defining the  nodes (Case Discrete)
        
        BN.BayesianNode<String> pollution = new BN.BayesianNode<String>();
        pollution.name ="Pollution";
        pollution.cpt = new BN.CPT<String>();
        pollution.cpt.insert("L", 0.9f, null);        
        pollution.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        pollution.cpd.EF = new jMEF.Bernoulli(); // Choosen exponential family
        pollution.sample = null;

        BN.BayesianNode<String> smoker = new BN.BayesianNode<String>();
        smoker.name ="Smoker";
        smoker.cpt = new BN.CPT<String>();
        smoker.cpt.insert("T",0.3f, null);        
        smoker.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        smoker.cpd.EF = new jMEF.Bernoulli(); // Choosen exponential family
        smoker.sample = null;
        
        BN.BayesianNode<String> cancer = new BN.BayesianNode<String>();
        cancer.name ="Cancer";
        cancer.cpt = new BN.CPT<String>();       
        cancer.cpt.inserts("T",
                        //  C      P S
                new float[]{Float.NaN,
                            0.05f,  // 1 0 
                            0.02f,  // 1 1 
                            0.03f,  // 1 0 
                            0.001f},// 1 0
                           //P S
                new String[][]{{"Pollution","Smoker"},
                            {"H","T"},
                            {"H","F"},
                            {"L","T"},
                            {"L","F"}}
        );
        cancer.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        cancer.cpd.EF = new jMEF.Bernoulli(); // Choosen exponential family        
        cancer.sample = null;
        
        
        BN.BayesianNode<String> xray = new BN.BayesianNode<String>();
        xray.name ="Xray";        
        xray.cpt = new BN.CPT<String>();
        xray.cpt.inserts( "pos",
                new float[]{Float.NaN,
                            0.9f,  // 0 
                            0.2f},// 1 0
                           //P S
                new String[][]{{"Cancer"},
                            {"T"},
                            {"F"}}
        ); 
        xray.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        xray.cpd.EF = new jMEF.Bernoulli(); // Choosen exponential family
        xray.sample = null;
        
        BN.BayesianNode<String> dyspnoea = new BN.BayesianNode<String>();
        dyspnoea.name ="Dyspnoea";        
        dyspnoea.cpt = new BN.CPT<String>();
        dyspnoea.cpt.inserts( "T",
                new float[]{Float.NaN,
                            0.65f,  // 0 
                            0.3f},// 1 0
                           //P S
                new String[][]{{"Cancer"},
                            {"T"},
                            {"F"}}
        );         
        dyspnoea.cpd = new jMEF.MixtureModel( 1 ); // dim <- 1
        dyspnoea.cpd.EF = new jMEF.Bernoulli(); // Choosen exponential family
        dyspnoea.sample = null;
        
        // Connecting the nodes
        pollution.children = new BN.List<BN.BayesianNode>();
        pollution.children.insertAtBack(cancer);
        
        smoker.children = new BN.List<BN.BayesianNode>();
        smoker.children.insertAtBack(cancer);
        
        cancer.parents = new BN.List<BN.BayesianNode>();
        cancer.parents.insertAtBack(pollution);
        cancer.parents.insertAtBack(smoker);
        
        cancer.children = new BN.List<BN.BayesianNode>();
        cancer.children.insertAtBack(xray);
        cancer.children.insertAtBack(dyspnoea);

        xray.parents = new BN.List<BN.BayesianNode>(); 
        xray.parents.insertAtBack(cancer);
        
        dyspnoea.parents = new BN.List<BN.BayesianNode>(); 
        dyspnoea.parents.insertAtBack(cancer);
        
        // Building the network
        BN.BayesianNetwork< Integer > cancer_bn = new BN.BayesianNetwork< Integer >(); // create a BN 
        cancer_bn.roots = new BN.List<BN.BayesianNode>();
        cancer_bn.roots.insertAtBack(pollution);
        cancer_bn.roots.insertAtBack(smoker);
        
        // To sample from BN
        sampler = new BN.Sampling();
//        Trace.active = true;
        aTopologicalOrder = sampler.findATopologicalOrder(cancer_bn);        

        N = 1; //10000; //1000; // size of X
        X = new BN.List[N];
        for (int i=0; i<N; i++){
            X[i] = sampler.forwardSample(aTopologicalOrder); 
//            X[i].print();
        }
        
        // To wirte samples to file
//        BN.FileManager.writeSamples(aTopologicalOrder, X);
        
        BN.Histogram h = new BN.Histogram<String>(32);
        h.init(new String[][]{
            {"L","T","T","pos","T"},
            {"L","T","T","pos","F"},
            {"L","T","T","neg","T"},
            {"L","T","T","neg","F"},
            {"L","T","F","pos","T"},
            {"L","T","F","pos","F"},
            {"L","T","F","neg","T"},
            {"L","T","F","neg","F"},
            {"L","F","T","pos","T"},
            {"L","F","T","pos","F"},
            {"L","F","T","neg","T"},
            {"L","F","T","neg","F"},
            {"L","F","F","pos","T"},
            {"L","F","F","pos","F"},
            {"L","F","F","neg","T"},
            {"L","F","F","neg","F"},
            {"H","T","T","pos","T"},
            {"H","T","T","pos","F"},
            {"H","T","T","neg","T"},
            {"H","T","T","neg","F"},
            {"H","T","F","pos","T"},
            {"H","T","F","pos","F"},
            {"H","T","F","neg","T"},
            {"H","T","F","neg","F"},
            {"H","F","T","pos","T"},
            {"H","F","T","pos","F"},
            {"H","F","T","neg","T"},
            {"H","F","T","neg","F"},
            {"H","F","F","pos","T"},
            {"H","F","F","pos","F"},
            {"H","F","F","neg","T"},
            {"H","F","F","neg","F"}            
            });
//        for (int i=0; i<h.x.length; i++)
//            h.x[i].print();
        h.loadSamples(X);
//        for (int i=0; i<1; i++) //14th Oct h.x.length; i++)
////            System.out.println(h.frequency[i]+"\t"+h.getRelativeFrecuency(h.x[i]));
//            System.out.printf("%d\t%.6f\n",h.frequency[i],h.getRelativeFrecuency(h.x[i]));
        
//        BN.List<String> x = sampler.forwardSample(cancer_bn, "only-header");        
//        x.print();        
//        sampler.cleanSample(cancer_bn);
//        //Trace.active = true;
//        x = sampler.forwardSample(cancer_bn, "only-data"); //"xml");        
//        x.print();        
        
        // Testing Multinomial distribution
//        jMEF.MixtureModel f = new jMEF.MixtureModel( 1 ); // dim <- 1
//        // Choosen exponential family
//        f.EF = new jMEF.MultinomialFixedN(4); // n <- 4
//        jMEF.PVector L = new jMEF.PVector(3);
//        L.array[0] = 0.7f; // p1 <- 0.7
//        L.array[1] = 0.2f; // p2 <- 0.2
//        L.array[2] = 0.1f; // p3 <- 0.1
//        f.param[0] = L;
//        
//        jMEF.PVector[] samples = f.drawRandomPoints(10);
//        for (int i=0; i<samples.length; i++)
//            System.out.println( samples[i].array[0] + " " + samples[i].array[1] + " " + samples[i].array[2]);
        
        // Testing Bernulli distribution
//        jMEF.MixtureModel f = new jMEF.MixtureModel( 1 ); // dim <- 1
//        // Choosen exponential family
//        f.EF = new jMEF.Bernoulli();
//        jMEF.PVector L = new jMEF.PVector(1);
//        L.array[0] = 0.2f; // p <- 0.9
//        f.param[0] = L;
//        
//        jMEF.PVector[] samples = f.drawRandomPoints(10);
//        for (int i=0; i<samples.length; i++)
//            System.out.println( samples[i].array[0]);
        
        // Connecting nodes
//        BN.ListNode<BN.BayesianNode>  node = bn.roots.queryNodeFromFront();
//        while (node!=null){
//            if (node.data.name.compareTo("Pollution")==0 || node.data.name.compareTo("Smoker")==0){
//                node.data.children = new BN.List<BN.BayesianNode>();
//                node.data.children.insertAtBack(cancer);
//                cancer.parents.insertAtBack(node.data);
//            }
//            node = node.nextNode;
//        }
        
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
        glu.gluPerspective(45.0f, h, 1.0, 20.0);
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
        gl.glTranslatef(-1.5f, 0.0f, -6.0f);

        // Drawing Using Triangles
        gl.glBegin(GL.GL_TRIANGLES);
            gl.glColor3f(1.0f, 0.0f, 0.0f);    // Set the current drawing color to red
            gl.glVertex3f(0.0f, 1.0f, 0.0f);   // Top
            gl.glColor3f(0.0f, 1.0f, 0.0f);    // Set the current drawing color to green
            gl.glVertex3f(-1.0f, -1.0f, 0.0f); // Bottom Left
            gl.glColor3f(0.0f, 0.0f, 1.0f);    // Set the current drawing color to blue
            gl.glVertex3f(1.0f, -1.0f, 0.0f);  // Bottom Right
        // Finished Drawing The Triangle
        gl.glEnd();

        // Move the "drawing cursor" to another position
        gl.glTranslatef(3.0f, 0.0f, 0.0f);
        // Draw A Quad
        gl.glBegin(GL.GL_QUADS);
            gl.glColor3f(0.5f, 0.5f, 1.0f);    // Set the current drawing color to light blue
            gl.glVertex3f(-1.0f, 1.0f, 0.0f);  // Top Left
            gl.glVertex3f(1.0f, 1.0f, 0.0f);   // Top Right
            gl.glVertex3f(1.0f, -1.0f, 0.0f);  // Bottom Right
            gl.glVertex3f(-1.0f, -1.0f, 0.0f); // Bottom Left
        // Done Drawing The Quad
        gl.glEnd();

        // Flush all drawing operations to the graphics card
        gl.glFlush();
    }

    public void displayChanged(GLAutoDrawable drawable, boolean modeChanged, boolean deviceChanged) {
    }
}

