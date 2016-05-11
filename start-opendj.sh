#!/bin/bash
set -e

# ENV
echo ${LDAPORT:-389}
echo ${LDAPSPORT:-636}
echo ${ADMINPORT:-4444}
echo ${BASEDN:-dc=example,dc=com}
echo ${HOST:-localhost}
echo "${PASSWORD:-admin123}"

initLdap(){
  echo "Initializing Ldap ..."
  /opt/opendj/setup --cli --ldapPort ${LDAPORT:-389} --ldapsPort ${LDAPSPORT:-636} --adminConnectorPort ${ADMINPORT:-4444} --enableStartTLS --generateSelfSignedCertificate --baseDN ${BASEDN:-dc=example,dc=com} -h ${HOST:-localhost} --rootUserPassword "${PASSWORD:-admin123}" --acceptLicense --no-prompt
}

stopServer(){
  /opt/opendj/bin/stop-ds
}

loadDump(){
  echo "Loading dump file ..."
  /opt/opendj/bin/import-ldif --includeBranch "${BASEDN}" --backendID userRoot --ldifFile "${DUMPLDAP}"
}

startServer(){
  exec /opt/opendj/bin/start-ds --nodetach
}

if [ "${INIT_LDAP}" == "true" ]; then
    initLdap
    stopServer
fi

if [ -e "${LOAD_DUMP}" ]; then
    stopServer
    loadDump
fi
startServer
