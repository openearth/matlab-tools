###############################################################################
# modules                                                                     #
###############################################################################

import os, smtplib, mimetypes

from email                  import encoders
from email.message          import Message
from email.mime.audio       import MIMEAudio
from email.mime.base        import MIMEBase
from email.mime.image       import MIMEImage
from email.mime.multipart   import MIMEMultipart
from email.mime.text        import MIMEText

from config                 import config
from network                import storage

###############################################################################
# functions                                                                   #
###############################################################################

def send_reports(runid, cfg, recipients):
    'Send reports by e-mail'

    success = []
    failure = []

    # send e-mail if minimal information is provided
    if cfg.has_key('smtp') and len(recipients) > 0:

        # create multipart mime message
        message_file    = os.path.join(config.get_root(), 'tools', cfg['message'])

        # determine pdf dir
        pdf_path        = os.path.join(config.get_root(), 'runs', runid, 'report')

        # connect to smtp server
        smtp            = smtplib.SMTP(cfg['smtp'])

        # loop through mailinglist
        for recipient, reports in recipients.iteritems():

            mail        = create_email(cfg, message_file, '[update]')
            mail['To']  = recipient

            attachments = [r.strip() for r in reports.split(',')]

            for pdf in os.listdir(pdf_path):
                if pdf[-4:] == '.pdf':
                    if pdf in attachments or 'all' in attachments:

                        file_path = os.path.join(pdf_path, pdf)

                        if os.path.exists(file_path):

                            # determine mime type
                            ctype, encoding = mimetypes.guess_type(file_path)

                            # check if determination of mime type succeeded, otherwise assume
                            # some binary garbage type
                            if ctype is None or encoding is not None:
                                ctype = 'application/octet-stream'

                            # read attachments based on mime type
                            maintype, subtype = ctype.split('/', 1)
                            if maintype == 'text':
                                fp = open(file_path)
                                data = MIMEText(fp.read(), _subtype=subtype)
                                fp.close()
                            elif maintype == 'image':
                                fp = open(file_path, 'rb')
                                data = MIMEImage(fp.read(), _subtype=subtype)
                                fp.close()
                            elif maintype == 'audio':
                                fp = open(file_path, 'rb')
                                data = MIMEAudio(fp.read(), _subtype=subtype)
                                fp.close()
                            else:
                                # attach base64 encoded binary garbage type
                                fp = open(file_path, 'rb')
                                data = MIMEBase(maintype, subtype)
                                data.set_payload(fp.read())
                                fp.close()
                                encoders.encode_base64(data)

                            # attach attachments to mail labeled as attachment
                            data.add_header('Content-Disposition', 'attachment', filename=pdf)
                            mail.attach(data)

            # generate mime body
            mail_body   = mail.as_string()

            # send mail
            try:
                smtp.sendmail(mail['From'], recipient, mail_body)
                success.append(recipient)
            except:
                failure.append(recipient)

        smtp.quit()

    return (success, failure)

def send_notification(runid, storage_path, cfg, recipient):
    'Send notification by e-mail'

    # send e-mail if minimal information is provided
    if cfg.has_key('smtp'):

        markers = {                                                                         \
            'runid'         : runid,                                                        \
            'storage_path'  : os.path.join(storage.get_network_path(storage_path, runid)[1])     }

        # create multipart mime message
        message_file    = os.path.join(config.get_root(), 'tools', cfg['notification'])
        mobj            = create_email(cfg, message_file, '[notification]', **markers)

        # connect to smtp server
        smtp            = smtplib.SMTP(cfg['smtp'])

        # generate mime body
        mail_body       = mobj.as_string()

        # send mail
        try:
            smtp.sendmail(mobj['From'], recipient, mail_body)
        except:
            pass

        smtp.quit()

def create_email(cfg, message_file, ad, **markers):
    'Create an e-mail object'

    mobj                = []

    # create e-mail if minimal information is provided
    if cfg.has_key('smtp'):

        # create multipart mime message (with attachments)
        mobj            = MIMEMultipart()

        # set default e-mail settings
        mobj['From']    = cfg['from']
        mobj['Subject'] = cfg['subject']+' '+ad
        mobj.preamble   = 'This message has been MIME-formatted.\n'

        # read and attch message body
        if os.path.exists(message_file):
            fp          = open(message_file)
            message     = fp.read()
            message     = message.format(**markers)
            message     = MIMEText(message, _subtype='plain')
            fp.close()

            mobj.attach(message)

    return mobj