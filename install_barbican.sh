source config.cfg
# Step 0: Update Sever
apt update && apt dist-upgrade

# Step 1: Install RabbitMQ
apt-get install rabbitmq-server -y
rabbitmqctl add_user $RABBIT_USER $RABBIT_PASSWORD
rabbitmqctl set_permissions $RABBIT_USER ".*" ".*" ".*"


# Step2: Install Mysql-server
echo mysql-server mysql-server/root_password password $DATABASE_PASSWORD | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $DATABASE_PASSWORD | debconf-set-selections
apt-get -y install mysql-server

# Install Barbican without Keystone
# Create a database:
cat << EOF | mysql -uroot -p$DATABASE_PASSWORD
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '$BARBICAN_PASSWORD';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '$BARBICAN_PASSWORD';
FLUSH PRIVILEGES;
EOF

# Enable the Openstack repo
apt install -y software-properties-common
add-apt-repository -y cloud-archive:newton
apt -y update && apt -y  dist-upgrade

# Install Openstack-client
apt install python-openstackclient -y


# Install package barbican-service
apt-get -y install barbican-api barbican-keystone-listener barbican-worker

# Change file barbican.conf
sed -i "s/sql_connection = sqlite:\/\/\/\/var\/lib\/barbican\/barbican.sqlite/sql_connection = mysql+pymysql:\/\/barbican:$BARBICAN_PASSWORD@127.0.0.1\/barbican?charset=utf8/g" /etc/barbican/barbican.conf

sed -i "s/rabbit_userid=guest/rabbit_userid=$RABBIT_USER/g" /etc/barbican/barbican.conf
sed -i "s/rabbit_password=guest/rabbit_password=$RABBIT_PASSWORD/g" /etc/barbican/barbican.conf
sed -i "0,/enable = False/s//enable = True/" /etc/barbican/barbican.conf

# Upgrade Database
barbican-manage db upgrade

# Restart service
/etc/init.d/apache2 restart
/etc/init.d/barbican-keystone-listener restart
/etc/init.d/barbican-worker restart
