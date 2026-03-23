FROM ghcr.io/orissolutions/odoo:18.0

USER root

RUN apt-get update && apt-get install -y python3-dev build-essential python3-levenshtein libmagic1 libssl-dev libffi-dev zlib1g-dev cargo git vim

RUN pip3 install --break-system-packages wheel
RUN pip3 install --break-system-packages --ignore-installed py3o.template py3o.formats html2text pyfcm barcode google_auth redis rstr jsonrpcclient PyJWT pandas openpyxl pycryptodome curlify pyzk

COPY odoo-upgrade /usr/local/bin/odoo-upgrade
COPY odoo-shell   /usr/local/bin/odoo-shell
RUN chmod +x /usr/local/bin/odoo-*

USER odoo

