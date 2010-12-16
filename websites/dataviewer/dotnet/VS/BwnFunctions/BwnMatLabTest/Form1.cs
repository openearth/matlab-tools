using System;
using System.Drawing;
using System.IO;
using System.Net;
using System.Windows.Forms;
using BwnMatLabTest.Bwn;

namespace BwnMatLabTest
{
    public partial class Form1 : Form
    {
        private void Form1_Load(object sender, EventArgs e)
        {

        }
        
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var ncFile = "http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv250.nc";
            var ncVariable = "AHN250";
            var centre = new[] {53.22917, 5.154906};
            var vertex = new[] {53.15018 , 5.120844};

            var soapClient = new BwnFunctionsWrapperSoapClient();
            var imageName = soapClient.InterpolateToLine(ncFile, ncVariable, centre[0], centre[1], vertex[0], vertex[1]);
            pictureBox1.Image = LoadPicture("http://" + soapClient.Endpoint.Address.Uri.Authority + imageName);
        }

    
        private void button2_Click(object sender, EventArgs e)
        {
            var ncFile = "http://opendap.deltares.nl/thredds/dodsC/opendap/knmi/etmgeg/etmgeg_344.nc";
            var ncVariable = "wind_speed_mean";
            var startTime = "20100101T000000";
            var stopTime = "20100201T000000";
            var soapClient = new BwnFunctionsWrapperSoapClient();
            var imageName = soapClient.PlotTimeSeries(ncFile, ncVariable,startTime,stopTime);
            pictureBox1.Image = LoadPicture("http://" + soapClient.Endpoint.Address.Uri.Authority + imageName);
        }

        private Bitmap LoadPicture(string url)
        {
            HttpWebRequest wreq;
            HttpWebResponse wresp;
            Stream mystream;
            mystream = null;
            wresp = null;
            try
            {
                wreq = (HttpWebRequest) WebRequest.Create(url);
                wreq.AllowWriteStreamBuffering = true;

                wresp = (HttpWebResponse) wreq.GetResponse();

                if ((mystream = wresp.GetResponseStream()) != null)
                    return new Bitmap(mystream);
            }
            finally
            {
                if (mystream != null)
                    mystream.Close();

                if (wresp != null)
                    wresp.Close();

            }
            return null;
        }
    }
}
