# coding: utf-8
import os, sys, time, logging, argparse
from reader_sobek3.Sobek32FMConverter import Sobek32FMConverter
from reader_sobek3.Sobek3Reader import Sobek3Reader
from writer_dflowfm.FMWriter import FMWriter
from pathlib import Path


def sobek3_2_fm_converter(input_file, output_dir, generate_2d_grid):
    sobek3_to_dflowfm_converter_version = "1.17"
    reader       = Sobek3Reader()
    sobek3_model = reader.read_all(input_file)
    converter    = Sobek32FMConverter()
    fm_model     = converter.convert_to_fm_model(sobek3_model, generate_2d_grid)
    writer       = FMWriter(fm_model)
    succeeded    = writer.write_all(os.path.dirname(input_file), output_dir, sobek3_to_dflowfm_converter_version)


if __name__ == '__main__':
    generate_2d_grid   = False

    parser = argparse.ArgumentParser(description='Conversion script for SOBEK3 to D-Flow FM models.')
    parser.add_argument("--inputfile", "-i",
                        default="",
                        required=True,
                        help="Filename including path to the SOBEK3 md1d file",
                        dest="input_file")
    parser.add_argument("--outputdir", "-o",
                        default="",
                        required=True,
                        help="Path to a not yet existing directory where the resulting D-Flow FM model will be placed",
                        dest="output_dir")
    args = parser.parse_args()
    input_file = Path(args.__dict__["input_file"]).resolve()
    output_dir = Path(args.__dict__["output_dir"]).resolve()



    if not output_dir.exists():
        os.mkdir(output_dir)

    # set up logging to file - see previous section for more details
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                        datefmt='%m-%d %H:%M',
                        filename=os.path.join(output_dir,'sobek3_to_dflowfm.log'),
                        filemode='w')
    # define a Handler which writes INFO messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    # set a format which is simpler for console use
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.root.addHandler(console)


    logging.info('Converting from Sobek3 to D-Flow FM: ' + os.path.basename(input_file))
    sobek3_2_fm_converter(input_file, output_dir, generate_2d_grid)
    logging.info('Finished')







