# Seed script used to auto-generate SSL certificates if necessary and ensure they can be shared
# between all services to establish trust via a volume.

# Always export password (no error if missing unless SSL is enabled)
if [[ -s /run/secrets/ssl_keystore_password ]]; then
  export SSL_KEYSTORE_PASSWORD="$(cat /run/secrets/ssl_keystore_password)"
else
  # It will be empty, but user have a possibility to change server.ssl.key-store-password=${SSL_KEYSTORE_PASSWORD}
  # to normal password - no error thrown will let user skip having secret of ssl_keystore_password and even use ENC(...)
  export SSL_KEYSTORE_PASSWORD=""
fi

if [[ "${ENABLE_SSL:-false}" == "true" ]]; then
  echo "SSL is enabled"

  if [[ -z "${SSL_KEYSTORE_PASSWORD}" ]]; then
    echo "ERROR: SSL keystore password secret not found or empty" >&2
    exit 1
  fi

  PUBLIC_CERTIFICATES_PATH="/public-certificates"
  PROVIDED_CERTIFICATES_PATH="/server/config"
  INSIGHT_GENERATED_KEYSTORE_SERVER="${PUBLIC_CERTIFICATES_PATH}/insight-keystore-server-ssl"
  INSIGHT_GENERATED_KEYSTORE_WORKER="${PUBLIC_CERTIFICATES_PATH}/insight-keystore-worker-ssl"
  INSIGHT_PROVIDED_KEYSTORE_SERVER="${PROVIDED_CERTIFICATES_PATH}/insight-keystore-server-ssl"

  # Checking if user provided SSL keystore, if not, generate it
  if [[ -f ${INSIGHT_PROVIDED_KEYSTORE_SERVER} ]]; then
    echo "Using provided server's SSL keystore ${INSIGHT_PROVIDED_KEYSTORE_SERVER}"
  elif [[ -f ${INSIGHT_GENERATED_KEYSTORE_SERVER} ]]; then
    echo "Using generated server's SSL keystore ${INSIGHT_GENERATED_KEYSTORE_SERVER}"
  else
    # Remove any existing insight-keystore
    rm -f ${INSIGHT_GENERATED_KEYSTORE_SERVER}
    rm -f ${INSIGHT_GENERATED_KEYSTORE_WORKER}
    echo "Creating keystores for server and worker: ${INSIGHT_GENERATED_KEYSTORE_SERVER} & ${INSIGHT_GENERATED_KEYSTORE_WORKER}"

    # 1. Generate server’s keypair under alias insight-server-https
    keytool -genkeypair \
      -alias insight-server-https \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -keystore "${INSIGHT_GENERATED_KEYSTORE_SERVER}" -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -dname "cn=server, ou=fico, o=xpress, c=insight" \
      -ext "SAN=dns:server,dns:localhost,dns:host.docker.internal,ip:127.0.0.1"

    # 2. Generate worker’s keypair under alias insight-worker-https in worker's keystore
    keytool -genkeypair \
      -alias insight-worker-https \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -keystore "${INSIGHT_GENERATED_KEYSTORE_WORKER}" -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -dname "cn=worker, ou=fico, o=xpress, c=insight" \
      -ext "SAN=dns:worker,dns:localhost,dns:host.docker.internal,ip:127.0.0.1"

    # 3. Export server’s public certificate
    keytool -exportcert \
      -rfc \
      -alias insight-server-https \
      -keystore "${INSIGHT_GENERATED_KEYSTORE_SERVER}" -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -file ${PUBLIC_CERTIFICATES_PATH}/insight-server-cert.pem

    # 4. Export worker’s public certificate
    keytool -exportcert \
      -rfc \
      -alias insight-worker-https \
      -keystore "${INSIGHT_GENERATED_KEYSTORE_WORKER}" -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -file ${PUBLIC_CERTIFICATES_PATH}/insight-worker-cert.pem

    # 5. Create a truststore for workers to trust the server’s cert
    rm -f ${PUBLIC_CERTIFICATES_PATH}/insight-cacerts-server
    keytool -importcert \
      -alias insight-server-https \
      -file ${PUBLIC_CERTIFICATES_PATH}/insight-server-cert.pem \
      -keystore ${PUBLIC_CERTIFICATES_PATH}/insight-cacerts-server \
      -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -noprompt

    # keep cert to be used by Workbench
    # rm -f ${PUBLIC_CERTIFICATES_PATH}/insight-server-cert.pem

    # 6. Create a truststore for the server to trust the worker’s cert
    rm -f ${PUBLIC_CERTIFICATES_PATH}/insight-cacerts-worker
    keytool -importcert \
      -alias insight-worker-https \
      -file ${PUBLIC_CERTIFICATES_PATH}/insight-worker-cert.pem \
      -keystore ${PUBLIC_CERTIFICATES_PATH}/insight-cacerts-worker \
      -storepass "${SSL_KEYSTORE_PASSWORD}" \
      -noprompt
    rm -f ${PUBLIC_CERTIFICATES_PATH}/insight-worker-cert.pem

    # 7. Add Tableau cert to trust store, if provided
    if [[ -f "${PROVIDED_CERTIFICATES_PATH}/tableau-cert.pem" ]]; then
      echo "Using provided tableau certificate"
      keytool -importcert \
        -alias tableau-https \
        -file ${PROVIDED_CERTIFICATES_PATH}/tableau-cert.pem \
        -keystore ${PUBLIC_CERTIFICATES_PATH}/insight-cacerts-worker \
        -storepass "${SSL_KEYSTORE_PASSWORD}" \
        -noprompt
    fi

    echo "server and worker certificates were generated to ${PUBLIC_CERTIFICATES_PATH} to establish SSL connection"
  fi
fi