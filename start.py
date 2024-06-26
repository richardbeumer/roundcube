#!/usr/bin/python3

import os
import logging as log
import sys
from socrate import conf
import subprocess

log.basicConfig(stream=sys.stderr, level=os.environ.get("LOG_LEVEL", "WARNING"))
env = os.environ

context = {}
context.update(env)

os.environ["MAX_FILESIZE"] = str(int(int(env.get("MESSAGE_SIZE_LIMIT"))*0.66/1048576))
with open("/etc/resolv.conf") as handle:
    content = handle.read().split()
    resolver = content[content.index("nameserver") + 1]
    context["RESOLVER"] = f"[{resolver}]" if ":" in resolver else resolver

db_flavor=os.environ.get("ROUNDCUBE_DB_FLAVOR",os.environ.get("DB_FLAVOR","sqlite"))
if db_flavor=="sqlite":
    os.environ["DB_DSNW"]="sqlite:////data/roundcube.db"
elif db_flavor=="mysql":
    os.environ["DB_DSNW"]="mysql://%s:%s@%s/%s" % (
        os.environ.get("ROUNDCUBE_DB_USER","roundcube"),
        os.environ.get("ROUNDCUBE_DB_PW"),
        os.environ.get("ROUNDCUBE_DB_HOST",os.environ.get("DB_HOST","database")),
        os.environ.get("ROUNDCUBE_DB_NAME","roundcube")
        )
elif db_flavor=="postgresql":
    os.environ["DB_DSNW"]="pgsql://%s:%s@%s/%s" % (
        os.environ.get("ROUNDCUBE_DB_USER","roundcube"),
        os.environ.get("ROUNDCUBE_DB_PW"),
        os.environ.get("ROUNDCUBE_DB_HOST",os.environ.get("DB_HOST","database")),
        os.environ.get("ROUNDCUBE_DB_NAME","roundcube")
        )
else:
    print("Unknown ROUNDCUBE_DB_FLAVOR: %s",db_flavor)
    exit(1)



conf.jinja("/php.ini", os.environ, "/usr/local/etc/php/conf.d/roundcube.ini")

# Create dirs, setup permissions
os.system("mkdir -p /data/gpg /var/www/html/logs")
os.system("touch /var/www/html/logs/errors.log")
os.system("chown -R www-data:www-data /var/www/html/logs")

try:
    print("Initializing database")
    result=subprocess.check_output(["/var/www/html/bin/initdb.sh","--dir","/var/www/html/SQL"],stderr=subprocess.STDOUT)
    print(result.decode())
except subprocess.CalledProcessError as e:
    if "already exists" in e.stdout.decode():
        print("Already initialzed")
    else:
        print(e.stdout.decode())
        quit(1)

try:
    print("Upgrading database")
    subprocess.check_call(["/var/www/html/bin/update.sh","--version=?","-y"],stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as e:
    quit(1)

# Setup database permissions
os.system("chown -R www-data:www-data /data")

# Tail roundcube logs
subprocess.Popen(["tail","-f","-n","0","/var/www/html/logs/errors.log"])

# Configure nginx
conf.jinja("/conf/nginx-webmail.conf", context, "/etc/nginx/http.d/webmail.conf")
if os.path.exists("/var/run/nginx.pid"):
    os.system("nginx -s reload")


# Run nginx
os.system("php-fpm83")
os.execv("/usr/sbin/nginx", ["nginx", "-g", "daemon off;"])