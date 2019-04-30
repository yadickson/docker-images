#!/bin/bash

function gfInit {
  if [ -z "$GF_ADMINPASSWORD" ]; then
	GF_ADMINPASSWORD=adminadmin
  fi
  if [ -z "$GF_MASTERPASSWORD" ]; then
	GF_MASTERPASSWORD=changeit
  fi
  if [ -z "$PKCSALIAS" ]; then
	PKCSALIAS=localhost
  fi
  if [ -z "$HOSTNAME" ]; then
	HOSTNAME=localhost
  fi
  createAsadminPassfile
  $GF_ASADMIN --user=admin --passwordfile $GF_TEMP_PASSFILE create-domain --savemasterpassword=true --savelogin=true --keytooloptions CN=$HOSTNAME $GF_DOMAIN
  rm $GF_TEMP_PASSFILE
  ln -s $GF_DOMAINDIR/config/master-password $GF_DOMAINDIR/master-password
  if [ -d "$GF_DOMAINBASEDIR/certs" ]; then
    for certfile in $GF_DOMAINBASEDIR/certs/*; do
      certalias=$(basename "$certfile" | cut -d. -f1)
      $KEYTOOL -importcert -trustcacerts -alias $certalias -file $certfile -keystore $CASTORE -storepass $GF_MASTERPASSWORD -noprompt
    done
    rm -r $GF_DOMAINBASEDIR/certs
  fi
  if [ -f "$GF_DOMAINBASEDIR/server.p12" ]; then
    $KEYTOOL -exportcert -keystore $GF_DOMAINBASEDIR/server.p12 -storetype PKCS12 -file $GF_DOMAINBASEDIR/server.cert -storepass $GF_MASTERPASSWORD -alias $PKCSALIAS
    $KEYTOOL -delete -alias s1as -keystore $KEYSTORE -storepass $GF_MASTERPASSWORD
    $KEYTOOL -delete -alias s1as -keystore $CASTORE  -storepass $GF_MASTERPASSWORD
    $KEYTOOL -delete -alias glassfish-instance -keystore $KEYSTORE -storepass $GF_MASTERPASSWORD
    $KEYTOOL -delete -alias glassfish-instance -keystore $CASTORE  -storepass $GF_MASTERPASSWORD
    $KEYTOOL -importkeystore -srckeystore $GF_DOMAINBASEDIR/server.p12 -srcstoretype PKCS12 -destkeystore $KEYSTORE -srcalias $PKCSALIAS -storepass $GF_MASTERPASSWORD -srcstorepass $GF_MASTERPASSWORD -destalias s1as
    $KEYTOOL -importkeystore -srckeystore $GF_DOMAINBASEDIR/server.p12 -srcstoretype PKCS12 -destkeystore $KEYSTORE -srcalias $PKCSALIAS -storepass $GF_MASTERPASSWORD -srcstorepass $GF_MASTERPASSWORD -destalias glassfish-instance
    $KEYTOOL -import -file $GF_DOMAINBASEDIR/server.cert -storepass $GF_MASTERPASSWORD -noprompt -keystore $CASTORE -alias s1as
    $KEYTOOL -import -file $GF_DOMAINBASEDIR/server.cert -storepass $GF_MASTERPASSWORD -noprompt -keystore $CASTORE -alias glassfish-instance
    rm $GF_DOMAINBASEDIR/server.p12
    rm $GF_DOMAINBASEDIR/server.cert
  fi
  if [ -f "$GF_DOMAINBASEDIR/krb5.conf" ] && [ -f "$GF_DOMAINBASEDIR/server.keytab" ]; then
    mv $GF_DOMAINBASEDIR/krb5.conf $GF_DOMAINDIR/config/
    mv $GF_DOMAINBASEDIR/server.keytab $GF_DOMAINDIR/config/
    chmod 0600 $GF_DOMAINDIR/config/server.keytab
    cat <<EOF >> $GF_DOMAINDIR/config/login.conf
spnego-client {
       com.sun.security.auth.module.Krb5LoginModule required;
};

spnego-server {
       com.sun.security.auth.module.Krb5LoginModule required
       debug=false
       useKeyTab=true
       keyTab=server.keytab
       principal="$KRB_PRINCIPAL"
       storeKey=true;
};
EOF
  fi
  $GF_ASADMIN start-domain
  $GF_ASADMIN enable-secure-admin
  $GF_ASADMIN delete-jvm-options -- -client
  $GF_ASADMIN create-jvm-options -- -server
  $GF_ASADMIN delete-jvm-options -- -Xmx512m
  $GF_ASADMIN create-jvm-options -- -Xms4096m
  $GF_ASADMIN create-jvm-options -- -Xmx4096m
  $GF_ASADMIN delete-jvm-options '-XX\:MaxPermSize=192m'
  $GF_ASADMIN create-jvm-options -- '-XX\:MaxMetaspaceSize=512m'
  $GF_ASADMIN create-jvm-options -- '-XX\:MetaspaceSize=512m'
  $GF_ASADMIN create-jvm-options -Djdk.tls.rejectClientInitiatedRenegotiation=true
  $GF_ASADMIN set server.admin-service.das-config.autodeploy-enabled=false
  $GF_ASADMIN set configs.config.server-config.admin-service.das-config.dynamic-reload-enabled=false
  $GF_ASADMIN set server.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled=false
  $GF_ASADMIN set server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled=false
  $GF_ASADMIN set server.iiop-service.iiop-listener.SSL.ssl.ssl3-enabled=false
  $GF_ASADMIN set server.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-enabled=false
  $GF_ASADMIN set configs.config.server-config.network-config.protocols.protocol.http-listener-1.http.header-buffer-length-bytes=131072
  $GF_ASADMIN set configs.config.server-config.network-config.protocols.protocol.http-listener-2.http.header-buffer-length-bytes=131072
  $GF_ASADMIN set configs.config.server-config.network-config.transports.transport.tcp.buffer-size-bytes=262144
  $GF_ASADMIN set configs.config.server-config.admin-service.property.adminConsoleStartup=ALWAYS
  $GF_ASADMIN stop-domain
}

#
# create asadmin password file
#
function createAsadminPassfile {
  cat <<EOF > $GF_TEMP_PASSFILE
AS_ADMIN_PASSWORD=$GF_ADMINPASSWORD
AS_ADMIN_ADMINPASSWORD=$GF_ADMINPASSWORD
AS_ADMIN_USERPASSWORD=$GF_ADMINPASSWORD
AS_ADMIN_MASTERPASSWORD=$GF_MASTERPASSWORD
EOF
}

