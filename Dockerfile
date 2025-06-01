FROM odoo:18.0
# Of course, you can change the 12.0 by the version you want

USER root

RUN apt-get update && apt-get install -y python3-dev build-essential python3-levenshtein libmagic1 libssl-dev libffi-dev zlib1g-dev cargo git vim

RUN pip3 install --break-system-packages wheel
RUN pip3 install --break-system-packages --ignore-installed py3o.template py3o.formats html2text pyfcm barcode google_auth redis rstr jsonrpcclient PyJWT pandas openpyxl curlify pyzk

ADD entrypoint.sh /

RUN chown odoo /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER odoo