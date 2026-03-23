/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        Sampling
 * Description: sampling algorithms that generates events from a Bayesian network. 
 * Each variable is sampled according to the conditional distribution given 
 * the values already sampled for the variable’s parents.
 * Author:      Diego Garcia
 * Date:        08th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-08   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class Sampling {
    
    public String not (String value){
        if (value.compareToIgnoreCase("T")==0)
            return "F";
        if (value.compareToIgnoreCase("F")==0)
            return "T";
        if (value.compareToIgnoreCase("pos")==0)
            return "neg"; 
        if (value.compareToIgnoreCase("neg")==0)
            return "pos";        
        if (value.compareToIgnoreCase("L")==0)
            return "H"; 
        if (value.compareToIgnoreCase("H")==0)
            return "L";    
        return "NOT "+value;
    }
    public float getConditionalProbability(BayesianNode  node){
        // 1. To contruct a list of  parents' nodes sample value
        ListNode<CPTNode> rowCPT = node.cpt.rows.queryNodeFromFront();                

        List <String> parentSample = new List <String>(); // list of  parents' nodes sample value        
                
        ListNode<String> parentRow = rowCPT.data.parents.queryNodeFromFront();
        while (parentRow != null){
            ListNode<BayesianNode>  parentNode  = node.parents.queryNodeFromFront();
            while (parentNode != null){
                if (parentRow.data.compareToIgnoreCase(parentNode.data.name) == 0){// parents' node sample value was found
                    if (parentNode.data.sample!= null)
                        parentSample.insertAtBack((String)parentNode.data.sample);
                    else return Float.NaN; //  parent have no one sample
                }
                parentNode = parentNode.nextNode;
            }
            parentRow = parentRow.nextNode;
        }
        
        // 2. To visit each row of the cpt and to return the probability that match with the parents' sample 
                
        // cpt's rows are visited
        rowCPT = rowCPT.nextNode;                        
        while (rowCPT!=null){
            parentRow = rowCPT.data.parents.queryNodeFromFront();
            ListNode<String> sample = parentSample.queryNodeFromFront();
            while (parentRow != null && sample != null && 
                   parentRow.data.compareToIgnoreCase(sample.data) == 0){
                parentRow = parentRow.nextNode;
                sample = sample.nextNode;
            }
            if (parentRow == null && sample == null) return rowCPT.data.probability;
            
            rowCPT = rowCPT.nextNode;                        
        }
        return Float.NaN;
    }
    public float getMeanGaussian(BayesianNode  node){
        float Mu = 0f;
        ListNode<CoefNode> coef = node.coef.queryNodeFromFront();
        while (coef != null){
            if (coef.data.parent == null)
                Mu += coef.data.coef;
            else{
                if (coef.data.parent.sample== null) return Float.NaN; //  parent have no one sample
                Mu += coef.data.coef * new Float(coef.data.parent.sample.toString()).floatValue();
            }
            coef = coef.nextNode;
        }
        return Mu;
    }    
    public String sampleNode(BN.BayesianNode node){
        
        if (node.coef == null){// Case discrete
            jMEF.PVector L = new jMEF.PVector(1); // dim <- 1

            if (node.cpt.rows == null && 
                node.parents == null){ // the node current have no parents (case root node)
                    L.array[0] = node.cpt.probability; // p <- rowCPT.data.probability
            }
            else{ // the node current have parents (case child node)
                float p = this.getConditionalProbability(node);
                Trace.trace ("Node: "+node.name+", Probability: "+p, 2);

                if (p > 0f)
                    L.array[0] = p;
                else return null; //  parent have no one sample
            }
            // Updating parameter of distribution
            node.cpd.param[0] = L;
            // Sampling from distribution
            jMEF.PVector[] samples = node.cpd.drawRandomPoints(1);
            return ((int)samples[0].array[0] == 1)? (String)node.cpt.value : 
                                                    this.not((String)node.cpt.value);
        }
        // 2015-10 Case continuos
        if (node.parents != null){ // the node current have parents (case child node)
            jMEF.PVector param = (jMEF.PVector)node.cpd.param[0];
            float Mu = getMeanGaussian(node);
            if (Mu > 0f)
                param.array[0] = Mu; // -10.35534 + 0.5G + 0.7711E
            else return null; //  parent have no one sample
            node.cpd.param[0] = param; // Update param
        }
        // Sampling from distribution
        jMEF.PVector[] samples = node.cpd.drawRandomPoints(1);
        return new Double(samples[0].array[0]).toString();
        
    }
    
    public void sampleHelper(List < BayesianNode > listNodes, List<String> x){
        System.out.println("Begin sampleHelper");
        if (listNodes != null){
            ListNode<BayesianNode>  node = listNodes.queryNodeFromFront();
            while (node!=null){ // list nodes are visited
                node.data.sample = this.sampleNode(node.data); // To save sample in node (for children nodes)
                System.out.println("  Proccesing node: "+ node.data.name+", sample: "+ node.data.sample);
                if (node.data.sample!= null)
                    x.insertAtBack( (String) node.data.sample ); // all parents have  one sample

                sampleHelper(node.data.children, x); // Recursive

                node = node.nextNode;
            }        
        }
        System.out.println("End sampleHelper");
    }
    
    public void forwardSampleHelper(ListNode<BayesianNode> node, List<String> x, String mode){
//        System.out.println("Begin forwardSampleHelper");
        if (node != null){            
            // Sampling Node if it have no sample
            if (node.data.sample == null){
                node.data.sample = this.sampleNode(node.data); // To save sample in node (for children nodes)
                if (node.data.sample!= null){  // all parents have one sample
                    if (mode.compareToIgnoreCase("xml") == 0)
                        x.insertAtBack("<"+node.data.name+">" + (String) node.data.sample + "</"+node.data.name+">");
                    if (mode.compareToIgnoreCase("only-header") == 0)
                        x.insertAtBack(node.data.name);
                    if (mode.compareToIgnoreCase("only-data") == 0)
                        x.insertAtBack((String) node.data.sample);
                }
                Trace.trace ("Proccesing node: "+ node.data.name+", sample: "+ node.data.sample,1);
            }
            
            // Sampling Node's Brothers  //if it have no sample
            if (node.nextNode != null) // && node.nextNode.data.sample == null)
                forwardSampleHelper(node.nextNode, x, mode);

            // Sampling Node's Children if it have children  
            if (node.data.children!=null)
                forwardSampleHelper(node.data.children.queryNodeFromFront(), x, mode);
            
        }
//        System.out.println("End forwardSampleHelper");
    }    
    public List<String> forwardSample (BayesianNetwork bn, String mode){
        
        List<String> x = new List<String>();
        
//        sampleHelper(bn.roots, x);
        forwardSampleHelper(bn.roots.queryNodeFromFront(), x, mode);
        
        return x;        
    }

    public void forwardSampleHelper(ListNode<BayesianNode> node, List<String> x){
        if (node != null){
            x.insertAtBack( sampleNode(node.data) );
            node.data.sample = x.queryFromBack();            
            Trace.trace ("Proccesing node: "+ node.data.name+", sample: "+ node.data.sample,1);
            
            forwardSampleHelper(node.nextNode, x);
        }
        
    }    
    
    public List<String> forwardSample (List<BayesianNode> aTopologicalOrder){
        
        List<String> x = new List<String>();
        
//        sampleHelper(bn.roots, x);
        forwardSampleHelper(aTopologicalOrder.queryNodeFromFront(), x);
        
        return x;        
    }
    
    public void findATopologicalOrderHelper(ListNode<BayesianNode> node, List<BayesianNode> x){
        if (node != null){            
            // Sampling Node if it have no sample
            if (node.data.sample == null){
                node.data.sample = this.sampleNode(node.data); // To save sample in node (for children nodes)
                if (node.data.sample!= null){  // all parents have one sample
                    x.insertAtBack(node.data);
                }
                Trace.trace ("Proccesing node: "+ node.data.name+", sample: "+ node.data.sample,1);
            }
            
            // Sampling Node's Brothers  //if it have no sample
            if (node.nextNode != null) // && node.nextNode.data.sample == null)
                findATopologicalOrderHelper(node.nextNode, x);

            // Sampling Node's Children if it have children  
            if (node.data.children!=null)
                findATopologicalOrderHelper(node.data.children.queryNodeFromFront(), x);            
        }        
    }    
    public List<BayesianNode> findATopologicalOrder(BayesianNetwork bn){
        List<BayesianNode> aTopologicalOrder = new List<BayesianNode>();
        findATopologicalOrderHelper(bn.roots.queryNodeFromFront(), aTopologicalOrder);
        return aTopologicalOrder;
    }
    
    public void cleanSampleHelper(ListNode<BayesianNode> node){
        if (node != null){            
            // Cleaning Node if it have  sample
            if (node.data.sample != null)
                node.data.sample = null;
            
            // Cleaning Node's Brothers
            if (node.nextNode != null) //l && node.nextNode.data.sample == null)
                cleanSampleHelper(node.nextNode);

            // Cleaning Node's Children if it have children  
            if (node.data.children!=null)
                cleanSampleHelper(node.data.children.queryNodeFromFront());
            
        }        
    }
    public void cleanSample (BayesianNetwork bn){
        cleanSampleHelper(bn.roots.queryNodeFromFront());
    }
    
}
