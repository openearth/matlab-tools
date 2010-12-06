using System.Windows.Forms;
using OpenEarthTools;

namespace TestSharedMatlab
{
    public partial class Form1 : Form
    {
        private readonly Publisher publisher;

        public Form1()
        {
            InitializeComponent();
            //publisher = new Publisher();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
                publisher.Dispose();
            }
            base.Dispose(disposing);
        }

        private void button1_Click(object sender, System.EventArgs e)
        {
            var zandMotor = new ZandMotor.GebruikWriter();

            zandMotor.gebruikwriter("test deze functie");

            zandMotor.Dispose();
        }
    }
}
