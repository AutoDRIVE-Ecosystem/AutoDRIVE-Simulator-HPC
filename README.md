# AutoDRIVE Simulator HPC - Palmetto WebViewer


This branch contains the code for the AutoDRIVE Simulator WebViewer, specifically for the Palmetto testing environment. 

This WebViewer may be used in conjunction with the test _autodrive_test_webviewer_, available under the **palmetto** branch of this same repository. 

In order to deploy the WebViewer for the aforementioned test, you need to update the target path within the _deploy_webviewer.sh_ script to point to your AutoDRIVE Simulator installation, and then execute the script.  

To access the WebViewer from outside the Palmetto cluster using a local browser, you first need to set up a 
SOCKS v5 tunnelling connection from your local machine, as explained in the [Palmetto Docs](https://docs.rcd.clemson.edu/palmetto/connect/proxy/).