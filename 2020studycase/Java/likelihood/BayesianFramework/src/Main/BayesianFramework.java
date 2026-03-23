package Main;

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
        Frame frame = new Frame("Bayesian Framework");
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
        
        // 06-03-2016 dgarcia
        
        Likelihood.BayesianModel bm = new Likelihood.BayesianModel(
                // Define Pijk vector
                new float[][][]{
                    {//i=1
                        {// j=1                            
                                0.9f // k=1
                        },
                        {// j=2
                                0.1f // k=1
                        }
                    },
                    {//i=2
                        {// j=1
                                0.3f // k=1
                        },
                        {// j=2
                                0.7f // k=1
                        }
                    },
                    {//i=3
                        {// j=1
                                0.05f, 0.02f, 0.03f, 0.001f // k=1,2,3,4
                        },
                        {// j=2
                                0.95f, 0.98f, 0.97f, 0.999f // k=1,2,3,4
                        }

                    },
                    {//i=4
                        {// j=1
                                0.9f, 0.2f // k=1,2
                        },
                        {// j=2
                                0.1f, 0.8f // k=1,2
                        }
                    },
                    {//i=5
                        {// j=1
                                0.65f, 0.3f // k=1,2
                        },
                        {// j=2
                                0.35f, 0.7f // k=1,2
                        }
                        
                    }
                },
                // Define Nijk vector
                new int[][][]{
                    {//i=1
                        {// j=1                            
                                1016 // k=1
                        },
                        {// j=2
                                8984 // k=1
                        }
                    },
                    {//i=2
                        {// j=1
                                3021 // k=1
                        },
                        {// j=2
                                6979 // k=1
                        }
                    },
                    {//i=3
                        {// j=1
                                12, 19, 82, 14 // k=1,2,3,4
                        },
                        {// j=2
                                294, 691, 2633, 6255 // k=1,2,3,4
                        }
                    },
                    {//i=4
                        {// j=1
                                117, 1936 // k=1,2
                        },
                        {// j=2
                                10, 7937 // k=1,2
                        }
                    },
                    {//i=5
                        {// j=1
                                84, 43 // k=1,2
                        },
                        {// j=2
                                2991, 6882 // k=1,2
                        }
                        
                    }                    
                },
                // Define Vi vector
                new int[]{1,2,3,4,5},
                // Define Ri vector
                new int[]{2,2,2,2,2},
                // Define Qi vector
                new int[]{1,1,4,2,2}
        );
        
//        // 07-03-2016 dgarcia Testing 1
//        for (int i=0; i < bm.v.length; i++){
//            System.out.print("i=" + (i+1));
//            for (int j=0; j < bm.r[i]; j++){
//                System.out.print("\tj=" + (j+1));
//                for (int k=0; k < bm.q[i]; k++)
//                    System.out.print("\t" + bm.n[i][j][k]);
//                System.out.println();
//            }
//        }
//        // 07-03-2016 dgarcia Testing 2
//        for (int i=0; i < bm.v.length; i++){
//            System.out.print("i=" + (i+1));
//            for (int j=0; j < bm.r[i]; j++){
//                System.out.print("\tj=" + (j+1));
//                for (int k=0; k < bm.q[i]; k++)
//                    System.out.printf("\t %.3f",bm.p[i][j][k]);
//                System.out.println();
//            }
//        }        
        
        System.out.println("Likelihood => "+bm.likelihood().toPlainString());
        
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

