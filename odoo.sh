#!/bin/bash

# Actualizamos las librerías.
sudo apt update && apt upgrade -y

# Creamos el usuario y grupo de sistema 'odoo'.
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo

# Creamos en directorio en donde se almacenará el archivo de configuración de Odoo.
sudo mkdir /etc/odoo

# Instalamos Postgres y librerías de Python necesarias.
sudo apt install postgresql postgresql-server-dev-14 git python3 python3-pip build-essential python3-dev libldap2-dev libsasl2-dev python3-setuptools libjpeg-dev nodejs npm -y

# Descargamos odoo version 16 utilizando git para descargarlo desde Github.
sudo git clone --depth 1 --branch 16.0 https://github.com/odoo/odoo /opt/odoo/odoo

# Damos permiso al directorio que contiene los archivos de OdooERP e instalamos las dependencias de Python3.
sudo chown odoo:odoo /opt/odoo/ -R && sudo rm /usr/lib/python3/dist-packages/_cffi_backend.cpython-310-x86_64-linux-gnu.so 
sudo pip3 install cffi && sudo pip3 install -r /opt/odoo/odoo/requirements.txt

# Descargamos wkhtmltopdf para generar PDF en Odoo.
sudo apt install wkhtmltopdf -y
sudo wkhtmltopdf --version

sleep 4

# Creamos un usuario 'odoo' para la base de datos.
sudo su - postgres -c "createuser -s odoo"

# Creamos la configuracion de Odoo.
sudo su - odoo -c "/opt/odoo/odoo/odoo-bin --addons-path=/opt/odoo/odoo/addons -s --stop-after-init"

# Creamos el archivo de configuracion de Odoo.
sudo tee /etc/odoo/odoo.conf > /dev/null <<EOF
[options]
addons_path = /opt/odoo/odoo/addons
admin_passwd = admin
csv_internal_sep = ,
data_dir = /opt/odoo/.local/share/Odoo
db_host = False
db_maxconn = 64
db_name = False
db_password = False
db_port = False
db_sslmode = prefer
db_template = template0
db_user = False
dbfilter = 
demo = {}
email_from = False
from_filter = False
geoip_database = /usr/share/GeoIP/GeoLite2-City.mmdb
gevent_port = 8072
http_enable = True
http_interface = 
http_port = 8069
import_partial = 
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 65536
limit_time_cpu = 60
limit_time_real = 120
limit_time_real_cron = -1
list_db = True
log_db = False
log_db_level = warning
log_handler = :INFO
log_level = info
logfile =
max_cron_threads = 2
osv_memory_age_limit = False
osv_memory_count_limit = 0
pg_path = 
pidfile = 
proxy_mode = False
reportgz = False
screencasts = 
screenshots = /tmp/odoo_tests
server_wide_modules = base,web
smtp_password = False
smtp_port = 25
smtp_server = localhost
smtp_ssl = False
smtp_ssl_certificate_filename = False
smtp_ssl_private_key_filename = False
smtp_user = False
syslog = False
test_enable = False
test_file = 
test_tags = None
transient_age_limit = 1.0
translate_modules = ['all']
unaccent = False
upgrade_path = 
websocket_keep_alive_timeout = 3600
websocket_rate_limit_burst = 10
websocket_rate_limit_delay = 0.2
without_demo = False
workers = 0
x_sendfile = False
EOF

# Creamos el archivo de inicio del servicio de Odoo.
sudo cp /opt/odoo/odoo/debian/init /etc/init.d/odoo && sudo chmod -R 777 /etc/init.d/odoo
sudo ln -s /opt/odoo/odoo/odoo-bin /usr/bin/odoo

sudo update-rc.d -f odoo start 20 2 3 4 5 .

sudo service odoo start
sudo service odoo status
